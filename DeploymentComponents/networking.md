## Minimum Number of IP's Needed within Virtual Network

Subnet | Resource | Number of IP's | Notes
-- | -- | :--: | --
Private Endpoint Subnet | Synapse | 3 | Private Endpoints
Private Endpoint Subnet | Purview | 4 | Private Endpoints
Private Endpoint Subnet | Landing Storage | 3 | Private Endpoints
Private Endpoint Subnet | Data Lake | 2 | Private Endpoints
Private Endpoint Subnet | Key Vault | 1 | Private Endpoints
Private Endpoint Subnet | SQL Server | 1 | Private Endpoints
Private Endpoint Subnet | Machine Learning Workspace | 1 | Private Endpoints
Private Endpoint Subnet | ML Storage | 4 | Private Endpoints
Private Endpoint Subnet | ML Container Registry | 1 | Private Endpoints
Private Endpoint Subnet | ML Key Vault | 1 | Private Endpoints
Private Endpoint Subnet | Logic App Storage | 4 | Private Endpoints
Private Endpoint Subnet | Data Factory | 2 | Private Endpoints
Private Endpoint Subnet | Cognitive Service | 1 | Private Endpoints
Private Endpoint Subnet | Event Hub Namespace | 1 | Private Endpoints
Private Endpoint Subnet | Databricks | 2 | Private Endpoints
**Data Subnet** | **Data Subnet Minimum IP's** | **31** |  /26 recommended |
Logic App Subnet | Logic App | 32 | [(/27 subnet minimum)](https://learn.microsoft.com/en-us/azure/logic-apps/secure-single-tenant-workflow-virtual-network-private-endpoint#considerations-for-outbound-traffic-through-virtual-network-integration)
**Logic App Subnet** | **Logic App Subnet Minimum IP's** | **32** |  
  | **Total Minimum IP's Needed** | **63** |  

## Required DNS Zones

The customer should provide the DNS Zones. **Please do not deploy the optional DNS zones from the IP Kit if you're integrating with an existing Virtual Network.**

Private link resource type / Subresource | Private DNS zone name | Notes
-- | -- | --
Azure SQL Database (Microsoft.Sql/servers) / sqlServer | privatelink.database.windows.net |  
Azure Synapse Analytics (Microsoft.Synapse/workspaces) / Sql | privatelink.sql.azuresynapse.net |  
Azure Synapse Analytics (Microsoft.Synapse/workspaces) / SqlOnDemand | privatelink.sql.azuresynapse.net |  
Azure Synapse Analytics (Microsoft.Synapse/workspaces) / Dev | privatelink.dev.azuresynapse.net |  
Azure Synapse Studio (Microsoft.Synapse/privateLinkHubs) / Web | privatelink.azuresynapse.net | Private Endpoint Deployment Can be Disabled in [Networking File(s)](../blob/main/DeliveryIP_GitHub/variables/networking_setup/)
Storage account (Microsoft.Storage/storageAccounts) / Blob (blob, blob_secondary) | privatelink.blob.core.windows.net |  
Storage account (Microsoft.Storage/storageAccounts) / Table (table, table_secondary) | privatelink.table.core.windows.net |  
Storage account (Microsoft.Storage/storageAccounts) / Queue (queue, queue_secondary) | privatelink.queue.core.windows.net |  
Storage account (Microsoft.Storage/storageAccounts) / File (file, file_secondary) | privatelink.file.core.windows.net |  
Storage account (Microsoft.Storage/storageAccounts) / DFS (dfs, dfs_secondary) | privatelink.dfs.core.windows.net |  
Storage account (Microsoft.Storage/storageAccounts) / Web (web, web_secondary) | privatelink.web.core.windows.net |  
Azure Event Hubs (Microsoft.EventHub/namespaces) / namespace | privatelink.servicebus.windows.net |  
Azure Key Vault (Microsoft.KeyVault/vaults) / vault | privatelink.vaultcore.azure.net |  
Azure Container Registry (Microsoft.ContainerRegistry/registries) / registry | privatelink.azurecr.io |  
Azure Machine Learning (Microsoft.MachineLearningServices/workspaces) / amlworkspace | privatelink.api.azureml.ms & privatelink.notebooks.azure.net |  
Cognitive Services (Microsoft.CognitiveServices/accounts) / account | privatelink.cognitiveservices.azure.com |  
Azure Data Factory (Microsoft.DataFactory/factories) / dataFactory | privatelink.datafactory.azure.net |  
Azure Data Factory (Microsoft.DataFactory/factories) / portal | privatelink.adf.azure.com | Private Endpoint Deployment Can be Disabled in [Networking File(s)](../blob/main/DeliveryIP_GitHub/variables/networking_setup/)
Microsoft Purview (Microsoft.Purview) / account | privatelink.purview.azure.com | Private Endpoint Deployment Can be Disabled in [Networking File(s)](../blob/main/DeliveryIP_GitHub/variables/networking_setup/)
Microsoft Purview (Microsoft.Purview) / portal | privatelink.purviewstudio.azure.com | Private Endpoint Deployment Can be Disabled in [Networking File(s)](../blob/main/DeliveryIP_GitHub/variables/networking_setup/)
Azure Databricks (Microsoft.Databricks/workspaces) | databricks_ui_api, browser_authentication | privatelink.azuredatabricks.net