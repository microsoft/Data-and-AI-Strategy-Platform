// Copyright (c) Microsoft Corporation.
// Licensed under the MIT license.
param eventHubName string

param azureResourceName string 

param principalId string = ''

var azureRBACEventHubsDataOwnerRoleID = 'f526a384-b230-433a-b45c-95f59c4a2dec' //Azure Event Hubs Data Owner

resource r_eventHub 'Microsoft.EventHub/namespaces@2021-11-01' existing = {
  name: eventHubName
}

//Grant Azure Resource a Role Assignment as Azure Event Hubs Data Owner in the Event Hub Namespace
resource r_eventHubRoleAssignment 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid(azureResourceName, eventHubName)
  scope: r_eventHub
  properties:{
    roleDefinitionId: resourceId('Microsoft.Authorization/roleDefinitions', azureRBACEventHubsDataOwnerRoleID)
    principalId: principalId
    principalType:'ServicePrincipal'
  }
}
