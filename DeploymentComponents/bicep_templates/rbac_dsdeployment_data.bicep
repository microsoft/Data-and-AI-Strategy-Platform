// Copyright (c) Microsoft Corporation.
// Licensed under the MIT license.
param env string

param Service_Principal_Infra_Object_ID string

param Assign_RBAC_for_CICD_Service_Principal string

param Service_Principal_CICD_Object_ID string

param Entra_Group_Admin_Group_ID string

param Entra_Group_Shared_Service_Group_ID string

param Assign_RBAC_for_Governance string

param Entra_Group_Governance_Group_ID string

param Assign_RBAC_for_Publishers string

param Entra_Groups_Data_Publishers string

var Entra_Groups_Data_Publishers_Object = (Assign_RBAC_for_Publishers == 'True') ? json(Entra_Groups_Data_Publishers) : []

param Assign_RBAC_for_Producers string

param Entra_Groups_Data_Producers string

var Entra_Groups_Data_Producers_Object = (Assign_RBAC_for_Producers == 'True') ? json(Entra_Groups_Data_Producers) : []

param Assign_RBAC_for_Consumers string

param Entra_Groups_Data_Consumers string

var Entra_Groups_Data_Consumers_Object = (Assign_RBAC_for_Consumers == 'True') ? json(Entra_Groups_Data_Consumers) : []

var Entra_Groups_Data_Consumers_Publishers_Producers = union(Entra_Groups_Data_Publishers_Object, Entra_Groups_Data_Producers_Object, Entra_Groups_Data_Consumers_Object)

param DeployDataLake string

param dataLakeName string

param DeployLandingStorage string

param landingStorageName string

param DeployPurview string

param purviewName string

param DeployKeyVault string

param keyVaultName string

param DeployADF string

param dataFactoryName string 

param DeploySynapse string

param synapseWorkspaceName string

param DeployCognitiveService string

param cognitiveServiceName string

param DeployEventHubNamespace string

param eventHubNamespaceName string

param DeployStreamAnalytics string

param streamAnalyticsName string

param DeployLogicApp string

param logicAppRG string

param logicAppName string

param DeployDatabricks string

param databricksWorkspaceName string

// assign Contributor for CI/CD Sevrice Principal
var azureRBACContributorRoleID = 'b24988ac-6180-42a0-ab88-20f7382dd24c'

resource r_CICDServicePrincipalContributorAtRg 'Microsoft.Authorization/roleAssignments@2022-04-01' = if (Assign_RBAC_for_CICD_Service_Principal == 'True') {
  name: guid(Service_Principal_CICD_Object_ID, 'ContributorAtRG', resourceGroup().name)
  properties:{
    roleDefinitionId: resourceId('Microsoft.Authorization/roleDefinitions', azureRBACContributorRoleID)
    principalId: Service_Principal_CICD_Object_ID
    principalType: 'ServicePrincipal'
  }
}


// Assign Reader Role to All Entra Groups
// Reader Role ID
var azureRBACReaderRoleID = 'acdd72a7-3385-48ef-bd42-f606fba81ae7' 

resource r_SharedServiceReaderAtRg 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid(Entra_Group_Shared_Service_Group_ID, 'ReaderAtRG', resourceGroup().name)
  properties:{
    roleDefinitionId: resourceId('Microsoft.Authorization/roleDefinitions', azureRBACReaderRoleID)
    principalId: Entra_Group_Shared_Service_Group_ID
    principalType: 'Group'
  }
}

resource r_GovernanceReaderAtRg 'Microsoft.Authorization/roleAssignments@2022-04-01' = if (Assign_RBAC_for_Governance == 'True') {
  name: guid(Entra_Group_Governance_Group_ID, 'ReaderAtRG', resourceGroup().name)
  properties:{
    roleDefinitionId: resourceId('Microsoft.Authorization/roleDefinitions', azureRBACReaderRoleID)
    principalId: Entra_Group_Governance_Group_ID
    principalType: 'Group'
  }
}

resource r_PublishersConsumersProducersReaderAtRg 'Microsoft.Authorization/roleAssignments@2022-04-01' = [for Entra_Groups_Data_Consumer_Publisher_Producer in Entra_Groups_Data_Consumers_Publishers_Producers: {
  name: guid(Entra_Groups_Data_Consumer_Publisher_Producer.Group_ID, 'ReaderAtRG', resourceGroup().name)
  properties:{
    roleDefinitionId: resourceId('Microsoft.Authorization/roleDefinitions', azureRBACReaderRoleID)
    principalId: Entra_Groups_Data_Consumer_Publisher_Producer.Group_ID
    principalType: 'Group'
  }
}]

resource r_logicapp 'Microsoft.Web/sites@2022-03-01' existing = {
  scope: resourceGroup(logicAppRG)
  name: logicAppName
}

resource r_keyvault 'Microsoft.KeyVault/vaults@2021-11-01-preview' existing = if (DeployKeyVault == 'True') {
  name: keyVaultName
}

//Grant Key Vault Secrets Officer to Admin Entra Group on Key Vault
//Key Vault Secrets Officer
var azureRBACKeyVaultSecretsOfficerRoleID = 'b86a8fe4-44ce-4948-aee5-eccb2c155cd7' 

resource r_keyVaultRoleAssignmentAdmin 'Microsoft.Authorization/roleAssignments@2022-04-01' = if (DeployKeyVault == 'True') {
  name: guid(r_keyvault.id, Entra_Group_Admin_Group_ID)
  scope: r_keyvault
  properties:{
    roleDefinitionId: resourceId('Microsoft.Authorization/roleDefinitions', azureRBACKeyVaultSecretsOfficerRoleID)
    principalId: Entra_Group_Admin_Group_ID
    principalType: 'Group'
  }
}

resource r_keyVaultRoleAssignmentSharedServices 'Microsoft.Authorization/roleAssignments@2022-04-01' = if (env == 'dev' && DeployKeyVault == 'True' && Entra_Group_Shared_Service_Group_ID != Entra_Group_Admin_Group_ID) {
  name: guid(r_keyvault.id, Entra_Group_Shared_Service_Group_ID)
  scope: r_keyvault
  properties:{
    roleDefinitionId: resourceId('Microsoft.Authorization/roleDefinitions', azureRBACKeyVaultSecretsOfficerRoleID)
    principalId: Entra_Group_Shared_Service_Group_ID
    principalType: 'Group'
  }
}

resource r_purview 'Microsoft.Purview/accounts@2021-07-01' existing = if (DeployPurview == 'True') {
  name: purviewName
}

// Storage Blob Data Owner Role
var azureRBACStorageBlobDataOwnerRoleID = 'b7e6dc6d-f1e8-4753-8033-0f276bb0955b' 

// Storage Blob Data Contributor Role
var azureRBACStorageBlobDataContributorRoleID = 'ba92f5b4-2d11-453d-a403-e96b0029c9fe' 

// Storage Blob Data Reader Role
var azureRBACStorageBlobDataReaderRoleID = '2a2b9908-6ea1-4ae2-8e65-a410df84e7d1' 

resource r_dataLake 'Microsoft.Storage/storageAccounts@2021-09-01' existing = if (DeployDataLake == 'True') {
  name: dataLakeName
}

//Grant Blob Storage Owner to Service Principal so it can assign ACL's
resource r_dataLakeRoleAssignmentServicePrincipalInfra 'Microsoft.Authorization/roleAssignments@2022-04-01' = if (DeployDataLake == 'True') {
  name: guid(r_dataLake.id, Service_Principal_Infra_Object_ID)
  scope: r_dataLake
  properties:{
    roleDefinitionId: resourceId('Microsoft.Authorization/roleDefinitions', azureRBACStorageBlobDataOwnerRoleID)
    principalId: Service_Principal_Infra_Object_ID
    principalType: 'ServicePrincipal'
  }
}

//Grant Blob Storage Contributor to Shared Service Entra Group on Storage Account If NonProd, Otherwies Reader
resource r_dataLakeRoleAssignmentEntraGroupNonProd 'Microsoft.Authorization/roleAssignments@2022-04-01' = if (env != 'prod' && DeployDataLake == 'True') {
  name: guid(r_dataLake.id, Entra_Group_Shared_Service_Group_ID)
  scope: r_dataLake
  properties:{
    roleDefinitionId: resourceId('Microsoft.Authorization/roleDefinitions', azureRBACStorageBlobDataContributorRoleID)
    principalId: Entra_Group_Shared_Service_Group_ID
    principalType: 'Group'
  }
}

//Grant Blob Storage Contributor to Shared Service Entra Group on Storage Account If NonProd, Otherwies Reader
resource r_dataLakeRoleAssignmentEntraGroupProd 'Microsoft.Authorization/roleAssignments@2022-04-01' = if (env == 'prod' && DeployDataLake == 'True') {
  name: guid(r_dataLake.id, Entra_Group_Shared_Service_Group_ID)
  scope: r_dataLake
  properties:{
    roleDefinitionId: resourceId('Microsoft.Authorization/roleDefinitions', azureRBACStorageBlobDataReaderRoleID)
    principalId: Entra_Group_Shared_Service_Group_ID
    principalType: 'Group'
  }
}

//Grant Blob Storage Reader to Data Consumers, Publishers, and Producers on Data Lake
resource r_readerOnDataLakeEntraGroupProd 'Microsoft.Authorization/roleAssignments@2022-04-01' = [for Entra_Groups_Consumer_Publisher_Producer in Entra_Groups_Data_Consumers_Publishers_Producers: {
  name: guid(Entra_Groups_Consumer_Publisher_Producer.Group_ID, r_dataLake.id)
  scope: r_dataLake
  properties:{
    roleDefinitionId: resourceId('Microsoft.Authorization/roleDefinitions', azureRBACStorageBlobDataReaderRoleID)
    principalId: Entra_Groups_Consumer_Publisher_Producer.Group_ID
    principalType: 'Group'
  }
}]

//Grant Purview Reader Rights to Storage Accounts
resource r_dataLakeRoleAssignmentPurview 'Microsoft.Authorization/roleAssignments@2022-04-01' = if (DeployPurview == 'True' && DeployDataLake == 'True') {
  name: guid(r_dataLake.id, r_purview.id)
  scope: r_dataLake
  properties:{
    roleDefinitionId: resourceId('Microsoft.Authorization/roleDefinitions', azureRBACStorageBlobDataReaderRoleID)
    principalId: (DeployPurview != 'True')?'':r_purview.identity.principalId
    principalType: 'ServicePrincipal'
  }
}


resource r_landingStorage 'Microsoft.Storage/storageAccounts@2021-09-01' existing = if (DeployLandingStorage == 'True') {
  name: landingStorageName
}

//Grant Blob Storage Owner to Service Principal so it can assign ACL's
resource r_landingStorageRoleAssignmentServicePrincipalInfra 'Microsoft.Authorization/roleAssignments@2022-04-01' = if (DeployLandingStorage == 'True') {
  name: guid(r_landingStorage.id, Service_Principal_Infra_Object_ID)
  scope: r_landingStorage
  properties:{
    roleDefinitionId: resourceId('Microsoft.Authorization/roleDefinitions', azureRBACStorageBlobDataOwnerRoleID)
    principalId: Service_Principal_Infra_Object_ID
    principalType: 'ServicePrincipal'
  }
}

//Grant Blob Storage Contributor to Shared Service Entra Group on Storage Account If NonProd, Otherwies Reader
resource r_landingStorageRoleAssignmentEntraGroupProd 'Microsoft.Authorization/roleAssignments@2022-04-01' = if (env == 'prod' && DeployLandingStorage == 'True') {
  name: guid(r_landingStorage.id, Entra_Group_Shared_Service_Group_ID)
  scope: r_landingStorage
  properties:{
    roleDefinitionId: resourceId('Microsoft.Authorization/roleDefinitions', azureRBACStorageBlobDataReaderRoleID)
    principalId: Entra_Group_Shared_Service_Group_ID
    principalType: 'Group'
  }
}

//Grant Blob Storage Contributor to Shared Service Entra Group on Storage Account If NonProd, Otherwies Reader
resource r_landingStorageRoleAssignmentEntraGroupNonProd 'Microsoft.Authorization/roleAssignments@2022-04-01' = if (env != 'prod' && DeployLandingStorage == 'True') {
  name: guid(r_landingStorage.id, Entra_Group_Shared_Service_Group_ID)
  scope: r_landingStorage
  properties:{
    roleDefinitionId: resourceId('Microsoft.Authorization/roleDefinitions', azureRBACStorageBlobDataContributorRoleID)
    principalId: Entra_Group_Shared_Service_Group_ID
    principalType: 'Group'
  }
}

resource r_landingStorageRoleAssignmentPurview 'Microsoft.Authorization/roleAssignments@2022-04-01' = if (DeployPurview == 'True' && DeployLandingStorage == 'True') {
  name: guid(r_landingStorage.id, r_purview.id)
  scope: r_landingStorage
  properties:{
    roleDefinitionId: resourceId('Microsoft.Authorization/roleDefinitions', azureRBACStorageBlobDataReaderRoleID)
    principalId: (DeployPurview != 'True')?'':r_purview.identity.principalId
    principalType: 'ServicePrincipal'
  }
}

//cognitve services assignments
resource r_cognitiveService 'Microsoft.CognitiveServices/accounts@2022-10-01' existing = if (DeployCognitiveService == 'True') {
  name: cognitiveServiceName
}

module m_cognitive_service_datalake_rbac 'rbac_storage_account.bicep' = if (DeployCognitiveService == 'True' && DeployDataLake == 'True') {
  name: 'datalake_rbac'
  params: {
    azureResourceName: cognitiveServiceName
    storageAccountName: dataLakeName
    principalId: (DeployCognitiveService != 'True')?'':r_cognitiveService.identity.principalId
    roleId: azureRBACStorageBlobDataReaderRoleID
  }
}

module m_cognitive_service_landingstorage_rbac 'rbac_storage_account.bicep' = if (DeployCognitiveService == 'True' && DeployLandingStorage == 'True') {
  name: 'landingstorage_rbac'
  params: {
    azureResourceName: cognitiveServiceName
    storageAccountName: landingStorageName
    principalId: (DeployCognitiveService != 'True')?'':r_cognitiveService.identity.principalId
    roleId: azureRBACStorageBlobDataReaderRoleID
  }
}

//Cognitive Services User
var azureRBACCognitiveServicesUserRoleID = 'a97b65f3-24c7-4388-baec-2e87135dc908' 

resource r_CognitiveServicesUserRoleAssignment 'Microsoft.Authorization/roleAssignments@2022-04-01' = if (DeployCognitiveService == 'True') {
  name: guid(r_cognitiveService.id, Entra_Group_Shared_Service_Group_ID)
  scope: r_cognitiveService
  properties:{
    roleDefinitionId: resourceId('Microsoft.Authorization/roleDefinitions', azureRBACCognitiveServicesUserRoleID)
    principalId: Entra_Group_Shared_Service_Group_ID
    principalType: 'Group'
  }
}

// data factory role assignments
resource r_datafactory 'Microsoft.DataFactory/factories@2018-06-01' existing = if (DeployADF == 'True') {
  name: dataFactoryName
}

//Data Factory Contributor
var azureRBACDataFactoryContributorRoleID = '673868aa-7521-48a0-acc6-0f60742d39f5' 

//Grant Logic App a Role Assignment as Data Factory Contributor in Data Factory
resource r_adfLogicAppAssignment 'Microsoft.Authorization/roleAssignments@2022-04-01' = if (DeployLogicApp == 'True' && DeployADF == 'True') {
  name: guid(r_logicapp.id, r_datafactory.id)
  scope: r_datafactory
  properties:{
    roleDefinitionId: resourceId('Microsoft.Authorization/roleDefinitions', azureRBACDataFactoryContributorRoleID)
    principalId: (DeployLogicApp != 'True')?'':r_logicapp.identity.principalId
    principalType: 'ServicePrincipal'
  }
}

resource r_adfSharedServiceAssignment 'Microsoft.Authorization/roleAssignments@2022-04-01' = if (DeployADF == 'True') {
  name: guid(Entra_Group_Shared_Service_Group_ID, resourceGroup().name, azureRBACDataFactoryContributorRoleID)
  properties:{
    roleDefinitionId: resourceId('Microsoft.Authorization/roleDefinitions', azureRBACDataFactoryContributorRoleID)
    principalId: Entra_Group_Shared_Service_Group_ID
    principalType: 'Group'
  }
}

module m_adf_datalake_rbac 'rbac_storage_account.bicep' = if (DeployADF == 'True' && DeployDataLake == 'True') {
  name: 'm_adf_datalake_rbac'
  params: {
    azureResourceName: r_datafactory.name
    storageAccountName: dataLakeName
    principalId: (DeployADF != 'True')?'':r_datafactory.identity.principalId
    roleId: azureRBACStorageBlobDataContributorRoleID
  }
}

module m_adf_landingstorage_rbac 'rbac_storage_account.bicep' = if (DeployADF == 'True' && DeployLandingStorage == 'True') {
  name: 'm_adf_landingstorage_rbac'
  params: {
    azureResourceName: r_datafactory.name
    storageAccountName: landingStorageName
    principalId: (DeployADF != 'True')?'':r_datafactory.identity.principalId
    roleId: azureRBACStorageBlobDataContributorRoleID
  }
}

//Key Vault Secrets User
var azureRBACStorageKeyVaultSecretsUserRoleID = '4633458b-17de-408a-b874-0445c86b69e6' 

module m_adf_keyvault_rbac 'rbac_keyvault.bicep' = if (DeployADF == 'True' && DeployKeyVault == 'True') {
  name: 'm_adf_keyvault_rbac'
  params: {
    azureResourceName: r_datafactory.name
    keyVaultName: keyVaultName
    principalId: (DeployADF != 'True')?'':r_datafactory.identity.principalId
    roleId: azureRBACStorageKeyVaultSecretsUserRoleID
  }
}

module m_adf_cognitiveService_rbac 'rbac_cognitive_service_user.bicep' = if (DeployADF == 'True' && DeployCognitiveService == 'True') {
  name: 'm_adf_cognitiveService_rbac'
  params: {
    azureResourceName: r_datafactory.name
    cognitiveServiceName: cognitiveServiceName
    principalId: (DeployADF != 'True')?'':r_datafactory.identity.principalId
  }
}

//Synapse role assignments
resource r_synapseWorkspace 'Microsoft.Synapse/workspaces@2021-06-01' existing = if (DeploySynapse == 'True') {
  name: synapseWorkspaceName
}

module m_synapse_datalake_rbac 'rbac_storage_account.bicep' = if (DeploySynapse == 'True' && DeployDataLake == 'True') {
  name: 'm_synapse_datalake_rbac'
  params: {
    azureResourceName: synapseWorkspaceName
    storageAccountName: dataLakeName
    principalId: (DeploySynapse != 'True')?'':r_synapseWorkspace.identity.principalId
    roleId: azureRBACStorageBlobDataContributorRoleID
  }
}

module m_synapse_landing_storage_rbac 'rbac_storage_account.bicep' = if (DeploySynapse == 'True' && DeployLandingStorage == 'True') {
  name: 'synapse_landing_storage_rbac'
  params: {
    azureResourceName: synapseWorkspaceName
    storageAccountName: landingStorageName
    principalId: (DeploySynapse != 'True')?'':r_synapseWorkspace.identity.principalId
    roleId: azureRBACStorageBlobDataContributorRoleID
  }
}

module m_synapse_keyvault_rbac 'rbac_keyvault.bicep' = if (DeploySynapse == 'True' && DeployKeyVault == 'True') {
  name: 'keyvault_rbac'
  params: {
    azureResourceName: synapseWorkspaceName
    keyVaultName: keyVaultName
    principalId: (DeploySynapse != 'True')?'':r_synapseWorkspace.identity.principalId
    roleId: azureRBACStorageBlobDataContributorRoleID
  }
}

module m_synapse_cognitiveService_rbac 'rbac_cognitive_service_user.bicep' = if (DeploySynapse == 'True' && DeployCognitiveService == 'True') {
  name: 'm_synapse_rbac_cognitive_service_user'
  params: {
    azureResourceName: synapseWorkspaceName
    cognitiveServiceName: cognitiveServiceName
    principalId: (DeploySynapse != 'True')?'':r_synapseWorkspace.identity.principalId
  }
}

//Grant Purview as Reader on Synapse
resource r_synapseRoleAssignmentPurview 'Microsoft.Authorization/roleAssignments@2022-04-01' = if (DeployPurview == 'True' && DeploySynapse == 'True') {
  name: guid(r_synapseWorkspace.id, r_purview.id)
  scope: r_synapseWorkspace
  properties:{
    roleDefinitionId: resourceId('Microsoft.Authorization/roleDefinitions', azureRBACReaderRoleID)
    principalId: (DeployPurview != 'True')?'':r_purview.identity.principalId
    principalType:'ServicePrincipal'
  }
}


// event hub role assignments
resource r_eventHubNamespace 'Microsoft.EventHub/namespaces@2021-11-01' existing = if (DeployEventHubNamespace == 'True') {
  name: eventHubNamespaceName
}

//event Hubs Data Owner
var azureRBACEventHubDataOwnerRoleID = 'f526a384-b230-433a-b45c-95f59c4a2dec'

resource r_EventHubSharedServiceAssignment 'Microsoft.Authorization/roleAssignments@2022-04-01' = if (DeployEventHubNamespace == 'True') {
  name: guid(Entra_Group_Shared_Service_Group_ID, r_eventHubNamespace.id)
  scope: r_eventHubNamespace
  properties:{
    roleDefinitionId: resourceId('Microsoft.Authorization/roleDefinitions', azureRBACEventHubDataOwnerRoleID)
    principalId: Entra_Group_Shared_Service_Group_ID
    principalType: 'Group'
  }
}

module m_eventhub_landingstorage_rbac 'rbac_storage_account.bicep' = if (DeployEventHubNamespace == 'True' && DeployLandingStorage == 'True') {
  name: 'm_eventhub_landingstorage_rbac'
  params: {
    azureResourceName: eventHubNamespaceName
    storageAccountName: landingStorageName
    principalId: (DeployEventHubNamespace != 'True')?'':r_eventHubNamespace.identity.principalId
    roleId: azureRBACStorageBlobDataContributorRoleID
  }
}


//stream analytics role assignments
resource r_StreamAnalytics 'Microsoft.StreamAnalytics/StreamingJobs@2021-10-01-preview' existing = if (DeployStreamAnalytics == 'True') {
  name: streamAnalyticsName
}

resource r_StreamAnalyticsSharedServiceAssignment 'Microsoft.Authorization/roleAssignments@2022-04-01' = if (DeployStreamAnalytics == 'True') {
  name: guid(Entra_Group_Shared_Service_Group_ID, r_StreamAnalytics.id)
  scope: r_StreamAnalytics
  properties:{
    roleDefinitionId: resourceId('Microsoft.Authorization/roleDefinitions', azureRBACContributorRoleID)
    principalId: Entra_Group_Shared_Service_Group_ID
    principalType: 'Group'
  }
}

module m_stream_analytics_landing_storage_rbac 'rbac_storage_account.bicep' = if (DeployLandingStorage == 'True' && DeployStreamAnalytics == 'True') {
  name: 'stream_analytics_landing_storage_rbac'
  params: {
    azureResourceName: streamAnalyticsName
    storageAccountName: landingStorageName
    principalId: (DeployStreamAnalytics != 'True')?'':r_StreamAnalytics.identity.principalId
    roleId: azureRBACStorageBlobDataContributorRoleID
  }
}

//Grant Stream Analytics as Azure Event Hubs Data Sender to Event Hub
module m_stream_analytics_event_hub_owner_rbac 'rbac_event_hub_owner.bicep' = if (DeployEventHubNamespace == 'True' && DeployStreamAnalytics == 'True') {
  name: 'm_stream_analytics_event_hub_owner_rbac'
  params: {
    azureResourceName: streamAnalyticsName
    eventHubName: eventHubNamespaceName
    principalId: (DeployStreamAnalytics != 'True')?'':r_StreamAnalytics.identity.principalId
  }
}

//Grant ADF Contributor on Databricks Workspace
resource r_databricksWorkspace 'Microsoft.Databricks/workspaces@2023-02-01' existing = if (DeployDatabricks == 'True') {
  name: databricksWorkspaceName
}

resource r_ADFContributorOnDatabricks 'Microsoft.Authorization/roleAssignments@2022-04-01' = if (DeployADF == 'True' && DeployDatabricks == 'True') {
  name: guid(r_databricksWorkspace.id, r_datafactory.id, 'Contributor')
  scope: r_databricksWorkspace
  properties:{
    roleDefinitionId: resourceId('Microsoft.Authorization/roleDefinitions', azureRBACContributorRoleID)
    principalId: (DeployADF != 'True')?'':r_datafactory.identity.principalId
    principalType: 'ServicePrincipal'
  }
}

output synapseWorkspaceEntraId string = (DeploySynapse != 'True')?'':r_synapseWorkspace.identity.principalId
