# ------------------------------------------------------------------------------
# AKS Cluster (set deploy_aks = false to use existing cluster)
# ------------------------------------------------------------------------------
variable "deploy_aks" {
  description = "Whether to deploy a new AKS cluster (true) or use existing cluster (false)"
  type        = bool
  default     = true
}

variable "resource_group_name" {
  description = "Azure resource group name"
  type        = string
}

variable "location" {
  description = "Azure region for resources"
  type        = string
  default     = "eastus"
}

variable "aks_cluster_name" {
  description = "Name of the AKS cluster (used when deploy_aks=true)"
  type        = string
  default     = "backstage-aks"
}

variable "aks_node_count" {
  description = "Number of worker nodes for AKS"
  type        = number
  default     = 2
}

variable "aks_vm_size" {
  description = "VM size for AKS worker nodes"
  type        = string
  default     = "Standard_D2s_v3"
}

# ------------------------------------------------------------------------------
# Existing AKS (when deploy_aks = false)
# ------------------------------------------------------------------------------
variable "existing_aks_name" {
  description = "Name of existing AKS cluster (when deploy_aks=false)"
  type        = string
  default     = ""
}

variable "existing_aks_rg" {
  description = "Resource group of existing AKS cluster (when deploy_aks=false)"
  type        = string
  default     = ""
}

# ------------------------------------------------------------------------------
# Backstage Helm Configuration
# ------------------------------------------------------------------------------
variable "backstage_namespace" {
  description = "Kubernetes namespace for Backstage"
  type        = string
  default     = "backstage"
}

variable "backstage_release_name" {
  description = "Helm release name for Backstage"
  type        = string
  default     = "backstage"
}

variable "backstage_chart_version" {
  description = "Backstage Helm chart version"
  type        = string
  default     = "2.6.3"
}

variable "backstage_image_tag" {
  description = "Backstage container image tag"
  type        = string
  default     = "latest"
}

variable "backstage_custom_image" {
  description = "Custom Backstage image (leave empty to use default ghcr.io/backstage/backstage)"
  type        = string
  default     = ""
}

variable "backstage_ingress_enabled" {
  description = "Enable Ingress for external access"
  type        = bool
  default     = true
}

variable "backstage_ingress_host" {
  description = "Ingress hostname (e.g., backstage.yourdomain.com)"
  type        = string
  default     = ""
}

variable "postgresql_enabled" {
  description = "Deploy PostgreSQL as subchart (recommended for dev/demo)"
  type        = bool
  default     = true
}

variable "postgresql_password" {
  description = "PostgreSQL password (use env/sensitive - do not commit)"
  type        = string
  sensitive   = true
  default     = ""
}

# ------------------------------------------------------------------------------
# Tags
# ------------------------------------------------------------------------------
variable "tags" {
  description = "Tags to apply to Azure resources"
  type        = map(string)
  default     = {}
}
