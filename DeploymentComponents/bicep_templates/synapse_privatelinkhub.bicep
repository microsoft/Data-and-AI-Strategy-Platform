// Copyright (c) Microsoft Corporation.
// Licensed under the MIT license.
param location string

param VnetforPrivateEndpointsRgName string
param VnetforPrivateEndpointsName string
param PrivateEndpointSubnetName string
param UseManualPrivateLinkServiceConnections string
param DNS_ZONE_SUBSCRIPTION_ID string
param PrivateDNSZoneRgName string
param PrivateEndpointId string

var privatelinkhubprivateDnsZoneName = 'privatelink.azuresynapse.net'

resource r_synapsePrivateLinkHub 'Microsoft.Synapse/privateLinkHubs@2021-06-01' = {
  name: '${replace(VnetforPrivateEndpointsName,'-','')}synplhub'
  location: location
}

module r_PrivateLinkHub_private_endpoint 'private_endpoint.bicep' = {
  name: 'synapse_privatelinkhub_private_endpoint'
  params: {
    location:location
    VnetforPrivateEndpointsRgName: VnetforPrivateEndpointsRgName
    VnetforPrivateEndpointsName: VnetforPrivateEndpointsName
    PrivateEndpointSubnetName: PrivateEndpointSubnetName
    UseManualPrivateLinkServiceConnections: UseManualPrivateLinkServiceConnections
    DNS_ZONE_SUBSCRIPTION_ID: DNS_ZONE_SUBSCRIPTION_ID
    PrivateDNSZoneRgName: PrivateDNSZoneRgName
    privateDnsZoneName:privatelinkhubprivateDnsZoneName
    privateDnsZoneConfigsName:replace(privatelinkhubprivateDnsZoneName,'.','-')
    resourceName: r_synapsePrivateLinkHub.name
    resourceID: r_synapsePrivateLinkHub.id
    privateEndpointgroupIds: [
      'Web'
    ]
    PrivateEndpointId: PrivateEndpointId
  }
  dependsOn: [
    r_synapsePrivateLinkHub
  ]
}
