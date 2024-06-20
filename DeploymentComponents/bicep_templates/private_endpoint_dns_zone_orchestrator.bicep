// Copyright (c) Microsoft Corporation.
// Licensed under the MIT license.
param DeployDataLake string
param DeployLandingStorage string
param DeployKeyVault string
param DeployAzureSQL string
param DeployADF string
param DeploySynapse string
param DeployPurview string
param DeployLogicApp string
param DeployMLWorkspace string
param DeployCognitiveService string
param DeployEventHubNamespace string
param DeployADFPortalPrivateEndpoint string
param DeploySynapseWebPrivateEndpoint string
param DeployPurviewPrivateEndpoints string
param DeployDatabricks string


param VnetforPrivateEndpointsRgName string
param VnetforPrivateEndpointsName string
param DNS_ZONE_SUBSCRIPTION_ID string
param PrivateDNSZoneRgName string

resource r_vnet 'Microsoft.Network/virtualNetworks@2022-01-01' existing = {
  scope: resourceGroup(VnetforPrivateEndpointsRgName)
  name: VnetforPrivateEndpointsName
}

//storage - blob
var blobprivateDnsZoneName = 'privatelink.blob.${environment().suffixes.storage}'
module m_blob_dns_zone 'private_endpoint_dns_zone.bicep' = if (DeployDataLake == 'True' ||  DeployLandingStorage == 'True' || DeployPurview == 'True') {
  name: 'blob_private_endpoint'
  scope: resourceGroup(DNS_ZONE_SUBSCRIPTION_ID, PrivateDNSZoneRgName)
  params: {
    privateDnsZoneName: blobprivateDnsZoneName
    vnet_id: r_vnet.id
  }
}

//storage - dfs
var dfsprivateDnsZoneName = 'privatelink.dfs.${environment().suffixes.storage}'
module m_df_dns_zone 'private_endpoint_dns_zone.bicep' = if (DeployDataLake == 'True' ||  DeployLandingStorage == 'True') {
  name: 'dfs_private_endpoint'
  scope: resourceGroup(DNS_ZONE_SUBSCRIPTION_ID, PrivateDNSZoneRgName)
  params: {
    privateDnsZoneName: dfsprivateDnsZoneName
    vnet_id: r_vnet.id
  }
}

//storage - file
var fileprivateDnsZoneName = 'privatelink.file.${environment().suffixes.storage}'
module m_file_dns_zone 'private_endpoint_dns_zone.bicep' = if (DeployMLWorkspace == 'True' || DeployLandingStorage == 'True' || DeployLogicApp == 'True') {
  name: 'file_private_endpoint'
  scope: resourceGroup(DNS_ZONE_SUBSCRIPTION_ID, PrivateDNSZoneRgName)
  params: {
    privateDnsZoneName: fileprivateDnsZoneName
    vnet_id: r_vnet.id
  }
}

//storage - queue
var queueprivateDnsZoneName = 'privatelink.queue.${environment().suffixes.storage}'
module m_queue_dns_zone 'private_endpoint_dns_zone.bicep' = if (DeployMLWorkspace == 'True' || DeployLandingStorage == 'True' || DeployLogicApp == 'True' || DeployPurview == 'True') {
  name: 'queue_private_endpoint'
  scope: resourceGroup(DNS_ZONE_SUBSCRIPTION_ID, PrivateDNSZoneRgName)
  params: {
    privateDnsZoneName: queueprivateDnsZoneName
    vnet_id: r_vnet.id
  }
}

//storage - table
var tableprivateDnsZoneName = 'privatelink.table.${environment().suffixes.storage}'
module m_table_dns_zone 'private_endpoint_dns_zone.bicep' = if (DeployDataLake == 'True' || DeployLandingStorage == 'True' || DeployLogicApp == 'True') {
  name: 'table_private_endpoint'
  scope: resourceGroup(DNS_ZONE_SUBSCRIPTION_ID, PrivateDNSZoneRgName)
  params: {
    privateDnsZoneName: tableprivateDnsZoneName
    vnet_id: r_vnet.id
  }
}

//azure sql
var sqlPrivateDnsZoneName = 'privatelink${environment().suffixes.sqlServerHostname}'
module m_sql_dns_zone 'private_endpoint_dns_zone.bicep' = if (DeployAzureSQL == 'True') {
  name: 'sql_private_endpoint'
  scope: resourceGroup(DNS_ZONE_SUBSCRIPTION_ID, PrivateDNSZoneRgName)
  params: {
    privateDnsZoneName: sqlPrivateDnsZoneName
    vnet_id: r_vnet.id
  }
}

//cognitive service
var cognitiveServicePrivateDnsZoneName = 'privatelink.cognitiveservices.azure.com'
module m_cognitive_service_dns_zone 'private_endpoint_dns_zone.bicep' = if (DeployCognitiveService == 'True') {
  name: 'cognitive_service_dns_zone'
  scope: resourceGroup(DNS_ZONE_SUBSCRIPTION_ID, PrivateDNSZoneRgName)
  params: {
    privateDnsZoneName: cognitiveServicePrivateDnsZoneName
    vnet_id: r_vnet.id
  }
}

//data factory portal
var adfPortalPrivateDnsZoneName = 'privatelink.adf.azure.com'
module m_data_factory_portal_dns_zone 'private_endpoint_dns_zone.bicep' = if (DeployADF == 'True' && DeployADFPortalPrivateEndpoint == 'True') {
  name: 'data_factory_portal_dns_zone'
  scope: resourceGroup(DNS_ZONE_SUBSCRIPTION_ID, PrivateDNSZoneRgName)
  params: {
    privateDnsZoneName: adfPortalPrivateDnsZoneName
    vnet_id: r_vnet.id
  }
}

//data factory integration runtime
var adfPrivateDnsZoneName = 'privatelink.datafactory.azure.net'
module m_data_factory_dataFactory_dns_zone 'private_endpoint_dns_zone.bicep' = if (DeployADF == 'True') {
  name: 'data_factory_dataFactory_dns_zone'
  scope: resourceGroup(DNS_ZONE_SUBSCRIPTION_ID, PrivateDNSZoneRgName)
  params: {
    privateDnsZoneName: adfPrivateDnsZoneName
    vnet_id: r_vnet.id
  }
}

//event hub namespace for purview and/or event hub namespace for streaming pattern
var eventhubPrivateDnsZone='privatelink.servicebus.windows.net'
module m_event_hub_dns_zone 'private_endpoint_dns_zone.bicep' = if (DeployEventHubNamespace == 'True' || DeployPurview == 'True') {
  name: 'event_hub_dns_zone'
  scope: resourceGroup(DNS_ZONE_SUBSCRIPTION_ID, PrivateDNSZoneRgName)
  params: {
    privateDnsZoneName: eventhubPrivateDnsZone
    vnet_id: r_vnet.id
  }
}

//key vault
var keyVaultPrivateDnsZoneName = 'privatelink.vaultcore.azure.net'
module m_key_vault_dns_zone 'private_endpoint_dns_zone.bicep' = if (DeployKeyVault == 'True') {
  name: 'key_vault_dns_zone'
  scope: resourceGroup(DNS_ZONE_SUBSCRIPTION_ID, PrivateDNSZoneRgName)
  params: {
    privateDnsZoneName: keyVaultPrivateDnsZoneName
    vnet_id: r_vnet.id
  }
}

//logic app
var logicAppPrivateDnsZoneName = 'privatelink.azurewebsites.net'
module m_logic_app_dns_zone 'private_endpoint_dns_zone.bicep' = if (DeployLogicApp == 'True') {
  name: 'logic_app_dns_zone'
  scope: resourceGroup(DNS_ZONE_SUBSCRIPTION_ID, PrivateDNSZoneRgName)
  params: {
    privateDnsZoneName: logicAppPrivateDnsZoneName
    vnet_id: r_vnet.id
  }
}

//purview - portal
var purviewPortalprivateDnsZoneName = 'privatelink.purviewstudio.azure.com'
module m_purview_portal_dns_zone 'private_endpoint_dns_zone.bicep' = if (DeployPurview == 'True' && DeployPurviewPrivateEndpoints == 'True') {
  name: 'purview_portal_dns_zone'
  scope: resourceGroup(DNS_ZONE_SUBSCRIPTION_ID, PrivateDNSZoneRgName)
  params: {
    privateDnsZoneName: purviewPortalprivateDnsZoneName
    vnet_id: r_vnet.id
  }
}

//purview - account
var purviewAccountprivateDnsZoneName = 'privatelink.purview.azure.com'
module m_purview_account_dns_zone 'private_endpoint_dns_zone.bicep' = if (DeployPurview == 'True' && DeployPurviewPrivateEndpoints == 'True') {
  name: 'purview_account_dns_zone'
  scope: resourceGroup(DNS_ZONE_SUBSCRIPTION_ID, PrivateDNSZoneRgName)
  params: {
    privateDnsZoneName: purviewAccountprivateDnsZoneName
    vnet_id: r_vnet.id
  }
}

//synapse - dev
var synapseDevprivateDnsZoneName = 'privatelink.dev.azuresynapse.net'
module m_synapse_dev_dns_zone 'private_endpoint_dns_zone.bicep' = if (DeploySynapse == 'True') {
  name: 'synapse_dev_dns_zone'
  scope: resourceGroup(DNS_ZONE_SUBSCRIPTION_ID, PrivateDNSZoneRgName)
  params: {
    privateDnsZoneName: synapseDevprivateDnsZoneName
    vnet_id: r_vnet.id
  }
}

//synapse - sql
var synapseSqlprivateDnsZoneName = 'privatelink.sql.azuresynapse.net'
module m_synapse_sql_dns_zone 'private_endpoint_dns_zone.bicep' = if (DeploySynapse == 'True') {
  name: 'synapse_sql_dns_zone'
  scope: resourceGroup(DNS_ZONE_SUBSCRIPTION_ID, PrivateDNSZoneRgName)
  params: {
    privateDnsZoneName: synapseSqlprivateDnsZoneName
    vnet_id: r_vnet.id
  }
}

//synapse - web
var synapsePrivatelinkhubprivateDnsZoneName = 'privatelink.azuresynapse.net'
module m_synapse_web_dns_zone 'private_endpoint_dns_zone.bicep' = if (DeploySynapse == 'True' && DeploySynapseWebPrivateEndpoint == 'True') {
  name: 'synapse_web_dns_zone'
  scope: resourceGroup(DNS_ZONE_SUBSCRIPTION_ID, PrivateDNSZoneRgName)
  params: {
    privateDnsZoneName: synapsePrivatelinkhubprivateDnsZoneName
    vnet_id: r_vnet.id
  }
}

//machine leaning workspace container registry
var containerRegistryPrivateDnsZoneName = 'privatelink${environment().suffixes.acrLoginServer}'
module m_container_registry_dns_zone 'private_endpoint_dns_zone.bicep' = if (DeployMLWorkspace == 'True') {
  name: 'container_registry_dns_zone'
  scope: resourceGroup(DNS_ZONE_SUBSCRIPTION_ID, PrivateDNSZoneRgName)
  params: {
    privateDnsZoneName: containerRegistryPrivateDnsZoneName
    vnet_id: r_vnet.id
  }
}

//machine leaning workspace api
var mlWorkspaceprivateDnsZoneName1 = 'privatelink.api.azureml.ms'
module m_ml_workspace_api_dns_zone 'private_endpoint_dns_zone.bicep' = if (DeployMLWorkspace == 'True') {
  name: 'ml_workspace_api_dns_zone'
  scope: resourceGroup(DNS_ZONE_SUBSCRIPTION_ID, PrivateDNSZoneRgName)
  params: {
    privateDnsZoneName: mlWorkspaceprivateDnsZoneName1
    vnet_id: r_vnet.id
  }
}

//machine leaning workspace notebook
var mlWorkspaceprivateDnsZoneName2 = 'privatelink.notebooks.azure.net'
module m_ml_workspace_notebook_dns_zone 'private_endpoint_dns_zone.bicep' = if (DeployMLWorkspace == 'True') {
  name: 'ml_workspace_notebook_dns_zone'
  scope: resourceGroup(DNS_ZONE_SUBSCRIPTION_ID, PrivateDNSZoneRgName)
  params: {
    privateDnsZoneName: mlWorkspaceprivateDnsZoneName2
    vnet_id: r_vnet.id
  }
}

//databricks workspace
var databricksWorkspaceDnsZoneName = 'privatelink.azuredatabricks.net'
module m_databricksWorkspace_dns_zone 'private_endpoint_dns_zone.bicep' = if (DeployDatabricks == 'True') {
  name: 'databricksWorkspace_dns_zone'
  scope: resourceGroup(DNS_ZONE_SUBSCRIPTION_ID, PrivateDNSZoneRgName)
  params: {
    privateDnsZoneName: databricksWorkspaceDnsZoneName
    vnet_id: r_vnet.id
  }
}
