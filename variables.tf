
variable "location" { default = "eastus" }

variable "subscription_id" { type = string }
variable "tenant_id" { type = string }

# Names provided
variable "rg_name" { default = "rg-POC-dev-001" }
variable "vnet_name" { default = "vnet-POC-cus-001" }
variable "vnet_address_space" { default = "10.1.0.0/16" }

variable "subnet_dev_name" { default = "snet-dev-cus-001" }
variable "subnet_dev_cidr" { default = "10.1.0.0/24" }

variable "subnet_pep_name" { default = "snet-pep-dev-cus-001" }
variable "subnet_pep_cidr" { default = "10.1.1.0/24" }

variable "subnet_dbpr_name" { default = "snet-dbpr-dev-cus-001" }
variable "subnet_dbpr_cidr" { default = "10.1.2.0/24" }

variable "subnet_dbpu_name" { default = "snet-dbpu-dev-cus-001" }
variable "subnet_dbpu_cidr" { default = "10.1.3.0/24" }

variable "nsg_dev_name" { default = "nsg-POC-dev-cus-001" }
variable "nsg_dbpr_name" { default = "nsg-dbpr-dev-cus-001" }
variable "nsg_dbpu_name" { default = "nsg-dbpu-dev-cus-001" }
variable "nsg_pep_name" { default = "nsg-pep-dev-cus-001" }

variable "route_table_name" { default = "rt-POC-dev-cus-001" }

variable "ip_group_name" { default = "ipg-POC-dev-cus-001" }
variable "ip_group_cidrs" {
  type    = list(string)
  default = ["10.1.0.0/24", "10.1.1.0/24", "10.1.2.0/24", "10.1.3.0/24"]
}

variable "kv_name" { default = "kv-POC-dev-001" }

variable "storage_name" { default = "dlsPOCdevcus002" }
variable "storage_containers" {
  type    = list(string)
  default = ["bronze", "silver", "gold"]
}

variable "private_endpoint_names" {
  type = object({
    dls = "pep-dlsPOCdevcus002-001"
    kv  = "pep-kvPOCdev001-001"
    sql = "pep-sqlPOCdevcus001-001"
    dbx = "pep-dbxPOCdevcus001-001"
  })
}

variable "private_link_zone_names" {
  type = object({
    dls = "pl-dlsPOCdevcus002-cus-001"
    kv  = "pl-kv-dev-cus-001"
    sql = "pl-sql-dev-cus-001"
    dbx = "pl-dbx-dev-cus-001"
  })
}

variable "app_reg_name" { default = "appreg-POC-dev-cus-001" }
variable "managed_identity_name" { default = "mi-POC-dev-001" }

variable "databricks_workspace_name" { default = "dbx-POC-dev-cus-001" }
variable "databricks_tier" { default = "premium" }
variable "managed_rg_name" { default = "mrg-dbx-POC-dev-cus-001" }

variable "log_analytics_name" { default = "log-POC-dev-cus-001" }
variable "app_insights_name" { default = "appi-POC-dev-cus-001" }

variable "public_ip_name" { default = "pip-POC-dev-cus-001" }
variable "acr_name" { default = "cr-POC-dev-cus001" }

variable "backup_vault_name" { default = "bvault-dev-001" }

variable "hub_vnet_id" { type = string, default = null }
variable "sql_server_id" { type = string, default = null }

# Databricks provider env (workspace-level)
variable "databricks_host" { type = string, default = null }
variable "databricks_token" { type = string, default = null }
