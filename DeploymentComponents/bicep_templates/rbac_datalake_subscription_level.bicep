// Copyright (c) Microsoft Corporation.
// Licensed under the MIT license.
// set the target scope for this file
targetScope = 'subscription'

param purviewName string

param purviewPrincipalId string

var azureRBACStorageBlobDataReaderRoleID = '2a2b9908-6ea1-4ae2-8e65-a410df84e7d1' //Storage Blob Data Reader Role

//Grant Blob Storage Reader to Purview on Storage Account
//https://docs.microsoft.com/en-us/azure/synapse-analytics/security/how-to-grant-workspace-managed-identity-permissions
resource r_dataLakeRoleAssignmentPurview 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid(purviewName, subscription().id)
  properties:{
    roleDefinitionId: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', azureRBACStorageBlobDataReaderRoleID)
    principalId: purviewPrincipalId
    principalType:'ServicePrincipal'
  }
}
