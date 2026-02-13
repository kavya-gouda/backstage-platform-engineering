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

output "backstage_loadbalancer_ip" {
  description = "LoadBalancer external IP (when service type is LoadBalancer)"
  value       = local.use_loadbalancer ? try(
    data.kubernetes_service.backstage.status[0].load_balancer[0].ingress[0].ip,
    data.kubernetes_service.backstage.status[0].load_balancer[0].ingress[0].hostname,
    "pending"
  ) : null
}

output "backstage_access_command" {
  description = "Access Backstage: LoadBalancer (get EXTERNAL-IP) or port-forward (ClusterIP)"
  value       = local.use_loadbalancer ? "kubectl get svc -n ${var.backstage_namespace} -w  # wait for EXTERNAL-IP, then open http://<EXTERNAL-IP>:7007" : "kubectl port-forward -n ${var.backstage_namespace} svc/${var.backstage_release_name} 7007:7007"
}

output "backstage_url" {
  description = "Backstage URL (nip.io when LoadBalancer)"
  value       = var.backstage_ingress_enabled && var.backstage_ingress_host != "" ? "https://${var.backstage_ingress_host}" : (local.use_loadbalancer ? "http://backstage.${try(data.kubernetes_service.backstage.status[0].load_balancer[0].ingress[0].ip, data.kubernetes_service.backstage.status[0].load_balancer[0].ingress[0].hostname, "IP_PENDING")}.nip.io:7007" : "http://localhost:7007 (run port-forward)")
}
