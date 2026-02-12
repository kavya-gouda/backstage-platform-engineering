# Backstage Platform Engineering - AKS Deployment

Automation to deploy [Backstage](https://backstage.io/) to an Azure Kubernetes Service (AKS) cluster and enable it for internal developer use. Supports both **deploy** and **destroy** operations on demand.

## Architecture

| Component | Technology |
|-----------|------------|
| Infrastructure | Terraform |
| Container Orchestration | AKS (Azure Kubernetes Service) |
| Backstage Deployment | Helm (official [Backstage chart](https://github.com/backstage/charts)) |
| Database | PostgreSQL (Bitnami, embedded via Helm subchart) |
| CI/CD | GitHub Actions |

## Prerequisites

- **Azure subscription** with permissions to create resource groups, AKS, and related resources
- **Terraform** >= 1.5 (for local runs)
- **Azure CLI** (for local runs and `az aks get-credentials`)
- **kubectl** (for verifying deployment)
- **Helm** 3.10+ (optional; Terraform Helm provider handles charts)

## Quick Start

### Option 1: Local Deployment (Terraform + Scripts)

1. **Clone and navigate**
   ```bash
   cd backstage-platform-engineering
   ```

2. **Configure variables**
   ```bash
   cp terraform/terraform.tfvars.example terraform/terraform.tfvars
   # Edit terraform.tfvars with your values
   ```

3. **Set PostgreSQL password** (recommended for production)
   ```bash
   export TF_VAR_postgresql_password="your-secure-password"
   ```
   Leave unset for auto-generated password (stored in Terraform state).

4. **Deploy**
   ```bash
   # Bash
   ./scripts/deploy.sh

   # PowerShell (Windows)
   .\scripts\deploy.ps1
   ```

5. **Access Backstage**
   ```bash
   az aks get-credentials --resource-group <rg-name> --name <cluster-name>
   kubectl port-forward -n backstage svc/backstage 7007:7007
   ```
   Open http://localhost:7007

### Option 2: Destroy (Local)

```bash
./scripts/destroy.sh   # Bash
.\scripts\destroy.ps1  # PowerShell
```

## GitHub Actions CI/CD

### Setup Required Secrets

In your GitHub repo: **Settings → Secrets and variables → Actions**, add:

| Secret | Description |
|--------|-------------|
| `AZURE_CLIENT_ID` | Azure AD App (Service Principal) Client ID for OIDC |
| `AZURE_TENANT_ID` | Azure AD Tenant ID |
| `AZURE_SUBSCRIPTION_ID` | Azure Subscription ID |
| `POSTGRESQL_PASSWORD` | PostgreSQL password (optional; leave empty for auto-generated) |

**OIDC (recommended):** Configure [Azure OIDC with GitHub Actions](https://learn.microsoft.com/en-us/azure/developer/github/connect-from-azure).

**Service Principal (alternative):** Add `AZURE_CLIENT_SECRET` and use `azure/login` with `client-secret` instead of OIDC.

### Deploy Workflow

1. Go to **Actions → Deploy Backstage to AKS**
2. Click **Run workflow**
3. Fill in inputs (or use defaults)
4. Run

### Destroy Workflow

1. Go to **Actions → Destroy Backstage**
2. Click **Run workflow**
3. Enter the same `resource_group` and options used for deploy
4. Type **DESTROY** in `confirm_destroy`
5. Run

## Configuration

### Terraform Variables

| Variable | Default | Description |
|----------|---------|-------------|
| `deploy_aks` | `true` | Create new AKS vs use existing cluster |
| `resource_group_name` | required | Azure resource group |
| `location` | `eastus` | Azure region |
| `aks_cluster_name` | `backstage-aks` | AKS cluster name |
| `existing_aks_name` | - | Name of existing AKS (when `deploy_aks=false`) |
| `existing_aks_rg` | - | RG of existing AKS (when `deploy_aks=false`) |
| `backstage_namespace` | `backstage` | Kubernetes namespace |
| `backstage_ingress_enabled` | `false` | Enable Ingress for external access |
| `backstage_ingress_host` | - | Hostname (e.g., backstage.yourdomain.com) |
| `postgresql_enabled` | `true` | Use embedded PostgreSQL |

### Enabling Ingress (Developer Access)

For external access, you need:

1. **NGINX Ingress Controller** in the cluster
2. **DNS** pointing to the load balancer
3. **Optional:** cert-manager for TLS

Set in `terraform.tfvars`:
```hcl
backstage_ingress_enabled = true
backstage_ingress_host    = "backstage.yourdomain.com"
```

## Publishing to Your Repo

To use this in your own GitHub repo (e.g. `kavya-gouda/backstage-platform-engineering`):

1. **Initialize Git** (if not already)
   ```bash
   git init
   git add .
   git commit -m "Initial Backstage AKS deployment automation"
   ```

2. **Add remote and push**
   ```bash
   git remote add origin https://github.com/kavya-gouda/backstage-platform-engineering.git
   git branch -M main
   git push -u origin main
   ```

3. **Configure GitHub Actions** secrets as described above

4. **Run the deploy workflow** from the Actions tab

## Project Structure

```
backstage-platform-engineering/
├── .github/
│   └── workflows/
│       ├── deploy.yml      # Deploy Backstage to AKS
│       └── destroy.yml     # Destroy infrastructure
├── terraform/
│   ├── main.tf             # AKS + Backstage Helm
│   ├── variables.tf        # Input variables
│   ├── outputs.tf          # Output values
│   ├── versions.tf         # Provider versions
│   └── terraform.tfvars.example
├── helm/
│   └── values.yaml         # Helm values (reference)
├── scripts/
│   ├── deploy.sh           # Bash deploy script
│   ├── deploy.ps1          # PowerShell deploy script
│   ├── destroy.sh
│   └── destroy.ps1
└── README.md
```

## References

- [Backstage Documentation](https://backstage.io/docs)
- [Backstage Helm Chart](https://github.com/backstage/charts)
- [Backstage K8s Deployment](https://backstage.io/docs/deployment/k8s)
- [Terraform Azure Provider](https://registry.terraform.io/providers/hashicorp/azurerm)
