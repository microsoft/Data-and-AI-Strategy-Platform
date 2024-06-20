// Copyright (c) Microsoft Corporation.
// Licensed under the MIT license.
param storageAccountName string

param azureResourceName string 

param principalId string = ''

param roleId string

resource r_datalake 'Microsoft.Storage/storageAccounts@2021-08-01' existing = {
  name: storageAccountName
}

//Grant Azure Resource a Role Assignment as Blob Data Contributor Role in the Data Lake Storage Account
//https://docs.microsoft.com/en-us/azure/synapse-analytics/security/how-to-grant-workspace-managed-identity-permissions
resource r_dataLakeRoleAssignment 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid(azureResourceName, principalId, r_datalake.id)
  scope: r_datalake
  properties:{
    roleDefinitionId: resourceId('Microsoft.Authorization/roleDefinitions', roleId)
    principalId: principalId
    principalType:'ServicePrincipal'
  }
}
