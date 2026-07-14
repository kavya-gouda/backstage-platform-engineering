variable "webAppName" {
  type        = string
  description = "The globally unique name of the Azure Web App."
  default     = "${{ values.webAppName }}"
}

variable "location" {
  type        = string
  description = "The Azure region where resources will be deployed."
  default     = "${{ values.location }}"
}

variable "sku" {
  type        = string
  description = "The pricing tier SKU for the App Service Plan."
  default     = "${{ values.sku }}"
}

variable "runtime" {
  type        = string
  description = "The runtime stack string (e.g., node|24-lts)."
  default     = "${{ values.runtime }}"
}
