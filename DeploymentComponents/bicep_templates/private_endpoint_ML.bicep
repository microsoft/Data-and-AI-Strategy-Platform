// Copyright (c) Microsoft Corporation.
// Licensed under the MIT license.
param location string
param VnetforPrivateEndpointsRgName string
param VnetforPrivateEndpointsName string
param PrivateEndpointSubnetName string
param UseManualPrivateLinkServiceConnections string
param DNS_ZONE_SUBSCRIPTION_ID string
param PrivateDNSZoneRgName string
param privateDnsZoneName1 string
param privateDnsZoneConfigsName1 string
param privateDnsZoneName2 string
param privateDnsZoneConfigsName2 string
param resourceName string
param resourceID string
param privateEndpointgroupIds array
param PrivateEndpointId string

param mlStorageName string
param mlWorkspacePrincipalId string

var peName = 'pep-${PrivateEndpointId}-${location}-${resourceName}-${first(privateEndpointgroupIds)}'

var privateLinkServiceConnections = [
  {
    name: peName
    properties: {
      privateLinkServiceId: resourceID
      groupIds: privateEndpointgroupIds
    }
  }
]

resource r_vnet 'Microsoft.Network/virtualNetworks@2022-01-01' existing = {
  scope: resourceGroup(VnetforPrivateEndpointsRgName)
  name: VnetforPrivateEndpointsName
}

resource r_PrivateDNSZone1 'Microsoft.Network/privateDnsZones@2020-06-01' existing = {
  scope: resourceGroup(DNS_ZONE_SUBSCRIPTION_ID, PrivateDNSZoneRgName)
  name: privateDnsZoneName1
}

resource r_PrivateDNSZone2 'Microsoft.Network/privateDnsZones@2020-06-01' existing = {
  scope: resourceGroup(DNS_ZONE_SUBSCRIPTION_ID, PrivateDNSZoneRgName)
  name: privateDnsZoneName2
}


resource r_PrivateEndpoint 'Microsoft.Network/privateEndpoints@2021-05-01' = {
  name: peName
  location: location
  properties: {
    subnet: {
      id: '${r_vnet.id}/subnets/${PrivateEndpointSubnetName}'
    }
    customNetworkInterfaceName: '${peName}-nic'
    privateLinkServiceConnections: (UseManualPrivateLinkServiceConnections == 'True')?null:privateLinkServiceConnections
    manualPrivateLinkServiceConnections: (UseManualPrivateLinkServiceConnections == 'False')?null:privateLinkServiceConnections
  }
  tags: {
  }
  dependsOn: [

  ]
}


resource r_PrivateEndpointZoneGroup 'Microsoft.Network/privateEndpoints/privateDnsZoneGroups@2021-05-01' = {
  parent: r_PrivateEndpoint
  name: 'default'
  properties: {
    privateDnsZoneConfigs: [
      {
        name: privateDnsZoneConfigsName1
        properties: {
          privateDnsZoneId: r_PrivateDNSZone1.id
        }
      }
      {
        name: privateDnsZoneConfigsName2
        properties: {
          privateDnsZoneId: r_PrivateDNSZone2.id
        }
      }
    ]
  }
  dependsOn: [
  ]
}

//Grant Azure ML Workspace as Reader on Workspace Storage PE's
var azureRBACReaderRoleID = 'acdd72a7-3385-48ef-bd42-f606fba81ae7'

resource r_PrivateEndpoint_blob 'Microsoft.Network/privateEndpoints@2021-05-01' existing = {
  name: 'pep-${PrivateEndpointId}-${location}-${mlStorageName}-blob'
}

resource r_PrivateEndpoint_file 'Microsoft.Network/privateEndpoints@2021-05-01' existing = {
  name: 'pep-${PrivateEndpointId}-${location}-${mlStorageName}-file'
}

resource r_PrivateEndpoint_queue 'Microsoft.Network/privateEndpoints@2021-05-01' existing = {
  name: 'pep-${PrivateEndpointId}-${location}-${mlStorageName}-queue'
}

resource r_PrivateEndpoint_table 'Microsoft.Network/privateEndpoints@2021-05-01' existing = {
  name: 'pep-${PrivateEndpointId}-${location}-${mlStorageName}-table'
}

resource r_mlWorkspace_BlobPE_Reader 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid(r_PrivateEndpoint_blob.id, resourceID)
  scope: r_PrivateEndpoint_blob
  properties:{
    roleDefinitionId: resourceId('Microsoft.Authorization/roleDefinitions', azureRBACReaderRoleID)
    principalId: mlWorkspacePrincipalId
    principalType:'ServicePrincipal'
  }
}

resource r_mlWorkspace_FilePE_Reader 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid(r_PrivateEndpoint_file.id, resourceID)
  scope: r_PrivateEndpoint_file
  properties:{
    roleDefinitionId: resourceId('Microsoft.Authorization/roleDefinitions', azureRBACReaderRoleID)
    principalId: mlWorkspacePrincipalId
    principalType:'ServicePrincipal'
  }
}

resource r_mlWorkspace_QueuePE_Reader 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid(r_PrivateEndpoint_queue.id, resourceID)
  scope: r_PrivateEndpoint_queue
  properties:{
    roleDefinitionId: resourceId('Microsoft.Authorization/roleDefinitions', azureRBACReaderRoleID)
    principalId: mlWorkspacePrincipalId
    principalType:'ServicePrincipal'
  }
}

resource r_mlWorkspace_TablePE_Reader 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid(r_PrivateEndpoint_table.id, resourceID)
  scope: r_PrivateEndpoint_table
  properties:{
    roleDefinitionId: resourceId('Microsoft.Authorization/roleDefinitions', azureRBACReaderRoleID)
    principalId: mlWorkspacePrincipalId
    principalType:'ServicePrincipal'
  }
}
