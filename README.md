# Backstage Platform Engineering - AKS Deployment

Automation to deploy [Backstage](https://backstage.io/) to an Azure Kubernetes Service (AKS) cluster and enable it for internal developer use. Deploy and destroy via **GitHub Actions**.

## Architecture

![Architecture diagram](assets/architecture-diagram.png)

| Component | Technology |
|-----------|------------|
| Infrastructure | Terraform |
| Container Orchestration | AKS (Azure Kubernetes Service) |
| Backstage Deployment | Helm (official [Backstage chart](https://github.com/backstage/charts)) |
| Database | PostgreSQL (Bitnami, embedded via Helm subchart) |
| CI/CD | GitHub Actions |

## Prerequisites

- **Azure subscription** with permissions to create resource groups, AKS, and related resources
- **GitHub repository** with this code

## Setup

> **Full guide:** [.github/GITHUB_ACTIONS_SETUP.md](.github/GITHUB_ACTIONS_SETUP.md)

1. **Terraform remote state** – Create Azure Storage for state (required for CI)
2. **Azure OIDC** – Create service principal and federated credential
3. **GitHub secrets** – Add `AZURE_CLIENT_ID`, `AZURE_TENANT_ID`, `AZURE_SUBSCRIPTION_ID`, and optionally `POSTGRESQL_PASSWORD`, `BACKSTAGE_OAUTH_CLIENT_ID`, `BACKSTAGE_OAUTH_CLIENT_SECRET` (for GitHub sign-in)

## Deploy

1. Go to **Actions → Deploy Backstage to AKS**
2. Click **Run workflow**
3. Fill in inputs (or use defaults)
4. Run

### Workflow inputs

| Input | Default | Description |
|-------|---------|-------------|
| `resource_group` | `rg-backstage-platform` | Azure resource group name |
| `deploy_aks` | `true` | Create new AKS or use existing cluster |
| `location` | `eastus` | Azure region |
| `backstage_ingress_host` | - | Hostname for external access (e.g., backstage.example.com) |
| `github_auth_enabled` | `false` | Enable GitHub OAuth sign-in |
| `github_client_id` | - | GitHub OAuth App Client ID |
| `github_client_secret` | - | GitHub OAuth App Client Secret (use secret) |

> **GitHub auth setup:** See [docs/GITHUB_AUTH_SETUP.md](docs/GITHUB_AUTH_SETUP.md) for OAuth App creation and callback URL configuration.

## Destroy

1. Go to **Actions → Destroy Backstage**
2. Click **Run workflow**
3. Enter the same `resource_group` and options used for deploy
4. Type **DESTROY** in `confirm_destroy`
5. Run

## Access Backstage

After deploy, get cluster credentials:

```bash
az aks get-credentials --resource-group rg-backstage-platform --name backstage-aks
```

**Option A – LoadBalancer** (default when ingress is disabled):

```bash
kubectl get svc -n backstage -w   # Wait for EXTERNAL-IP, then open http://<EXTERNAL-IP>:7007
```

**Option B – Port-forward** (when using ClusterIP):

```bash
kubectl port-forward -n backstage svc/backstage 7007:7007
# Open http://localhost:7007
```

## Project Structure

```
backstage-platform-engineering/
├── .github/
│   ├── GITHUB_ACTIONS_SETUP.md   # Setup guide
│   └── workflows/
│       ├── deploy.yml            # Deploy Backstage to AKS
│       └── destroy.yml           # Destroy infrastructure
├── terraform/
│   ├── main.tf                   # AKS + Backstage Helm
│   ├── variables.tf              # Input variables
│   ├── outputs.tf                # Output values
│   └── versions.tf               # Provider versions
├── helm/
│   └── values.yaml               # Helm values (reference)
└── README.md
```

## References

- [Backstage Documentation](https://backstage.io/docs)
- [Backstage Helm Chart](https://github.com/backstage/charts)
- [Backstage K8s Deployment](https://backstage.io/docs/deployment/k8s)
- [Terraform Azure Provider](https://registry.terraform.io/providers/hashicorp/azurerm)
