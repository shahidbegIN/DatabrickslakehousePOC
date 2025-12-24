
output "resource_group_id" { value = azurerm_resource_group.rg.id }
output "vnet_id" { value = azurerm_virtual_network.vnet.id }
output "subnet_ids" {
  value = {
    dev = azurerm_subnet.snet_dev.id
    pep = azurerm_subnet.snet_pep.id
    dbpr = azurerm_subnet.snet_dbpr.id
    dbpu = azurerm_subnet.snet_dbpu.id
  }
}
output "storage_account_id" { value = azurerm_storage_account.dls.id }
output "key_vault_uri" { value = azurerm_key_vault.kv.vault_uri }
output "databricks_workspace_id" { value = azurerm_databricks_workspace.dbx.id }
