// Copyright (c) Microsoft Corporation.
// Licensed under the MIT license.
param Assign_RBAC_for_CICD_Service_Principal string

param Service_Principal_CICD_Object_ID string

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

param logicAppName string

param PrimaryRgName string

param DeployLandingStorage string

param landingStorageName string

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

//Assign logic app standard developer RBAC role to shared service group
resource r_LogicApp 'Microsoft.Web/sites@2022-03-01' existing = {
  name: logicAppName
}

var azureRBACLogicAppStandardDeveloperRoleID = '523776ba-4eb2-4600-a3c8-f2dc93da4bdb'

resource r_logicAppSharedServiceAssignment 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid('shared_services', r_LogicApp.id)
  scope: r_LogicApp
  properties:{
    roleDefinitionId: resourceId('Microsoft.Authorization/roleDefinitions', azureRBACLogicAppStandardDeveloperRoleID)
    principalId: Entra_Group_Shared_Service_Group_ID
    principalType: 'Group'
  }
}

// Storage Blob Data Contributor Role
var azureRBACStorageBlobDataContributorRoleID = 'ba92f5b4-2d11-453d-a403-e96b0029c9fe' 

module storageAccount_rbac 'rbac_storage_account.bicep' = if (DeployLandingStorage == 'True') {
  scope: resourceGroup(PrimaryRgName)
  name: 'storageAccount_rbac'
  params: {
    azureResourceName: r_LogicApp.name
    storageAccountName: landingStorageName
    principalId: r_LogicApp.identity.principalId
    roleId: azureRBACStorageBlobDataContributorRoleID
  }
}
