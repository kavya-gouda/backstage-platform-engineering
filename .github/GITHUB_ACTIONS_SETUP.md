# GitHub Actions Setup Guide

This guide walks you through setting up GitHub Actions to deploy Backstage to AKS. The repository includes two workflows:

| Workflow | Purpose |
|----------|---------|
| **Deploy Backstage to AKS** | Creates/updates AKS cluster and deploys Backstage |
| **Destroy Backstage** | Tears down infrastructure (manual confirmation required) |

---

## Prerequisites

- **Azure subscription** with permissions to create resource groups, AKS, storage accounts, and related resources
- **GitHub repository** with this code pushed (e.g., `your-org/backstage-platform-engineering`)

---

## Step 1: Configure Terraform Remote State (Required for CI/CD)

GitHub Actions runners are ephemeral—local Terraform state is lost after each run. You **must** use a remote backend for state to persist between deployments.

### 1a. Create Azure Storage for Terraform State

Run these commands once (Azure CLI required):

```bash
# Set variables
RESOURCE_GROUP="rg-tfstate-backstage"
STORAGE_ACCOUNT="tfstatebackstage"  # Must be globally unique, lowercase, alphanumeric only
CONTAINER="tfstate"
LOCATION="eastus"

# Create resource group and storage account
az group create --name $RESOURCE_GROUP --location $LOCATION
az storage account create \
  --resource-group $RESOURCE_GROUP \
  --name $STORAGE_ACCOUNT \
  --sku Standard_LRS \
  --encryption-services blob

# Create container
az storage container create --name $CONTAINER --account-name $STORAGE_ACCOUNT
```

### 1b. Enable Terraform Backend

Edit `terraform/versions.tf` and uncomment the backend block. Update values to match your storage:

```hcl
backend "azurerm" {
  resource_group_name  = "rg-tfstate-backstage"
  storage_account_name = "tfstatebackstage"
  container_name       = "tfstate"
  key                  = "backstage-platform.terraform.tfstate"
}
```

---

## Step 2: Create Azure Service Principal for OIDC

Use **OpenID Connect (OIDC)**—no long-lived secrets; GitHub exchanges a short-lived token with Azure.

### 2a. Create Microsoft Entra (Azure AD) App Registration

**Via Azure Portal:**
1. Go to [Azure Portal](https://portal.azure.com) → **Microsoft Entra ID** → **App registrations** → **New registration**
2. Name: `github-actions-backstage`
3. Click **Register**
4. Copy **Application (client) ID** and **Directory (tenant) ID**

**Via Azure CLI:**
```bash
APP_NAME="github-actions-backstage"
APP=$(az ad app create --display-name $APP_NAME --output json)
CLIENT_ID=$(echo $APP | jq -r .appId)
echo "Client ID: $CLIENT_ID"
echo "Tenant ID: $(az account show --query tenantId -o tsv)"
echo "Subscription ID: $(az account show --query id -o tsv)"
```

### 2b. Create Service Principal and Assign Roles

```bash
# Create service principal
az ad sp create --id $CLIENT_ID

# Assign Contributor role on subscription (or scope to specific resource group)
SUBSCRIPTION_ID=$(az account show --query id -o tsv)
az role assignment create \
  --assignee $CLIENT_ID \
  --role "Contributor" \
  --scope "/subscriptions/$SUBSCRIPTION_ID"
```

### 2c. Add Federated Credential (OIDC Trust)

Replace placeholders with your values:

```bash
# Your GitHub org/repo
GITHUB_ORG="your-org"        # or your username
GITHUB_REPO="backstage-platform-engineering"

az ad app federated-credential create \
  --id $CLIENT_ID \
  --name "github-actions" \
  --issuer "https://token.actions.githubusercontent.com" \
  --subject "repo:${GITHUB_ORG}/${GITHUB_REPO}:ref:refs/heads/main" \
  --audiences "api://AzureADTokenExchange"
```

For multiple branches or environment-specific deployments, add more federated credentials with different `--subject` values (e.g., `repo:org/repo:environment:production`).

---

## Step 3: Add GitHub Secrets

Go to your repo: **Settings** → **Secrets and variables** → **Actions** → **New repository secret**

| Secret | Required | Description |
|--------|----------|-------------|
| `AZURE_CLIENT_ID` | ✅ Yes | Application (client) ID from Step 2 |
| `AZURE_TENANT_ID` | ✅ Yes | Directory (tenant) ID |
| `AZURE_SUBSCRIPTION_ID` | ✅ Yes | Azure subscription ID |
| `POSTGRESQL_PASSWORD` | No | PostgreSQL password (leave empty for auto-generated; stored in state) |

---

## Step 4: Run the Deploy Workflow

1. Go to **Actions** → **Deploy Backstage to AKS**
2. Click **Run workflow**
3. Fill in inputs (or use defaults):

| Input | Default | Description |
|-------|---------|-------------|
| `resource_group` | `rg-backstage-platform` | Azure resource group name |
| `deploy_aks` | `true` | `true` = create new AKS; `false` = use existing cluster |
| `existing_aks_name` | - | Required when `deploy_aks=false` |
| `existing_aks_rg` | - | Required when `deploy_aks=false` |
| `location` | `eastus` | Azure region |
| `backstage_ingress_host` | - | e.g., `backstage.yourdomain.com` for external access |

4. Click **Run workflow**
5. Monitor the run; when it completes, Backstage is deployed.

### Access Backstage

```bash
az aks get-credentials --resource-group rg-backstage-platform --name backstage-aks
kubectl port-forward -n backstage svc/backstage 7007:7007
```

Open http://localhost:7007

---

## Step 5: (Optional) Run the Destroy Workflow

To tear down all resources:

1. **Actions** → **Destroy Backstage** → **Run workflow**
2. Enter the **same** `resource_group`, `deploy_aks`, `existing_aks_name`, `existing_aks_rg` used during deploy
3. Type **DESTROY** exactly in `confirm_destroy`
4. Run

---

## Alternative: Service Principal with Client Secret

If OIDC is not an option, you can use a client secret:

1. In Azure Portal → App registration → **Certificates & secrets** → **New client secret**
2. Copy the secret value
3. Add `AZURE_CLIENT_SECRET` to GitHub Secrets
4. Update the workflow's Azure Login step to use `client-secret` instead of OIDC (see workflow comments)

**Note:** Client secrets expire and require rotation. OIDC is recommended for production.

---

## Troubleshooting

| Issue | Solution |
|-------|----------|
| "Failed to get OIDC token" | Ensure `id-token: write` permission is in the workflow. Verify federated credential subject matches `repo:org/repo:ref:refs/heads/main` |
| "Backend initialization required" | Configure remote backend in `terraform/versions.tf` (Step 1) |
| "Error acquiring state lock" | Another run may be in progress. Wait or force-unlock via Terraform CLI |
| Terraform plan shows unexpected changes | Ensure backend state is from the same deployment; check `resource_group` and other inputs match previous runs |

---

## References

- [Azure OIDC with GitHub Actions](https://learn.microsoft.com/en-us/azure/developer/github/connect-from-azure-openid-connect)
- [Terraform Azure Backend](https://www.terraform.io/docs/language/settings/backends/azurerm.html)
