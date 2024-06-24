variable "resource_group_name" {
  description = "The name of the resource group in which to create the demo registry."
  type = string
} 

variable "location" {
  description = "The location/region where the demo registry should be created."
  type = string 
}

variable "acr_name" {
  description = "The name of the Azure Container Registry."
  type = string
}