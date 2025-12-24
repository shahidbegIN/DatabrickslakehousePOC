
locals {
  tags = {
    environment = "dev"
    owner       = "infra"
    workload    = "lakehouse-poc"
  }
}

resource "azurerm_resource_group" "rg" {
  name     = var.rg_name
  location = var.location
  tags     = local.tags
}

# Networking: VNet & Subnets
resource "azurerm_virtual_network" "vnet" {
  name                = var.vnet_name
  address_space       = [var.vnet_address_space]
  location            = var.location
  resource_group_name = azurerm_resource_group.rg.name
  tags                = local.tags
}

resource "azurerm_subnet" "snet_dev" {
  name                 = var.subnet_dev_name
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = [var.subnet_dev_cidr]
}

resource "azurerm_subnet" "snet_pep" {
  name                 = var.subnet_pep_name
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = [var.subnet_pep_cidr]
  private_endpoint_network_policies_enabled = false
}

resource "azurerm_subnet" "snet_dbpr" {
  name                 = var.subnet_dbpr_name
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = [var.subnet_dbpr_cidr]
}

resource "azurerm_subnet" "snet_dbpu" {
  name                 = var.subnet_dbpu_name
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = [var.subnet_dbpu_cidr]
}

# NSGs
resource "azurerm_network_security_group" "nsg_dev" {
  name                = var.nsg_dev_name
  location            = var.location
  resource_group_name = azurerm_resource_group.rg.name
  tags                = local.tags
}

resource "azurerm_network_security_group" "nsg_dbpr" {
  name                = var.nsg_dbpr_name
  location            = var.location
  resource_group_name = azurerm_resource_group.rg.name
  tags                = local.tags
}

resource "azurerm_network_security_group" "nsg_dbpu" {
  name                = var.nsg_dbpu_name
  location            = var.location
  resource_group_name = azurerm_resource_group.rg.name
  tags                = local.tags
}

resource "azurerm_network_security_group" "nsg_pep" {
  name                = var.nsg_pep_name
  location            = var.location
  resource_group_name = azurerm_resource_group.rg.name
  tags                = local.tags
}

# (Sample) NSG rules — adjust to your security posture
resource "azurerm_network_security_rule" "allow_azure_lb_inbound" {
  name                        = "nsgsr-POC-dev-001-allow-azlb"
  priority                    = 100
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "*"
  source_address_prefix       = "AzureLoadBalancer"
  destination_address_prefix  = "*"
  resource_group_name         = azurerm_resource_group.rg.name
  network_security_group_name = azurerm_network_security_group.nsg_dev.name
}

# Associate NSGs to subnets
resource "azurerm_subnet_network_security_group_association" "assoc_dev" {
  subnet_id                 = azurerm_subnet.snet_dev.id
  network_security_group_id = azurerm_network_security_group.nsg_dev.id
}

resource "azurerm_subnet_network_security_group_association" "assoc_dbpr" {
  subnet_id                 = azurerm_subnet.snet_dbpr.id
  network_security_group_id = azurerm_network_security_group.nsg_dbpr.id
}

resource "azurerm_subnet_network_security_group_association" "assoc_dbpu" {
  subnet_id                 = azurerm_subnet.snet_dbpu.id
  network_security_group_id = azurerm_network_security_group.nsg_dbpu.id
}

resource "azurerm_subnet_network_security_group_association" "assoc_pep" {
  subnet_id                 = azurerm_subnet.snet_pep.id
  network_security_group_id = azurerm_network_security_group.nsg_pep.id
}

# Route table (placeholder) and association for dev subnet
resource "azurerm_route_table" "rt" {
  name                = var.route_table_name
  location            = var.location
  resource_group_name = azurerm_resource_group.rg.name
  tags                = local.tags
}

resource "azurerm_subnet_route_table_association" "rt_assoc_dev" {
  subnet_id      = azurerm_subnet.snet_dev.id
  route_table_id = azurerm_route_table.rt.id
}

# IP Group
resource "azurerm_ip_group" "ipg" {
  name                = var.ip_group_name
  location            = var.location
  resource_group_name = azurerm_resource_group.rg.name
  cidrs               = var.ip_group_cidrs
  tags                = local.tags
}

# Monitoring: Log Analytics & App Insights
resource "azurerm_log_analytics_workspace" "law" {
  name                = var.log_analytics_name
  location            = var.location
  resource_group_name = azurerm_resource_group.rg.name
  sku                 = "PerGB2018"
  retention_in_days   = 30
  tags                = local.tags
}

resource "azurerm_application_insights" "appi" {
  name                = var.app_insights_name
  location            = var.location
  resource_group_name = azurerm_resource_group.rg.name
  application_type    = "web"
  workspace_id        = azurerm_log_analytics_workspace.law.id
  tags                = local.tags
}

# Key Vault (RBAC enabled)
resource "azurerm_key_vault" "kv" {
  name                        = var.kv_name
  location                    = var.location
  resource_group_name         = azurerm_resource_group.rg.name
  tenant_id                   = var.tenant_id
  sku_name                    = "standard"
  purge_protection_enabled    = true
  soft_delete_retention_days  = 7
  enable_rbac_authorization   = true
  public_network_access_enabled = false
  tags                        = local.tags
}

# Managed Identity
resource "azurerm_user_assigned_identity" "uami" {
  name                = var.managed_identity_name
  location            = var.location
  resource_group_name = azurerm_resource_group.rg.name
  tags                = local.tags
}

# Azure AD App Registration + SP + client secret stored in KV
resource "azuread_application" "app" {
  display_name = var.app_reg_name
}

resource "azuread_service_principal" "sp" {
  client_id = azuread_application.app.client_id
}

resource "azuread_application_password" "app_pwd" {
  application_object_id = azuread_application.app.id
  display_name          = "terraform-generated"
  end_date_relative     = "8760h" # 1 year
}

resource "azurerm_key_vault_secret" "sp_secret" {
  name         = "${var.app_reg_name}-secret"
  value        = azuread_application_password.app_pwd.value
  key_vault_id = azurerm_key_vault.kv.id
}

# Storage (ADLS Gen2)
resource "azurerm_storage_account" "dls" {
  name                     = var.storage_name
  resource_group_name      = azurerm_resource_group.rg.name
  location                 = var.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
  is_hns_enabled           = true
  allow_blob_public_access = false
  min_tls_version          = "TLS1_2"
  network_rules {
    default_action             = "Deny"
    bypass                     = ["AzureServices"]
    ip_rules                   = []
  }
  tags = local.tags
}

resource "azurerm_storage_container" "containers" {
  for_each              = toset(var.storage_containers)
  name                  = each.value
  storage_account_name  = azurerm_storage_account.dls.name
  container_access_type = "private"
}

# Private DNS zones and links
resource "azurerm_private_dns_zone" "pl_blob" {
  name                = "privatelink.blob.core.windows.net"
  resource_group_name = azurerm_resource_group.rg.name
}
resource "azurerm_private_dns_zone" "pl_dfs" {
  name                = "privatelink.dfs.core.windows.net"
  resource_group_name = azurerm_resource_group.rg.name
}
resource "azurerm_private_dns_zone" "pl_kv" {
  name                = "privatelink.vaultcore.azure.net"
  resource_group_name = azurerm_resource_group.rg.name
}
resource "azurerm_private_dns_zone" "pl_sql" {
  name                = "privatelink.database.windows.net"
  resource_group_name = azurerm_resource_group.rg.name
}
resource "azurerm_private_dns_zone" "pl_dbx" {
  name                = "privatelink.azuredatabricks.net"
  resource_group_name = azurerm_resource_group.rg.name
}

# Links to VNet
resource "azurerm_private_dns_zone_virtual_network_link" "link_blob" {
  name                  = var.private_link_zone_names.dls
  resource_group_name   = azurerm_resource_group.rg.name
  private_dns_zone_name = azurerm_private_dns_zone.pl_blob.name
  virtual_network_id    = azurerm_virtual_network.vnet.id
}
resource "azurerm_private_dns_zone_virtual_network_link" "link_dfs" {
  name                  = "${var.private_link_zone_names.dls}-dfs"
  resource_group_name   = azurerm_resource_group.rg.name
  private_dns_zone_name = azurerm_private_dns_zone.pl_dfs.name
  virtual_network_id    = azurerm_virtual_network.vnet.id
}
resource "azurerm_private_dns_zone_virtual_network_link" "link_kv" {
  name                  = var.private_link_zone_names.kv
  resource_group_name   = azurerm_resource_group.rg.name
  private_dns_zone_name = azurerm_private_dns_zone.pl_kv.name
  virtual_network_id    = azurerm_virtual_network.vnet.id
}
resource "azurerm_private_dns_zone_virtual_network_link" "link_sql" {
  name                  = var.private_link_zone_names.sql
  resource_group_name   = azurerm_resource_group.rg.name
  private_dns_zone_name = azurerm_private_dns_zone.pl_sql.name
  virtual_network_id    = azurerm_virtual_network.vnet.id
}
resource "azurerm_private_dns_zone_virtual_network_link" "link_dbx" {
  name                  = var.private_link_zone_names.dbx
  resource_group_name   = azurerm_resource_group.rg.name
  private_dns_zone_name = azurerm_private_dns_zone.pl_dbx.name
  virtual_network_id    = azurerm_virtual_network.vnet.id
}

# Private Endpoints
# ADLS Gen2 (DFS)
resource "azurerm_private_endpoint" "pep_dls_dfs" {
  name                = var.private_endpoint_names.dls
  location            = var.location
  resource_group_name = azurerm_resource_group.rg.name
  subnet_id           = azurerm_subnet.snet_pep.id

  private_service_connection {
    name                           = "${var.private_endpoint_names.dls}-dfs"
    is_manual_connection           = false
    private_connection_resource_id = azurerm_storage_account.dls.id
    subresource_names              = ["dfs"]
  }

  private_dns_zone_group {
    name                 = "dls-dfs-dns-group"
    private_dns_zone_ids = [azurerm_private_dns_zone.pl_dfs.id]
  }
}

# Key Vault
resource "azurerm_private_endpoint" "pep_kv" {
  name                = var.private_endpoint_names.kv
  location            = var.location
  resource_group_name = azurerm_resource_group.rg.name
  subnet_id           = azurerm_subnet.snet_pep.id

  private_service_connection {
    name                           = "${var.private_endpoint_names.kv}-conn"
    private_connection_resource_id = azurerm_key_vault.kv.id
    is_manual_connection           = false
    subresource_names              = ["vault"]
  }
  private_dns_zone_group {
    name                 = "kv-dns-group"
    private_dns_zone_ids = [azurerm_private_dns_zone.pl_kv.id]
  }
}

# SQL Server (existing) — requires var.sql_server_id
resource "azurerm_private_endpoint" "pep_sql" {
  count               = var.sql_server_id == null ? 0 : 1
  name                = var.private_endpoint_names.sql
  location            = var.location
  resource_group_name = azurerm_resource_group.rg.name
  subnet_id           = azurerm_subnet.snet_pep.id

  private_service_connection {
    name                           = "${var.private_endpoint_names.sql}-conn"
    private_connection_resource_id = var.sql_server_id
    is_manual_connection           = false
    subresource_names              = ["sqlServer"]
  }
  private_dns_zone_group {
    name                 = "sql-dns-group"
    private_dns_zone_ids = [azurerm_private_dns_zone.pl_sql.id]
  }
}

# Databricks PrivateLink — Confirm subresource_names in your region
resource "azurerm_private_endpoint" "pep_dbx" {
  name                = var.private_endpoint_names.dbx
  location            = var.location
  resource_group_name = azurerm_resource_group.rg.name
  subnet_id           = azurerm_subnet.snet_pep.id

  private_service_connection {
    name                           = "${var.private_endpoint_names.dbx}-conn"
    private_connection_resource_id = azurerm_databricks_workspace.dbx.id
    is_manual_connection           = false
    # Common subresources include "browser" and/or "databricks_ui_api". Adjust if needed.
    subresource_names              = ["browser"]
  }
  private_dns_zone_group {
    name                 = "dbx-dns-group"
    private_dns_zone_ids = [azurerm_private_dns_zone.pl_dbx.id]
  }
}

# Databricks Workspace (Premium) with VNet injection
resource "azurerm_databricks_workspace" "dbx" {
  name                = var.databricks_workspace_name
  location            = var.location
  resource_group_name = azurerm_resource_group.rg.name
  sku                 = var.databricks_tier
  tags                = local.tags

  custom_parameters {
    vnet_id                   = azurerm_virtual_network.vnet.id
    private_subnet_name       = azurerm_subnet.snet_dbpr.name
    public_subnet_name        = azurerm_subnet.snet_dbpu.name
    managed_resource_group_id = null
    managed_resource_group_name = var.managed_rg_name
  }
}

# Hub-Spoke VNet peering (to existing Hub VNet)
resource "azurerm_virtual_network_peering" "spoke_to_hub" {
  count                        = var.hub_vnet_id == null ? 0 : 1
  name                         = "${var.vnet_name}-to-hub"
  resource_group_name          = azurerm_resource_group.rg.name
  virtual_network_name         = azurerm_virtual_network.vnet.name
  remote_virtual_network_id    = var.hub_vnet_id
  allow_virtual_network_access = true
  allow_forwarded_traffic      = true
  allow_gateway_transit        = false
  use_remote_gateways          = false
}

# Public IP
resource "azurerm_public_ip" "pip" {
  name                = var.public_ip_name
  resource_group_name = azurerm_resource_group.rg.name
  location            = var.location
  allocation_method   = "Static"
  sku                 = "Standard"
  tags                = local.tags
}

# Container Registry
resource "azurerm_container_registry" "acr" {
  name                = var.acr_name
  resource_group_name = azurerm_resource_group.rg.name
  location            = var.location
  sku                 = "Basic"
  admin_enabled       = false
  tags                = local.tags
}

# Backup Vault
resource "azurerm_backup_vault" "bv" {
  name                = var.backup_vault_name
  resource_group_name = azurerm_resource_group.rg.name
  location            = var.location
  storage_settings {
    datastore_type = "VaultStore"
    type           = "LocallyRedundant"
  }
  tags = local.tags
}
