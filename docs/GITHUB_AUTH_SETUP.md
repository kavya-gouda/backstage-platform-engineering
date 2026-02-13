# GitHub OAuth Setup for Backstage

Follow these steps to enable GitHub sign-in for Backstage.

## Step 1: Create a GitHub OAuth App

1. Go to [GitHub Developer Settings](https://github.com/settings/developers) → **OAuth Apps** → **New OAuth App**
2. Fill in:
   - **Application name**: `Backstage` (or your app name)
   - **Homepage URL**: Your Backstage URL, e.g.:
     - LoadBalancer: `http://<EXTERNAL-IP>:7007` (get IP from `kubectl get svc -n backstage`)
     - Ingress: `https://backstage.yourdomain.com`
     - Local: `http://localhost:7007`
   - **Authorization callback URL**: `{Homepage URL}/api/auth/github/handler/frame`
     - Example (LoadBalancer): `http://20.123.45.67:7007/api/auth/github/handler/frame`
     - Example (Ingress): `https://backstage.yourdomain.com/api/auth/github/handler/frame`
3. Click **Register application**
4. Generate a **Client secret** and save both **Client ID** and **Client secret**

## Step 2: Add GitHub Secrets (for GitHub Actions)

Go to your repo: **Settings** → **Secrets and variables** → **Actions** → **New repository secret**

| Secret | Value |
|--------|-------|
| `BACKSTAGE_OAUTH_CLIENT_ID` | Your GitHub OAuth App Client ID |
| `BACKSTAGE_OAUTH_CLIENT_SECRET` | Your GitHub OAuth App Client Secret |

## Step 3: Deploy via GitHub Actions

1. Go to **Actions** → **Deploy Backstage to AKS** → **Run workflow**
2. Run once (without GitHub auth) to create the cluster
3. After deploy, get the nip.io URL from the output, e.g. `http://backstage.20.123.45.67.nip.io:7007`
4. Create GitHub OAuth App at [github.com/settings/developers](https://github.com/settings/developers):
   - **Homepage URL**: `http://backstage.<YOUR-IP>.nip.io:7007`
   - **Authorization callback URL**: `http://backstage.<YOUR-IP>.nip.io:7007/api/auth/github/handler/frame`
5. Add `BACKSTAGE_OAUTH_CLIENT_ID` and `BACKSTAGE_OAUTH_CLIENT_SECRET` to repo secrets (Step 2)
6. Re-run deploy with **Enable GitHub OAuth sign-in** checked

## Alternative: Local Terraform

Set the variables (via `terraform.tfvars` or environment):

```hcl
github_auth_enabled   = true
github_client_id     = "your-client-id"
github_client_secret = "your-client-secret"
```

Or use env vars (don't commit secrets):

```bash
export TF_VAR_github_client_id="your-client-id"
export TF_VAR_github_client_secret="your-client-secret"
terraform apply -var="github_auth_enabled=true"
```

**Important:** When using LoadBalancer with a dynamic IP, set:

```hcl
backstage_base_url_override = "http://<EXTERNAL-IP>:7007"
```

Replace `<EXTERNAL-IP>` with the output of `kubectl get svc -n backstage` (or `terraform output backstage_loadbalancer_ip`). The callback URL in the GitHub OAuth App must match this exactly.

## Step 5: Apply and Restart (local Terraform only)

```bash
cd terraform
terraform apply -auto-approve
kubectl rollout restart deployment/backstage -n backstage
```

## Step 6: Sign In

Open Backstage and click **Sign in** → **GitHub**. Complete the OAuth flow.

## PostgreSQL secret fix

If you see `The secret "backstage-postgresql" does not contain the key "user-password"`, delete the old secret and re-apply:

```bash
kubectl delete secret backstage-postgresql -n backstage --ignore-not-found
```

Then re-run the deploy workflow or `terraform apply`.

## Troubleshooting

| Issue | Solution |
|-------|----------|
| "Redirect URI mismatch" | Ensure the callback URL in GitHub OAuth App exactly matches `{baseUrl}/api/auth/github/handler/frame` |
| "User not found" | Add a User entity to the catalog with `spec.profile.displayName` and match GitHub username, or use `emailLocalPartMatchingUserEntityName` resolver |
| 401 on catalog | GitHub auth requires proper resolver; ensure users exist in the catalog or adjust resolver in auth config |

## Security

- Never commit `github_client_secret` to version control
- Use `TF_VAR_github_client_secret` or a secret manager in CI
- Rotate the client secret periodically in GitHub
