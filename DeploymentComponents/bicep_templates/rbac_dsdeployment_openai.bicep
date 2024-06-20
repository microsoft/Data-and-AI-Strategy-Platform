// Copyright (c) Microsoft Corporation.
// Licensed under the MIT license.
param env string

param Service_Principal_Infra_Object_ID string

param Assign_RBAC_for_CICD_Service_Principal string

param Service_Principal_CICD_Object_ID string

param Entra_Group_Shared_Service_Group_ID string

param Entra_Group_Admin_Group_ID string

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

param OpenAIServiceName string

param OpenAICognitiveSearchName string

param PrimaryRgName string

param dataLakeName string

param DeployOpenAIDemoApp string

param appServiceName string

param keyVaultName string

param documentIntelligenceName string

// assign Contributor for CI/CD Sevrice Principal
var azureRBACContributorRoleID = 'b24988ac-6180-42a0-ab88-20f7382dd24c'

resource r_CICDServicePrincipalContributorAtRg 'Microsoft.Authorization/roleAssignments@2022-04-01' = if (Assign_RBAC_for_CICD_Service_Principal == 'True') {
  name: guid(Service_Principal_CICD_Object_ID, 'ContributorAtRG')
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

//Cognitive Services Contributor
var azureRBACognitiveServicesContributorRoleID = '25fbc0a9-bd7c-42a3-aa1a-3b75d497ee68'

resource r_OpenAIService 'Microsoft.CognitiveServices/accounts@2022-10-01' existing = {
  name: OpenAIServiceName
}

resource r_CognitiveServicesContributorSharedServices 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid(r_OpenAIService.id, Entra_Group_Shared_Service_Group_ID, azureRBACognitiveServicesContributorRoleID)
  scope: r_OpenAIService
  properties:{
    roleDefinitionId: resourceId('Microsoft.Authorization/roleDefinitions', azureRBACognitiveServicesContributorRoleID)
    principalId: Entra_Group_Shared_Service_Group_ID
    principalType: 'Group'
  }
}

resource r_OpenAICognitiveSearch 'Microsoft.Search/searchServices@2022-09-01' existing = {
  name: OpenAICognitiveSearchName
}

//Cognitive Services OpenAI Contributor
var azureRBACognitiveServicesOpenAIContributorRoleID = 'a001fd3d-188f-4b5d-821b-7da978bf7442'

resource r_CognitiveServicesOpenAIContributorOpenAI 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid(r_OpenAIService.id, r_OpenAICognitiveSearch.id, azureRBACognitiveServicesContributorRoleID)
  scope: r_OpenAIService
  properties:{
    roleDefinitionId: resourceId('Microsoft.Authorization/roleDefinitions', azureRBACognitiveServicesOpenAIContributorRoleID)
    principalId: r_OpenAICognitiveSearch.identity.principalId
    principalType: 'ServicePrincipal'
  }
}

resource r_ServicePrincipalOpenAIContributorOpenAI 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid(r_OpenAIService.id, Service_Principal_Infra_Object_ID, azureRBACognitiveServicesContributorRoleID)
  scope: r_OpenAIService
  properties:{
    roleDefinitionId: resourceId('Microsoft.Authorization/roleDefinitions', azureRBACognitiveServicesOpenAIContributorRoleID)
    principalId: Service_Principal_Infra_Object_ID
    principalType: 'ServicePrincipal'
  }
}

//Search Service Contributor
var azureRBACSearchServiceContributorRoleID = '7ca78c08-252a-4471-8644-bb5ff32d4ba0'

resource r_CognitiveSearchContributorSharedServices 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid(r_OpenAICognitiveSearch.id, Entra_Group_Shared_Service_Group_ID, azureRBACSearchServiceContributorRoleID)
  scope: r_OpenAICognitiveSearch
  properties:{
    roleDefinitionId: resourceId('Microsoft.Authorization/roleDefinitions', azureRBACSearchServiceContributorRoleID)
    principalId: Entra_Group_Shared_Service_Group_ID
    principalType: 'Group'
  }
}

resource r_CognitiveSearchContributorOpenAI 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid(r_OpenAICognitiveSearch.id, r_OpenAIService.id, azureRBACSearchServiceContributorRoleID)
  scope: r_OpenAICognitiveSearch
  properties:{
    roleDefinitionId: resourceId('Microsoft.Authorization/roleDefinitions', azureRBACSearchServiceContributorRoleID)
    principalId: r_OpenAIService.identity.principalId
    principalType: 'ServicePrincipal'
  }
}

//Search Index Data Contributor
var azureRBACSearchIndexDataContributorRoleID = '8ebe5a00-799e-43f5-93ac-243d3dce84a7'

resource r_CognitiveSearchIndexContributorSharedServices 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid(r_OpenAICognitiveSearch.id, Entra_Group_Shared_Service_Group_ID, azureRBACSearchIndexDataContributorRoleID)
  scope: r_OpenAICognitiveSearch
  properties:{
    roleDefinitionId: resourceId('Microsoft.Authorization/roleDefinitions', azureRBACSearchIndexDataContributorRoleID)
    principalId: Entra_Group_Shared_Service_Group_ID
    principalType: 'Group'
  }
}

resource r_CognitiveSearchIndexContributorServicePrincipalInfra 'Microsoft.Authorization/roleAssignments@2022-04-01' = if (DeployOpenAIDemoApp == 'True') {
  name: guid(r_OpenAICognitiveSearch.id, Service_Principal_Infra_Object_ID)
  scope: r_OpenAICognitiveSearch
  properties:{
    roleDefinitionId: resourceId('Microsoft.Authorization/roleDefinitions', azureRBACSearchIndexDataContributorRoleID)
    principalId: Service_Principal_Infra_Object_ID
    principalType: 'ServicePrincipal'
  }
}

//Search Index Data Reader
var azureRBACSearchIndexDataReaderRoleID = '1407120a-92aa-4202-b7e9-c0e197c71c8f'

resource r_CognitiveSearchIndexContributorOpenAI 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid(r_OpenAICognitiveSearch.id, r_OpenAIService.id, azureRBACSearchIndexDataContributorRoleID)
  scope: r_OpenAICognitiveSearch
  properties:{
    roleDefinitionId: resourceId('Microsoft.Authorization/roleDefinitions', azureRBACSearchIndexDataReaderRoleID)
    principalId: r_OpenAIService.identity.principalId
    principalType: 'ServicePrincipal'
  }
}

//Storage Blob Data Contributor Role
var azureRBACStorageBlobDataContributorRoleID = 'ba92f5b4-2d11-453d-a403-e96b0029c9fe' 

//Grant OpenAI Blob Storage Contributor to Data Lake
module m_OpenAiService_datalake_rbac 'rbac_storage_account.bicep' = if (DeployOpenAIDemoApp == 'True') {
  scope: resourceGroup(PrimaryRgName)
  name: 'OpenAiService_datalake_rbac'
  params: {
    azureResourceName: r_OpenAIService.name
    storageAccountName: dataLakeName
    principalId: r_OpenAIService.identity.principalId
    roleId: azureRBACStorageBlobDataContributorRoleID
  }
}

//Grant Cognitive Search Blob Storage Contributor to Data Lake
module r_CognitiveSearch_datalake_rbac 'rbac_storage_account.bicep' = if (DeployOpenAIDemoApp == 'True') {
  scope: resourceGroup(PrimaryRgName)
  name: 'CognitiveSearch_datalake_rbac'
  params: {
    azureResourceName: r_OpenAICognitiveSearch.name
    storageAccountName: dataLakeName
    principalId: r_OpenAICognitiveSearch.identity.principalId
    roleId: azureRBACStorageBlobDataContributorRoleID
  }
}


resource r_appService 'Microsoft.Web/sites@2022-03-01' existing = if (DeployOpenAIDemoApp == 'True') {
  name: appServiceName
}

//Key Vault Secrets User
var azureRBACStorageKeyVaultSecretsUserRoleID = '4633458b-17de-408a-b874-0445c86b69e6' 

//Grant App Service Key Vault Secret User
module r_appService_key_vault_rbac 'rbac_keyvault.bicep' = if (DeployOpenAIDemoApp == 'True') {
  name: 'appService_key_vault_rbac'
  params: {
    azureResourceName: appServiceName
    keyVaultName: keyVaultName
    principalId: r_appService.identity.principalId
    roleId: azureRBACStorageKeyVaultSecretsUserRoleID
  }
}

//Cognitive Services OpenAI User
var azureRbacCognitiveServicesOpenAIUserRoleId = '5e0bd9bd-7b93-4f28-af87-19fc36ad61bd'

resource r_appservice_cognitiveservicesuserRBAC 'Microsoft.Authorization/roleAssignments@2022-04-01' = if (DeployOpenAIDemoApp == 'True') {
  name: guid(r_appService.id, r_OpenAIService.id, azureRbacCognitiveServicesOpenAIUserRoleId)
  scope: r_OpenAIService
  properties:{
    roleDefinitionId: resourceId('Microsoft.Authorization/roleDefinitions', azureRbacCognitiveServicesOpenAIUserRoleId)
    principalId: r_appService.identity.principalId
    principalType: 'ServicePrincipal'
  }
}

//Storage Blob Data Reader Role
var azureRBACStorageBlobDataReaderRoleID = '2a2b9908-6ea1-4ae2-8e65-a410df84e7d1' 

//Grant App Service Blob Storage Reader to Data Lake
module r_appservice_datalake_rbac 'rbac_storage_account.bicep' = if (DeployOpenAIDemoApp == 'True') {
  scope: resourceGroup(PrimaryRgName)
  name: 'appservice_datalake_rbac'
  params: {
    azureResourceName: r_appService.name
    storageAccountName: dataLakeName
    principalId: r_appService.identity.principalId
    roleId: azureRBACStorageBlobDataReaderRoleID
  }
}

// Used to issue search queries
resource r_appservice_cognitiveSearchDataReaderRBAC 'Microsoft.Authorization/roleAssignments@2022-04-01' = if (DeployOpenAIDemoApp == 'True') {
  name: guid(r_appService.id, r_OpenAICognitiveSearch.id, azureRBACSearchIndexDataReaderRoleID)
  scope: r_OpenAICognitiveSearch
  properties:{
    roleDefinitionId: resourceId('Microsoft.Authorization/roleDefinitions', azureRBACSearchIndexDataReaderRoleID)
    principalId: r_appService.identity.principalId
    principalType: 'ServicePrincipal'
  }
}

// Used to read index definitions (required when using authentication)
module searchReaderRoleBackend 'rbac_resource_group.bicep' = if (DeployOpenAIDemoApp == 'True') {
  name: 'search-reader-role-backend'
  params: {
    principalId: r_appService.identity.principalId
    roleDefinitionId: azureRBACReaderRoleID
    principalType: 'ServicePrincipal'
  }
}

//cognitve services assignments
resource r_documentIntelligence 'Microsoft.CognitiveServices/accounts@2022-10-01' existing = if (DeployOpenAIDemoApp == 'True') {
  name: documentIntelligenceName
}

module m_document_intelligence_datalake_rbac 'rbac_storage_account.bicep' = if (DeployOpenAIDemoApp == 'True') {
  scope: resourceGroup(PrimaryRgName)
  name: 'document_intelligence_datalake_rbac'
  params: {
    azureResourceName: documentIntelligenceName
    storageAccountName: dataLakeName
    principalId: r_documentIntelligence.identity.principalId
    roleId: azureRBACStorageBlobDataReaderRoleID
  }
}

//Cognitive Services User
var azureRBACCognitiveServicesUserRoleID = 'a97b65f3-24c7-4388-baec-2e87135dc908' 

resource r_DocumentIntelligenceUserRoleAssignment 'Microsoft.Authorization/roleAssignments@2022-04-01' = if (DeployOpenAIDemoApp == 'True') {
  name: guid(r_documentIntelligence.id, Entra_Group_Shared_Service_Group_ID)
  scope: r_documentIntelligence
  properties:{
    roleDefinitionId: resourceId('Microsoft.Authorization/roleDefinitions', azureRBACCognitiveServicesUserRoleID)
    principalId: Entra_Group_Shared_Service_Group_ID
    principalType: 'Group'
  }
}

resource r_documentintelligenceServicePrincipalInfra 'Microsoft.Authorization/roleAssignments@2022-04-01' = if (DeployOpenAIDemoApp == 'True') {
  name: guid(r_documentIntelligence.id, Service_Principal_Infra_Object_ID)
  scope: r_documentIntelligence
  properties:{
    roleDefinitionId: resourceId('Microsoft.Authorization/roleDefinitions', azureRBACCognitiveServicesUserRoleID)
    principalId: Service_Principal_Infra_Object_ID
    principalType: 'ServicePrincipal'
  }
}

resource r_keyvault 'Microsoft.KeyVault/vaults@2021-11-01-preview' existing = {
  name: keyVaultName
}

//Grant Key Vault Secrets Officer to Admin Entra Group on Key Vault
//Key Vault Secrets Officer
var azureRBACKeyVaultSecretsOfficerRoleID = 'b86a8fe4-44ce-4948-aee5-eccb2c155cd7' 

resource r_keyVaultRoleAssignmentAdmin 'Microsoft.Authorization/roleAssignments@2022-04-01' = if (DeployOpenAIDemoApp == 'True') {
  name: guid(keyVaultName, Entra_Group_Admin_Group_ID)
  scope: r_keyvault
  properties:{
    roleDefinitionId: resourceId('Microsoft.Authorization/roleDefinitions', azureRBACKeyVaultSecretsOfficerRoleID)
    principalId: Entra_Group_Admin_Group_ID
    principalType: 'Group'
  }
}

resource r_keyVaultRoleAssignmentSharedServices 'Microsoft.Authorization/roleAssignments@2022-04-01' = if (env == 'dev' && Entra_Group_Shared_Service_Group_ID != Entra_Group_Admin_Group_ID && DeployOpenAIDemoApp == 'True') {
  name: guid(keyVaultName, Entra_Group_Shared_Service_Group_ID)
  scope: r_keyvault
  properties:{
    roleDefinitionId: resourceId('Microsoft.Authorization/roleDefinitions', azureRBACKeyVaultSecretsOfficerRoleID)
    principalId: Entra_Group_Shared_Service_Group_ID
    principalType: 'Group'
  }
}

//Grant Blob Storage Contributor to Service Principal so it can Upload Documents
module r_service_principal_datalake_rbac 'rbac_storage_account.bicep' = if (DeployOpenAIDemoApp == 'True') {
  scope: resourceGroup(PrimaryRgName)
  name: 'service_principal_datalake_rbac'
  params: {
    azureResourceName: 'ServicePrincipalInfra'
    storageAccountName: dataLakeName
    principalId: Service_Principal_Infra_Object_ID
    roleId: azureRBACStorageBlobDataContributorRoleID
  }
}
