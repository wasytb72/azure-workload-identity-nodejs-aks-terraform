data "azuread_client_config" "current" {}

resource "azuread_application" "directory_role_app" {
  display_name = "${random_pet.prefix.id}-app"
  owners       = [data.azuread_client_config.current.object_id]
}

resource "azuread_service_principal" "directory_role_app" {
  application_id = azuread_application.directory_role_app.application_id
  use_existing   = true
}

resource "azuread_application_federated_identity_credential" "directory_role_app" {
  application_object_id = azuread_service_principal.directory_role_app.object_id
  display_name          = "kubernetes-federated-credential"
  description           = "Kubernetes service account federated credential"
  audiences             = ["api://AzureADTokenExchange"]
  subject               = "system:serviceaccount:default:workload-identity-sa" #TODO: this is hardcoded
  issuer                = var.issuer
}