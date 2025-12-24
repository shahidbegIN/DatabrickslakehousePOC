
# Diagnostic settings to Log Analytics
resource "azurerm_monitor_diagnostic_setting" "diag_dls" {
  name                       = "diag-dls"
  target_resource_id         = azurerm_storage_account.dls.id
  log_analytics_workspace_id = azurerm_log_analytics_workspace.law.id

  metric {
    category = "AllMetrics"
    enabled  = true
  }
  lifecycle { ignore_changes = [metric] }
}

resource "azurerm_monitor_diagnostic_setting" "diag_kv" {
  name                       = "diag-kv"
  target_resource_id         = azurerm_key_vault.kv.id
  log_analytics_workspace_id = azurerm_log_analytics_workspace.law.id

  enabled_log { category = "AuditEvent" }
  metric { category = "AllMetrics" }
}

resource "azurerm_monitor_diagnostic_setting" "diag_dbx" {
  name                       = "diag-dbx"
  target_resource_id         = azurerm_databricks_workspace.dbx.id
  log_analytics_workspace_id = azurerm_log_analytics_workspace.law.id

  metric { category = "AllMetrics" }
}
