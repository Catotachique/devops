output "resource_group_ids" {
  description = "The IDs of the resource groups."
  value = { for rg_key, rg in azurerm_resource_group.this : rg_key => rg.id }
}

output "resource_group_names" {
  description = "The names of the resource groups."
  value       = [for rg in azurerm_resource_group.this : rg.name]
}

output "resource_group_name_data_storage" {
  description = "Resource group name from data storage"
  value       = azurerm_resource_group.this["rg-data-storage"].name
}

output "resource_group_name_data_ingestion" {
  description = "Resource group name from data ingestion"
  value       = azurerm_resource_group.this["rg-data-ingestion"].name
}
