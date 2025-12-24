
# Azure Lakehouse (POC) — Terraform

This Terraform project provisions core resources for a Lakehouse on Azure in **East US** using your provided names. It sets up:

- Resource Group, VNet (10.1.0.0/16), 4 Subnets (dev, private, public, private-endpoints)
- NSGs (4) and a Route Table
- IP Group
- Log Analytics & Workspace-based Application Insights
- Key Vault (with RBAC) + Managed Identity
- Azure AD Application and Service Principal (client secret stored in Key Vault)
- ADLS Gen2 Storage account + containers **bronze**, **silver**, **gold**
- Private DNS Zones + Links for Storage, Key Vault, SQL, Databricks
- Private Endpoints for ADLS (DFS), Key Vault, SQL Server (existing), Databricks
- Databricks Workspace (Premium) with VNet injection into private/public subnets + Managed Resource Group
- Public IP, Container Registry, Backup Vault

> **Notes / Placeholders to review before `apply`:**
>
> 1. **Hub VNet Peering:** Provide `var.hub_vnet_id` of existing Hub (`vnet-hub-cus-001`).
> 2. **SQL Server:** Provide `var.sql_server_id` of the existing SQL Server (for Private Endpoint).
> 3. **Databricks PrivateLink subresources:** Confirm subresource names for Azure Databricks PrivateLink in your region (often `browser` and/or `databricks_ui_api`).
> 4. **Route Table:** Add specific routes/NVA next-hop as per your Hub/Spoke design.
> 5. **Key Vault RBAC:** This config enables RBAC and adds policies for the SP and MI. Adjust as needed.
> 6. **Unity Catalog Metastore:** Account-level resources typically require Databricks **MWS** (account) provider. A stub is included/commented; wire it up after workspace creation.
>
> If you want me to auto-fill 2–3 above for your tenant, share the actual resource IDs, and I’ll update the TF.

## How to use

1. **Set environment for providers** (recommended):
   ```bash
   # Azure CLI login
   az login
   az account set --subscription <SUB_ID>

   # Databricks provider (workspace URL & PAT if needed)
   export DATABRICKS_HOST="https://adb-<workspace-id>.azuredatabricks.net"
   export DATABRICKS_TOKEN="<your-PAT>"
   ```

2. **Edit `terraform.tfvars`** with values specific to your subscription (e.g., `subscription_id`, `tenant_id`, `sql_server_id`, `hub_vnet_id`).

3. **Initialize & apply**
   ```bash
   terraform init
   terraform plan -out tfplan
   terraform apply tfplan
   ```

## Post-apply checklist
- Validate DNS resolution inside the VNet for `*.privatelink.*` zones.
- Confirm Databricks workspace status and that clusters can attach to VNet-injected subnets.
- Attach Diagnostic Settings for any extra resources you add later.
- (Optional) Configure **Unity Catalog** at account level and set storage root in ADLS.

---
**Shahid**: If you prefer the README in **Hindi**, I can generate that version too. 😊
