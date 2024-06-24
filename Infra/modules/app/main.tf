provider "helm" {
  kubernetes {
    host                   = azurerm_kubernetes_cluster.default.kube_config.0.host
    client_certificate     = base64decode(var.aks_client_certificate)
    client_key             = base64decode(var.aks_client_certificate_key)
    cluster_ca_certificate = base64decode(var.aks_ca_certificate)
  }
}

resource "helm_release" "azure-workload-identity" {
  name             = "azure-workload-identity"
  repository       = "https://azure.github.io/azure-workload-identity/charts"
  chart            = "workload-identity-webhook"
  namespace        = "azure-workload-identity-system"
  create_namespace = true

  set {
    name  = "azureTenantID"
    value = data.azuread_client_config.current.tenant_id
  }

  depends_on = [
    module.aks.azurerm_kubernetes_cluster.default
  ]
}

## Application deployment

provider "kubernetes" {
  host = azurerm_kubernetes_cluster.default.kube_config.0.host

  client_certificate     = base64decode(var.aks_client_certificate)
  client_key             = base64decode(var.aks_client_certificate_key)
  cluster_ca_certificate = base64decode(var.aks_ca_certificate)
}

resource "kubernetes_service_account_v1" "sa" {
  metadata {
    name      = "workload-identity-sa"
    namespace = "default"
    annotations = {
      "azure.workload.identity/client-id" : var.azure_ad_application_id
    }
    labels = {
      "azure.workload.identity/use" = "true"
    }

  }
}

resource "kubernetes_deployment" "app" {

  metadata {
    name = "app-example"
    labels = {
      test = "MyExampleApp"
    }
  }

  spec {
    replicas = 2
    selector {
      match_labels = {
        test = "MyExampleApp"
      }
    }

    template {
      metadata {
        labels = {
          test = "MyExampleApp"
        }
      }

      spec {
        service_account_name = kubernetes_service_account_v1.sa.metadata[0].name
        container {
          image = "gjoshevski/aks-pod-info"  ## Change this if you want to use your image
          name  = "app"
          port {
            container_port = 3000
          }
          env {
            name  = "AZURE_SUBSCRIPTION_ID"
            value = data.azurerm_client_config.current.subscription_id
          }
          env {
            name  = "AZURE_SERVICE_PRINCIPAL_OBJECT_ID"
            value = var.azure_ad_application_id
          }
          resources {
            limits = {
              cpu    = "0.5"
              memory = "512Mi"
            }
            requests = {
              cpu    = "250m"
              memory = "50Mi"
            }
          }

        }
      }
    }
  }

  depends_on = [
    kubernetes_service_account_v1.sa,
    helm_release.azure-workload-identity
  ]
}

resource "kubernetes_service" "app" {
  metadata {
    name = "app-example"
  }

  spec {
    type = "LoadBalancer"
    selector = {
      test = "MyExampleApp"
    }
    session_affinity = "ClientIP"
    port {
      port        = 80
      target_port = 3000
    }
  }
}

data "azurerm_subscription" "primary" {
}

resource "azurerm_role_definition" "azurerm_custom_role" {
  name               = "my-custom-role-definition"
  scope              = data.azurerm_subscription.primary.id

  permissions {
    actions     = ["Microsoft.Authorization/roleAssignments/read"]
    not_actions = []
  }

  assignable_scopes = [
    data.azurerm_subscription.primary.id,
  ]
}

