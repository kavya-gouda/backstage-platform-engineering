# ------------------------------------------------------------------------------
# Provider Configuration
# ------------------------------------------------------------------------------
provider "azurerm" {
  features {}
}

data "azurerm_client_config" "current" {}

# ------------------------------------------------------------------------------
# Resource Group (always created for new AKS; optional for existing)
# ------------------------------------------------------------------------------
resource "azurerm_resource_group" "main" {
  count    = var.deploy_aks ? 1 : 0
  name     = var.resource_group_name
  location = var.location
  tags     = var.tags
}

# ------------------------------------------------------------------------------
# AKS Cluster (optional)
# ------------------------------------------------------------------------------
resource "azurerm_kubernetes_cluster" "main" {
  count               = var.deploy_aks ? 1 : 0
  name                = var.aks_cluster_name
  location            = azurerm_resource_group.main[0].location
  resource_group_name = azurerm_resource_group.main[0].name
  dns_prefix          = var.aks_cluster_name
  kubernetes_version  = "1.29"

  default_node_pool {
    name       = "default"
    node_count = var.aks_node_count
    vm_size    = var.aks_vm_size
  }

  identity {
    type = "SystemAssigned"
  }

  tags = var.tags
}

# ------------------------------------------------------------------------------
# Kubernetes & Helm Provider (configure for AKS)
# ------------------------------------------------------------------------------
data "azurerm_kubernetes_cluster" "main" {
  count               = var.deploy_aks ? 1 : 0
  name                = azurerm_kubernetes_cluster.main[0].name
  resource_group_name = azurerm_resource_group.main[0].name
}

data "azurerm_kubernetes_cluster" "existing" {
  count               = var.deploy_aks ? 0 : 1
  name                = var.existing_aks_name
  resource_group_name = var.existing_aks_rg
}

provider "kubernetes" {
  host                   = var.deploy_aks ? data.azurerm_kubernetes_cluster.main[0].kube_config[0].host : data.azurerm_kubernetes_cluster.existing[0].kube_config[0].host
  client_certificate     = base64decode(var.deploy_aks ? data.azurerm_kubernetes_cluster.main[0].kube_config[0].client_certificate : data.azurerm_kubernetes_cluster.existing[0].kube_config[0].client_certificate)
  client_key             = base64decode(var.deploy_aks ? data.azurerm_kubernetes_cluster.main[0].kube_config[0].client_key : data.azurerm_kubernetes_cluster.existing[0].kube_config[0].client_key)
  cluster_ca_certificate = base64decode(var.deploy_aks ? data.azurerm_kubernetes_cluster.main[0].kube_config[0].cluster_ca_certificate : data.azurerm_kubernetes_cluster.existing[0].kube_config[0].cluster_ca_certificate)
}

provider "helm" {
  kubernetes {
    host                   = var.deploy_aks ? data.azurerm_kubernetes_cluster.main[0].kube_config[0].host : data.azurerm_kubernetes_cluster.existing[0].kube_config[0].host
    client_certificate     = base64decode(var.deploy_aks ? data.azurerm_kubernetes_cluster.main[0].kube_config[0].client_certificate : data.azurerm_kubernetes_cluster.existing[0].kube_config[0].client_certificate)
    client_key             = base64decode(var.deploy_aks ? data.azurerm_kubernetes_cluster.main[0].kube_config[0].client_key : data.azurerm_kubernetes_cluster.existing[0].kube_config[0].client_key)
    cluster_ca_certificate = base64decode(var.deploy_aks ? data.azurerm_kubernetes_cluster.main[0].kube_config[0].cluster_ca_certificate : data.azurerm_kubernetes_cluster.existing[0].kube_config[0].cluster_ca_certificate)
  }
}

# ------------------------------------------------------------------------------
# Namespace for Backstage
# ------------------------------------------------------------------------------
resource "kubernetes_namespace" "backstage" {
  metadata {
    name = var.backstage_namespace
    labels = {
      "app.kubernetes.io/managed-by" = "terraform"
    }
  }
}

# ------------------------------------------------------------------------------
# Random password for PostgreSQL if not provided
# ------------------------------------------------------------------------------
resource "random_password" "postgresql" {
  count   = var.postgresql_enabled && var.postgresql_password == "" ? 1 : 0
  length  = 24
  special = true
}

locals {
  postgresql_password = var.postgresql_enabled ? (var.postgresql_password != "" ? var.postgresql_password : random_password.postgresql[0].result) : ""
}

# ------------------------------------------------------------------------------
# Backstage Helm Release (Official Chart)
# Uses file + set for password to avoid values in state
# ------------------------------------------------------------------------------
resource "helm_release" "backstage" {
  name             = var.backstage_release_name
  namespace        = kubernetes_namespace.backstage.metadata[0].name
  repository       = "oci://ghcr.io/backstage/charts/backstage"
  chart            = "backstage"
  version          = var.backstage_chart_version
  create_namespace = false
  wait             = true
  timeout          = 600

  dynamic "set_sensitive" {
    for_each = var.postgresql_enabled ? [1] : []
    content {
      name  = "postgresql.auth.password"
      value = local.postgresql_password
    }
  }

  set {
    name  = "backstage.image.tag"
    value = var.backstage_image_tag
  }

  set {
    name  = "postgresql.enabled"
    value = var.postgresql_enabled
  }

  set {
    name  = "ingress.enabled"
    value = var.backstage_ingress_enabled
  }

  dynamic "set" {
    for_each = var.backstage_ingress_enabled && var.backstage_ingress_host != "" ? [1] : []
    content {
      name  = "ingress.host"
      value = var.backstage_ingress_host
    }
  }

  dynamic "set" {
    for_each = var.backstage_ingress_enabled && var.backstage_ingress_host != "" ? [1] : []
    content {
      name  = "ingress.className"
      value = "nginx"
    }
  }

  dynamic "set" {
    for_each = var.backstage_ingress_enabled && var.backstage_ingress_host != "" ? [1] : []
    content {
      name  = "ingress.tls.enabled"
      value = "true"
    }
  }

  dynamic "set" {
    for_each = var.backstage_ingress_enabled && var.backstage_ingress_host != "" ? [1] : []
    content {
      name  = "backstage.appConfig.app.baseUrl"
      value = "https://${var.backstage_ingress_host}"
    }
  }

  dynamic "set" {
    for_each = var.backstage_ingress_enabled && var.backstage_ingress_host != "" ? [1] : []
    content {
      name  = "backstage.appConfig.backend.baseUrl"
      value = "https://${var.backstage_ingress_host}"
    }
  }
}
