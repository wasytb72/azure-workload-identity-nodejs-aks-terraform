output "aksconfig" {
  value = {
    "client_id" = azurerm.kubernetes_cluster.default.kube_config.0.client_id
    "client_secret" = azurerm.kubernetes_cluster.default.kube_config.0.client_secret
    "cluster_ca_certificate" = azurerm.kubernetes_cluster.default.kube_config.0.cluster_ca_certificate
    "host" = azurerm.kubernetes_cluster.default.kube_config.0.host
    "kube_config" = azurerm_kubernetes_cluster.default.kube_config_raw
    "issuer" = azurerm_kubernetes_cluster.default.kube_config.0.issuer
  }
}