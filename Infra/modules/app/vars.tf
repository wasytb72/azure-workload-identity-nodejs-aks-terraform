variable "aks_host" {
    description = "The host config for the AKS cluster."
    type = string
}

variable "aks_client_certificate" {
    description = "The certificate for the AKS cluster."
    type = string
}

variable "aks_client_certificate_key" {
    description = "The certificate key for the AKS cluster."
    type = string  
}

variable "aks_ca_certificate" {
    description = "The CA certificate for the AKS cluster."
    type = string  
}

variable "azure_ad_application_id" {
    description = "The Azure AD application ID."
    type = string
}