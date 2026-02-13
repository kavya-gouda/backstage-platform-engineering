# ------------------------------------------------------------------------------
# Provider Configuration
# ------------------------------------------------------------------------------
provider "azurerm" {
  features {}
}

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
  kubernetes_version  = "1.32"

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

# Use kubeconfig file when set (CI); otherwise use AKS credentials from data source
# When use_kubeconfig is true, avoid evaluating data sources (cluster may not exist during destroy)
locals {
  use_kubeconfig           = var.kube_config_path != ""
  kube_host                = local.use_kubeconfig ? null : (var.deploy_aks ? data.azurerm_kubernetes_cluster.main[0].kube_config[0].host : data.azurerm_kubernetes_cluster.existing[0].kube_config[0].host)
  use_loadbalancer         = !var.backstage_ingress_enabled && var.backstage_service_loadbalancer
  backstage_service_type   = (var.backstage_ingress_enabled && var.backstage_ingress_host != "") ? "ClusterIP" : (local.use_loadbalancer ? "LoadBalancer" : "ClusterIP")
  backstage_base_url       = var.backstage_base_url_override != "" ? var.backstage_base_url_override : ((var.backstage_ingress_enabled && var.backstage_ingress_host != "") ? "https://${var.backstage_ingress_host}" : "http://localhost:7007")
  kube_client_cert = local.use_kubeconfig ? null : base64decode(var.deploy_aks ? data.azurerm_kubernetes_cluster.main[0].kube_config[0].client_certificate : data.azurerm_kubernetes_cluster.existing[0].kube_config[0].client_certificate)
  kube_client_key  = local.use_kubeconfig ? null : base64decode(var.deploy_aks ? data.azurerm_kubernetes_cluster.main[0].kube_config[0].client_key : data.azurerm_kubernetes_cluster.existing[0].kube_config[0].client_key)
  kube_ca_cert     = local.use_kubeconfig ? null : base64decode(var.deploy_aks ? data.azurerm_kubernetes_cluster.main[0].kube_config[0].cluster_ca_certificate : data.azurerm_kubernetes_cluster.existing[0].kube_config[0].cluster_ca_certificate)
}

provider "kubernetes" {
  config_path = local.use_kubeconfig ? var.kube_config_path : null
  host        = local.use_kubeconfig ? null : local.kube_host
  client_certificate = local.use_kubeconfig ? null : local.kube_client_cert
  client_key             = local.use_kubeconfig ? null : local.kube_client_key
  cluster_ca_certificate = local.use_kubeconfig ? null : local.kube_ca_cert
}

provider "helm" {
  kubernetes {
    config_path = local.use_kubeconfig ? var.kube_config_path : null
    host        = local.use_kubeconfig ? null : local.kube_host
    client_certificate = local.use_kubeconfig ? null : local.kube_client_cert
    client_key             = local.use_kubeconfig ? null : local.kube_client_key
    cluster_ca_certificate = local.use_kubeconfig ? null : local.kube_ca_cert
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
# GitHub OAuth credentials secret (when github_auth_enabled)
# ------------------------------------------------------------------------------
resource "kubernetes_secret" "github_auth" {
  count = var.github_auth_enabled && var.github_client_id != "" && var.github_client_secret != "" ? 1 : 0

  metadata {
    name      = "${var.backstage_release_name}-github-auth"
    namespace = kubernetes_namespace.backstage.metadata[0].name
  }

  data = {
    AUTH_GITHUB_CLIENT_ID     = var.github_client_id
    AUTH_GITHUB_CLIENT_SECRET = var.github_client_secret
  }

  type = "Opaque"
}

# ------------------------------------------------------------------------------
# PostgreSQL credentials secret (Bitnami chart expects user-password + admin-password)
# ------------------------------------------------------------------------------
locals {
  postgresql_password = "backstage-postgres-dev"
}

resource "kubernetes_secret" "postgresql" {
  count = var.postgresql_enabled ? 1 : 0

  metadata {
    name      = "${var.backstage_release_name}-postgresql-credentials"
    namespace = kubernetes_namespace.backstage.metadata[0].name
  }

  data = {
    "user-password"  = local.postgresql_password
    "admin-password" = local.postgresql_password
    "password"       = local.postgresql_password # Backstage app connection
  }

  type = "Opaque"
}

# ------------------------------------------------------------------------------
# Backstage Helm Release (Official Chart)
# Uses file + set for password to avoid values in state
# ------------------------------------------------------------------------------
resource "helm_release" "backstage" {
  name             = var.backstage_release_name
  namespace        = kubernetes_namespace.backstage.metadata[0].name
  repository       = "https://backstage.github.io/charts"
  chart            = "backstage"
  version          = var.backstage_chart_version
  create_namespace = false
  wait             = true
  timeout          = 600

  dynamic "set" {
    for_each = var.postgresql_enabled ? [1] : []
    content {
      name  = "postgresql.auth.existingSecret"
      value = kubernetes_secret.postgresql[0].metadata[0].name
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

  # Auth: disable default policy when GitHub auth enabled; allow guest access otherwise
  set {
    name  = "backstage.appConfig.backend.auth.dangerouslyDisableDefaultAuthPolicy"
    value = var.github_auth_enabled ? "false" : "true"
  }

  dynamic "set" {
    for_each = var.github_auth_enabled && var.github_client_id != "" && var.github_client_secret != "" ? [1] : []
    content {
      name  = "backstage.appConfig.auth.environment"
      value = "development"
    }
  }

  dynamic "set" {
    for_each = var.github_auth_enabled && var.github_client_id != "" && var.github_client_secret != "" ? [1] : []
    content {
      name  = "backstage.appConfig.auth.providers.github.development.clientId"
      value = "$${AUTH_GITHUB_CLIENT_ID}"
    }
  }

  dynamic "set" {
    for_each = var.github_auth_enabled && var.github_client_id != "" && var.github_client_secret != "" ? [1] : []
    content {
      name  = "backstage.appConfig.auth.providers.github.development.clientSecret"
      value = "$${AUTH_GITHUB_CLIENT_SECRET}"
    }
  }

  # Inject GitHub auth env vars and sign-in config from values file
  values = var.github_auth_enabled && var.github_client_id != "" && var.github_client_secret != "" ? [
    <<-EOT
    backstage:
      extraEnvVarsSecrets:
        - ${kubernetes_secret.github_auth[0].metadata[0].name}
      appConfig:
        auth:
          providers:
            github:
              development:
                signIn:
                  resolvers:
                    - resolver: usernameMatchingUserEntityName
    EOT
  ] : []

  # Backstage needs time for DB migrations and plugin loading on first startup
  set {
    name  = "backstage.readinessProbe.initialDelaySeconds"
    value = "120"
  }
  set {
    name  = "backstage.readinessProbe.periodSeconds"
    value = "15"
  }

  set {
    name  = "ingress.enabled"
    value = var.backstage_ingress_enabled
  }

  # Use LoadBalancer when ingress disabled (avoids port-forward timeouts); ClusterIP when ingress handles traffic
  set {
    name  = "service.type"
    value = local.backstage_service_type
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

  # Required: backend.baseUrl is mandatory for Backstage startup (discovery, auth)
  # Use ingress host when configured; otherwise http://localhost:7007 for port-forward access
  set {
    name  = "backstage.appConfig.app.baseUrl"
    value = local.backstage_base_url
  }

  set {
    name  = "backstage.appConfig.backend.baseUrl"
    value = local.backstage_base_url
  }
}

# ------------------------------------------------------------------------------
# LoadBalancer IP (when service type is LoadBalancer)
# ------------------------------------------------------------------------------
data "kubernetes_service" "backstage" {
  metadata {
    name      = var.backstage_release_name
    namespace = kubernetes_namespace.backstage.metadata[0].name
  }
  depends_on = [helm_release.backstage]
}
