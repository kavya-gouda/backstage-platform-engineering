# Backstage App Setup (Option A - Same Repo)

This project builds and deploys a custom Backstage app with TechDocs, Software Templates, Catalog, and GitHub auth—all via GitHub Actions (no local build required).

## Flow

1. **Bootstrap** (run once) → Creates `backstage-app/` via `create-app` in CI
2. **Build** → Builds Docker image, pushes to GHCR (`ghcr.io/<org>/<repo>:latest`)
3. **Deploy** → Deploys to AKS using the built image

## Step 1: Bootstrap Backstage App

1. Go to **Actions** → **Bootstrap Backstage App**
2. Click **Run workflow**
3. Wait for it to complete—it will create `backstage-app/` and push to your repo

This runs `npx @backstage/create-app` in GitHub's runner (avoids local yarn/network issues). The app includes:

- **TechDocs** – documentation creation and viewing
- **Software Templates** – template-based project creation
- **Catalog** – component and API tracking
- **GitHub auth** – sign-in with GitHub OAuth

## Step 2: Build Image

After bootstrap:

1. **Actions** → **Build Backstage Image** → **Run workflow**
2. Or push changes to `backstage-app/` on `main`—build runs automatically

The image is pushed to `ghcr.io/<your-org>/<repo-name>:latest`. The workflow attempts to set the package visibility to **public** so AKS can pull without imagePullSecrets. If the API step fails, set it manually under **Packages** in your GitHub profile/org.

## Step 3: Deploy to AKS

1. **Actions** → **Deploy Backstage to AKS**
2. Check **Enable GitHub OAuth sign-in** if using GitHub auth
3. Leave **Custom Backstage image registry** and **repository** empty (defaults to GHCR)
4. Run workflow

The deploy uses the image from Step 2.

## Adding Plugins

1. Edit `backstage-app/` (e.g. add plugins in `packages/app`, `packages/backend`)
2. Commit and push to `main`
3. Build runs automatically
4. Run Deploy to update the cluster

## GHCR Package Visibility

The build workflow sets the package to **public** automatically so AKS can pull without credentials. If that fails, manually go to **Packages** → select the package → **Package settings** → **Change visibility** → **Public**.

## File Structure After Bootstrap

```
backstage-app/
├── packages/
│   ├── app/          # Frontend
│   └── backend/      # Backend (includes auth, TechDocs, Scaffolder)
├── plugins/
├── app-config.yaml
├── app-config.production.yaml
└── ...
```
