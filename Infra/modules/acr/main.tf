resource "random_pet" "prefix" {}

## Container Registry

resource "azurerm_container_registry" "acr" {
  name                = replace("${random_pet.prefix.id}", "-", "")
  resource_group_name = var.resource_group_name
  location            = var.location
  sku                 = "Standard"
  admin_enabled       = true
}

resource "azurerm_role_assignment" "acrpull_role" {
  scope                            = azurerm_container_registry.acr.id
  role_definition_name             = "AcrPull"
  principal_id                     = azurerm_kubernetes_cluster.default.kubelet_identity[0].object_id
  skip_service_principal_aad_check = true
}

## Build Image and push to ECR

resource "null_resource" "docker_build" {
  provisioner "local-exec" {
    command = <<-EOT
      docker build -t ${azurerm_container_registry.acr.name}.azurecr.io/app:latest ../../App/.
    EOT
  }
  triggers = {
    always_run = "${timestamp()}"
  }

  depends_on = [
    azurerm_container_registry.acr
  ]

}

resource "null_resource" "docker_login" {
  provisioner "local-exec" {
    command = <<-EOT
      docker login ${azurerm_container_registry.acr.login_server} -u ${azurerm_container_registry.acr.admin_username} -p ${azurerm_container_registry.acr.admin_password}
    EOT
  }
  triggers = {
    always_run = "${timestamp()}"
  }

  depends_on = [
    null_resource.docker_build
  ]

}

resource "null_resource" "docker_push" {
  provisioner "local-exec" {
    command = <<-EOT
      docker push ${azurerm_container_registry.acr.login_server}/app:latest
    EOT
  }
  triggers = {
    always_run = "${timestamp()}"
  }

  depends_on = [
    null_resource.docker_login
  ]

}