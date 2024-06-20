// Copyright (c) Microsoft Corporation.
// Licensed under the MIT license.
param aksClusterName string

param aksPrincipalId string

param vnetName string

var azureRBACNetworkContributorRoleID = '4d97b98b-1d4f-4787-a291-c67834d212e7'

resource r_vnet 'Microsoft.Network/virtualNetworks@2022-01-01' existing = {
  name: vnetName
}

resource r_akssubnet 'Microsoft.Network/virtualNetworks/subnets@2022-01-01' existing = {
  parent: r_vnet
  name: 'mlAksSubnet'
}


resource r_RBACNetworkContributor 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid(aksClusterName, '${r_vnet.id}/mlAksSubnet')
  scope: r_akssubnet
  properties: {
    roleDefinitionId: resourceId('Microsoft.Authorization/roleDefinitions', azureRBACNetworkContributorRoleID)
    principalId: aksPrincipalId
    principalType: 'ServicePrincipal'
  }
}
