provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "rg" {
  name = var.resource_group_name
  location = var.location
}

module "aks" {
  source = "./modules/aks"
  resource_group_name = azurerm_resource_group.rg.name
  location = azurerm_resource_group.rg.location
  aks_name = var.aks_name
}

module "acr" {
  source = "./modules/acr"
  resource_group_name = azurerm_resource_group.rg.name
  location = azurerm_resource_group.rg.location
  acr_name = var.acr_name
}

module "identity" {
  source = "./modules/identity"
  issuer = module.aks.aksconfig.issuer
}

module "app" {
  source = "./modules/app"
  aks_host = module.aks.aksconfig.host
  aks_ca_certificate = module.aks.aksconfig.cluster_ca_certificate
  aks_client_certificate = module.aks.aksconfig.client_certificate
  aks_client_certificate_key = module.aks.aksconfif.client_secret
  azure_ad_application_id = module.identity.app_id
}