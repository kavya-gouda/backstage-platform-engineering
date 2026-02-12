output "resource_group_name" {
  description = "Resource group name"
  value       = var.deploy_aks ? azurerm_resource_group.main[0].name : var.existing_aks_rg
}

output "aks_cluster_name" {
  description = "AKS cluster name"
  value       = var.deploy_aks ? azurerm_kubernetes_cluster.main[0].name : var.existing_aks_name
}

output "aks_kube_config_command" {
  description = "Command to get kubeconfig for the cluster"
  value       = "az aks get-credentials --resource-group ${var.deploy_aks ? azurerm_resource_group.main[0].name : var.existing_aks_rg} --name ${var.deploy_aks ? azurerm_kubernetes_cluster.main[0].name : var.existing_aks_name}"
}

output "backstage_namespace" {
  description = "Backstage namespace"
  value       = var.backstage_namespace
}

output "backstage_access_command" {
  description = "Command to port-forward and access Backstage locally"
  value       = "kubectl port-forward -n ${var.backstage_namespace} svc/${var.backstage_release_name} 7007:7007"
}

output "backstage_url" {
  description = "Backstage URL (ingress or port-forward)"
  value       = var.backstage_ingress_enabled && var.backstage_ingress_host != "" ? "https://${var.backstage_ingress_host}" : "http://localhost:7007 (run port-forward command above)"
}
