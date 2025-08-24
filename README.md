# LumoraGrid Infra (Terraform Skeleton)

Single-subscription **POC** layout with four logical environments (**dev, test, uat, prod**). 
Cost-first defaults with easy **upgrade toggles** for hardening (Private Endpoints, Premium tiers). 
Region default: **Australia East**.

## Structure
```
lumoragrid-infra/
  modules/
    resource-group/
    network/
    storage/
    keyvault/
    servicebus/
    cosmos/
    sql/
    monitor/
    identity/
  envs/
    dev/
    test/
    uat/
    prod/
```

## Quick start (local state for POC)
```bash
cd envs/dev
terraform init
terraform plan -var-file=dev.tfvars
terraform apply -var-file=dev.tfvars
```

> ⚠️ **Remote state (recommended later):** see `backend.tf` for an example `azurerm` backend (commented). 
Provide your Storage Account, container, and key per environment when you’re ready.

## Design
- **Public endpoints + IP allow-lists** by default (POC cost-friendly).
- Feature flags:
  - `enable_private_endpoints` – create Private Endpoints (needs a PE subnet in `network` module).
  - `enable_diagnostics` – send resource diagnostics/metrics to Log Analytics.
  - `sb_tier` – `Basic|Standard|Premium` (start with **Standard** for POC).
  - `cosmos_serverless` – `true` for Serverless (DEV/TEST), `false` to prep for autoscale later.
  - `sql_sku_name` – use `S0/S1/S2` or vCore (`GP_S_Gen5_2`, etc.).
- One **Log Analytics workspace per env**; multiple Application Insights can link to it.

## Secrets & IDs
- Provide `tenant_id`, optional AAD `object_id` for role assignments (in `identity` module).
- For SQL, pass `administrator_login` & `administrator_login_password` via pipeline variables/env vars. 
Never commit secrets.

## Upgrade-to-production checklist
- Switch `sb_tier = "Premium"` (UAT/PROD), set `enable_private_endpoints = true`, disable public access.
- Add **Failover Group** for SQL and **multi-region** for Cosmos (and continuous backup).
- Tighten Azure Policies (deny public networks) and move to **remote state**.


---
## Azure DevOps pipeline
A ready **azure-pipelines.yml** is included (multi-stage: dev → test → uat → prod).

### Prereqs
1) **Service connection** (Azure Resource Manager) named in a pipeline variable `AZURE_SERVICE_CONNECTION`.
   - Use **Workload Identity Federation** (OIDC) if possible.
2) **Remote state** Storage Account + Container + RG per subscription.
   - Set pipeline variables (or a Variable Group) for:
     - `TFSTATE_RG`, `TFSTATE_ACCOUNT`, `TFSTATE_CONTAINER`
3) **Environments** in ADO named `test`, `uat`, `prod` with **approval checks** configured.
4) **Secrets**: put `sql_admin_password` in a variable group and pass it at runtime with `-var "sql_admin_password=$(SQL_ADMIN_PASSWORD)"` if you prefer not to commit it to tfvars.

### Local vs Pipeline
- Local runs use `*.tfvars` from `envs/<env>`.
- Pipeline uses the same tfvars but injects remote state via `terraform init -backend-config=...`.

### Notes
- You can replace the install step with the **TerraformInstaller@1** task if your org has the extension:
  ```yaml
  - task: TerraformInstaller@1
    inputs:
      terraformVersion: '1.7.5'
  ```
