# PostgreSQL & Backstage Architecture Guide

## Overview

PostgreSQL is the **persistent data layer** for Backstage plugins. Each backend plugin that needs to store data uses PostgreSQL through Backstage's database abstraction layer.

## Connection Flow


```
┌─────────────────┐
│  Frontend (UI)  │  React app on port 3000
│  localhost:3000 │
└────────┬────────┘
         │ HTTP/REST API calls
         ↓
┌─────────────────┐
│  Backend API    │  Express server on port 7007
│  localhost:7007 │
└────────┬────────┘
         │
         │ Each plugin uses database manager
         ↓
┌─────────────────────────────────────┐
│  Backstage Database Manager         │
│  (@backstage/backend-defaults)      │
│                                     │
│  - Connection pooling               │
│  - Transaction management           │
│  - Migration runner (Knex.js)       │
└────────┬────────────────────────────┘
         │
         │ Uses 'pg' npm package
         ↓
┌─────────────────────────────────────┐
│  PostgreSQL Database                │
│  backstage-pg-kavya.postgres...     │
│                                     │
│  Database: backstage_plugin_catalog │
└─────────────────────────────────────┘
```
## How Configuration Works

### In app-config.yaml:

```yaml
backend:
  database:
    client: pg                                    # Use PostgreSQL driver
    connection:
      host: backstage-pg-kavya.postgres...       # Azure PostgreSQL server
      port: 5432
      user: kavya
      password: password123
      database: backstage_plugin_catalog         # Database name
      ssl:
        rejectUnauthorized: false                # Azure requires SSL
```
### What happens at startup:

1. **Backend initialization** (`packages/backend/src/index.ts`)
   - `createBackend()` reads app-config.yaml
   - Initializes database manager with connection config

2. **Plugin registration**
   - Each plugin is added: `backend.add(import('@backstage/plugin-catalog-backend'))`
   - Plugins that need database access request a connection

3. **Database migrations**
   - Backstage automatically runs migrations for each plugin
   - Creates tables if they don't exist
   - Updates schema if needed
4. **Backend starts** (`backend.start()`)
   - All plugins are running
   - Database connection pool is active
   - Ready to accept requests

## Plugins That Use PostgreSQL

### 1. **Catalog Plugin** (`@backstage/plugin-catalog-backend`)
**Purpose**: Store software catalog entities (services, APIs, components, users, groups)

**Tables Created**:
- `final_entities` - All catalog entities (services, components, APIs, etc.)
- `refresh_state` - Entity refresh/sync status
- `relations` - Entity relationships (owns, dependsOn, etc.)
- `search` - Full-text search index

**Example Data**:
```sql
-- A service entity in the catalog
INSERT INTO final_entities VALUES (
  'component:default/my-service',
  '{"apiVersion": "backstage.io/v1alpha1", "kind": "Component", ...}'
);
```
### 2. **Search Plugin** (`@backstage/plugin-search-backend-module-pg`)
**Purpose**: Full-text search across catalog and documentation

**Tables Created**:
- `documents` - Searchable content from all sources
- `documents_search` - PostgreSQL full-text search indexes

**Why PostgreSQL?**: 
- Uses PostgreSQL's native full-text search (tsvector, tsquery)
- Faster than external search engines for small/medium deployments

### 3. **Scaffolder Plugin** (`@backstage/plugin-scaffolder-backend`)
**Purpose**: Template execution history and task logs

**Tables Created**:
- `tasks` - Template execution records
- `task_events` - Step-by-step execution logs

**Example Use Case**:
When you create a new project from a template, the scaffolder stores:
- Template name used
- Input parameters
- Execution status (pending, processing, completed, failed)
- Output (created repository URL, etc.)

### 4. **Auth Plugin** (`@backstage/plugin-auth-backend`)
**Purpose**: User sessions and authentication tokens

**Tables Created**:
- `sessions` - User login sessions
- `refresh_tokens` - OAuth refresh tokens (if using OAuth providers)

### 5. **TechDocs Plugin** (`@backstage/plugin-techdocs-backend`)
**Purpose**: Documentation metadata

**Tables Created**:
- `techdocs_metadata` - Doc site metadata (last updated, generator info)

**Note**: Actual documentation HTML/assets stored separately (local filesystem or cloud storage)

## Database Connection Details

### Connection Pooling
Backstage uses connection pooling (via Knex.js):
- **Default pool size**: 5-20 connections
- Connections are reused across requests
- Automatic reconnection on connection loss

### Migrations
Backstage uses **Knex.js** for database migrations:
```bash
# Migrations are in each plugin's package
node_modules/@backstage/plugin-catalog-backend/migrations/
```

Migrations run automatically on backend startup:
- Creates tables if missing
- Applies schema changes
- Idempotent (safe to run multiple times)

### Transaction Support
Plugins can use transactions for data consistency:
```typescript
await database.transaction(async (tx) => {
  await tx('entities').insert(...);
  await tx('relations').insert(...);
  // All or nothing - rollback on error
});
```


