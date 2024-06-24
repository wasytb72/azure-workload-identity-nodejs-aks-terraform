resource "azurerm_kubernetes_cluster" "default" {
  name                = "${random_pet.prefix.id}-${var.aks_name}"
  location            = var.location
  resource_group_name = var.resource_group_name
  dns_prefix          = "${random_pet.prefix.id}-${var.aks_name}"
  oidc_issuer_enabled = true

  default_node_pool {
    name            = "default"
    node_count      = 1
    vm_size         = "Standard_D2_v5"
    os_disk_size_gb = 30
  }

  identity {
    type = "SystemAssigned"
  }


  tags = {
    environment = "Demo"
  }

  depends_on = [
    null_resource.oidc_issuer_enabled
  ]
}