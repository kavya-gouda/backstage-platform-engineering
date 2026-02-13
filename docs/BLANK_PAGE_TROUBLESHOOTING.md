# Blank Page Troubleshooting

If Backstage loads but shows a blank white page, the backend may be returning an empty response for `GET /`. Common causes and fixes:

## Symptom

- Health checks pass (`/.backstage/health/v1/readiness` returns 200)
- `GET /` returns 200 but with **0 bytes** content (empty body)
- Browser shows a blank white page

## Fixes

### 1. Verify baseUrl and backend.listen

The workflow should set `app.baseUrl` and `backend.baseUrl` to your nip.io URL. Ensure the "Update baseUrl for LoadBalancer (nip.io)" step completed successfully. If it failed (e.g. LoadBalancer IP not ready), re-run the deploy.

### 2. Restart Backstage after baseUrl change

If baseUrl was updated after the initial deploy, restart the pods so they pick up the new config:

```bash
kubectl rollout restart deployment/backstage -n backstage
```

### 3. Use a custom Backstage image (recommended)

The default `ghcr.io/backstage/backstage:latest` image may not include the frontend bundle in all cases. For reliable deployment, **build your own image** from a Backstage app created with `@backstage/create-app`:

1. Create a new Backstage app:
   ```bash
   npx @backstage/create-app@latest
   ```

2. Build the Docker image (includes both frontend and backend):
   ```bash
   cd my-backstage-app
   yarn install
   yarn tsc
   yarn build:backend
   docker build . -f packages/backend/Dockerfile -t myregistry.azurecr.io/backstage:latest
   ```

3. Push to your registry and set the image in Terraform:
   ```hcl
   # In terraform.tfvars or via -var
   backstage_image_tag = "latest"  # Use your tag
   # Override image via Helm set if your registry differs
   ```

   Or pass a custom image to the Helm chart via Terraform `set`:
   ```hcl
   set {
     name  = "backstage.image.registry"
     value = "myregistry.azurecr.io"
   }
   set {
     name  = "backstage.image.repository"
     value = "backstage"
   }
   set {
     name  = "backstage.image.tag"
     value = "latest"
   }
   ```

### 4. Check backend logs

```bash
kubectl logs -n backstage deployment/backstage -f
```

Look for errors when serving `GET /`. If you see "Cannot find module" or similar, the image may be missing the frontend bundle.

### 5. Verify config in the running pod

```bash
kubectl exec -n backstage deployment/backstage -- cat /app/app-config.yaml
```

Ensure `app.baseUrl` and `backend.baseUrl` match your access URL (e.g. `http://backstage.<IP>.nip.io:7007`).
