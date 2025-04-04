variable "resource_group_name" {
  description = "The name of the Azure Resource Group where resources will be deployed"
  type        = string
  default     = "rg-04082003"
}

variable "location" {
  description = "The Azure region where resources will be created"
  type        = string
  default     = "Central US"
}

variable "app_service_plan_name" {
  description = "The name of the Azure App Service Plan"
  type        = string
  default     = "my-app-service-plan-04082003"
}

variable "app_service_name" {
  description = "The name of the Azure App Service"
  type        = string
  default     = "webapijenkins-04082003"   //  Global Unique name for Azure App Service
}

