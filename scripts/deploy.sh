#!/usr/bin/env bash
# Deploy Backstage to AKS using Terraform
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TERRAFORM_DIR="${SCRIPT_DIR}/../terraform"

cd "$TERRAFORM_DIR"

echo "=== Initializing Terraform ==="
terraform init

echo "=== Planning deployment ==="
terraform plan -out=tfplan

echo "=== Applying deployment ==="
terraform apply tfplan

echo ""
echo "=== Deployment complete ==="
terraform output
