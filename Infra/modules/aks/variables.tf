variable "resource_group_name" {
  description = "The name of the resource group in which to create the AKS cluster."
  type = string
}

variable "location" {
  description = "The location/region where the AKS cluster should be created."
  type = string
}

variable "aks_name" {
  description = "The name of the Azure Kubernetes Service cluster."
  type = string
}