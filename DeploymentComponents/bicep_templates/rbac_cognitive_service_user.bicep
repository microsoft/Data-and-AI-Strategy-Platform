// Copyright (c) Microsoft Corporation.
// Licensed under the MIT license.
param cognitiveServiceName string

param azureResourceName string 

param principalId string = ''

var azureRBACCognitiveServicesUserRoleID = 'a97b65f3-24c7-4388-baec-2e87135dc908' //Cognitive Services User

resource r_cognitiveService 'Microsoft.CognitiveServices/accounts@2022-10-01' existing = {
  name: cognitiveServiceName
}

resource r_CognitiveServicesUserRoleAssignment 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid(azureResourceName, principalId, r_cognitiveService.id)
  scope: r_cognitiveService
  properties:{
    roleDefinitionId: resourceId('Microsoft.Authorization/roleDefinitions', azureRBACCognitiveServicesUserRoleID)
    principalId: principalId
    principalType:'ServicePrincipal'
  }
}
