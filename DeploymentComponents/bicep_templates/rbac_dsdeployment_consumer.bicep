// Copyright (c) Microsoft Corporation.
// Licensed under the MIT license.
param Assign_RBAC_for_CICD_Service_Principal string
param Service_Principal_CICD_Object_ID string
param Entra_Group_Admin_Group_ID string
param Entra_Group_for_Consumer_ID string
param DeployNewSynapse string
param NewSynapseWorkspaceName string
param dataLakeName string
param DeployNewConsumerMlWorkspace string
param NewMlWorkspaceName string
param PrimaryRgName string


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

resource r_ConsumerGroupReaderAtRg 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid(Entra_Group_for_Consumer_ID, 'ReaderAtRG', resourceGroup().name)
  properties:{
    roleDefinitionId: resourceId('Microsoft.Authorization/roleDefinitions', azureRBACReaderRoleID)
    principalId: Entra_Group_for_Consumer_ID
    principalType: 'Group'
  }
}

//Synapse role assignments
resource r_synapseWorkspace 'Microsoft.Synapse/workspaces@2021-06-01' existing = if (DeployNewSynapse == 'True') {
  name: NewSynapseWorkspaceName
}

module m_synapse_datalake_rbac 'rbac_storage_reader.bicep' = if (DeployNewSynapse == 'True') {
  scope: resourceGroup(PrimaryRgName)
  name: 'm_rbac_storage_reader'
  params: {
    azureResourceName: NewSynapseWorkspaceName
    storageAccountName: dataLakeName
    principalId: (DeployNewSynapse != 'True')?'':r_synapseWorkspace.identity.principalId
  }
}

module m_writer_on_curated_for_consumersynapse 'rbac_storage_contrib_container.bicep' = if (DeployNewSynapse == 'True') {
  scope: resourceGroup(PrimaryRgName)
  name: 'm_writer_on_curated_for_consumersynapse'
  params: {
    azureResourceName: r_synapseWorkspace.identity.principalId
    storageAccountName: dataLakeName
    containerName: 'curated'
    principalId: (DeployNewSynapse != 'True')?'':r_synapseWorkspace.identity.principalId
    principalType: 'ServicePrincipal'
  }
}



//Azure ML Role Assignments
resource r_mlworkspace 'Microsoft.MachineLearningServices/workspaces@2023-06-01-preview' existing = if (DeployNewConsumerMlWorkspace == 'True') {
  name: NewMlWorkspaceName
}

//assign data scientist role to shared service group and producer groups
var azureRBACMlDataScientistRoleID = 'f6c7c914-8db3-469d-8ca1-694a8f32e121'

resource r_AzureMlProducerSharedServicesAssignment 'Microsoft.Authorization/roleAssignments@2022-04-01' = if (DeployNewConsumerMlWorkspace == 'True') {
  name: guid('consumer_group', r_mlworkspace.name)
  scope: r_mlworkspace
  properties:{
    roleDefinitionId: resourceId('Microsoft.Authorization/roleDefinitions', azureRBACMlDataScientistRoleID)
    principalId: Entra_Group_for_Consumer_ID
    principalType: 'Group'
  }
}

//rbac_storage_reader_group
module m_reader_on_storage_account_for_consumergroup 'rbac_storage_reader_group.bicep' = {
  scope: resourceGroup(PrimaryRgName)
  name: 'm_reader_on_storage_account_for_consumergroup'
  params: {
    azureResourceName: Entra_Group_for_Consumer_ID
    storageAccountName: dataLakeName
    principalId: Entra_Group_for_Consumer_ID
  }
}

module m_writer_on_curated_for_consumergroup 'rbac_storage_contrib_container.bicep' = {
  scope: resourceGroup(PrimaryRgName)
  name: 'm_writer_on_curated_for_consumergroup'
  params: {
    azureResourceName: Entra_Group_for_Consumer_ID
    storageAccountName: dataLakeName
    containerName: 'curated'
    principalId: Entra_Group_for_Consumer_ID
    principalType: 'Group'
  }
}

//Grant Synapse Contributor Rights on Azure Machine Learning
//https://docs.microsoft.com/en-us/azure/synapse-analytics/security/how-to-grant-workspace-managed-identity-permissions
resource r_synapseContribRoleAssignment 'Microsoft.Authorization/roleAssignments@2022-04-01' = if (DeployNewSynapse == 'True') {
  name: guid(r_mlworkspace.name, r_synapseWorkspace.name)
  scope: r_mlworkspace
  properties:{
    roleDefinitionId: resourceId('Microsoft.Authorization/roleDefinitions', azureRBACContributorRoleID)
    principalId: (DeployNewSynapse != 'True')?'':r_synapseWorkspace.identity.principalId
    principalType:'ServicePrincipal'
  }
}
