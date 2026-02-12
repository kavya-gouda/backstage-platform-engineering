#!/usr/bin/env bash
# Destroy Backstage and optionally AKS
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TERRAFORM_DIR="${SCRIPT_DIR}/../terraform"

cd "$TERRAFORM_DIR"

echo "=== Initializing Terraform ==="
terraform init

echo "=== Destroying Backstage deployment and infrastructure ==="
terraform destroy

echo "=== Destroy complete ==="
