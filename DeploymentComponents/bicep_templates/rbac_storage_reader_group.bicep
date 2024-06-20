// Copyright (c) Microsoft Corporation.
// Licensed under the MIT license.
param storageAccountName string

param azureResourceName string 

param principalId string = ''

var azureRBACStorageBlobDataReaderRoleID = '2a2b9908-6ea1-4ae2-8e65-a410df84e7d1' //Storage Blob Data Reader Role

resource r_datalake 'Microsoft.Storage/storageAccounts@2021-08-01' existing = {
  name: storageAccountName
}

//Grant Azure Resource a Role Assignment as Blob Data Reader Role in the Data Lake Storage Account
resource r_dataLakeRoleAssignment 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid(r_datalake.id, azureResourceName)
  scope: r_datalake
  properties:{
    roleDefinitionId: resourceId('Microsoft.Authorization/roleDefinitions', azureRBACStorageBlobDataReaderRoleID)
    principalId: principalId
    principalType:'Group'
  }
}
