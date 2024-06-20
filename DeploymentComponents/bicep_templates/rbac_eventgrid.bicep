// Copyright (c) Microsoft Corporation.
// Licensed under the MIT license.
param eventGridName string

param azureResourceName string 

param principalId string = ''

var azureRBACStorageEventGridDataSenderRoleID = 'd5a91429-5739-47e2-a06b-3470a27159e7' //EventGrid Data Sender

resource r_eventgrid 'Microsoft.EventGrid/topics@2021-12-01' existing = {
  name: eventGridName
}

//Grant Azure Resource a Role Assignment as EventGrid Data Sender in the Event Grid
//https://docs.microsoft.com/en-us/azure/synapse-analytics/security/how-to-grant-workspace-managed-identity-permissions
resource r_eventGridRoleAssignment 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid(azureResourceName, eventGridName)
  scope: r_eventgrid
  properties:{
    roleDefinitionId: resourceId('Microsoft.Authorization/roleDefinitions', azureRBACStorageEventGridDataSenderRoleID)
    principalId: principalId
    principalType:'ServicePrincipal'
  }
}
