// Copyright (c) Microsoft Corporation.
// Licensed under the MIT license.
param location string
param synapseWorkspaceName string
param synapseWorkspaceId string
param VnetforPrivateEndpointsRgName string
param VnetforPrivateEndpointsName string
param PrivateEndpointSubnetName string
param UseManualPrivateLinkServiceConnections string
param DNS_ZONE_SUBSCRIPTION_ID string
param PrivateDNSZoneRgName string
param PrivateEndpointId string

var devprivateDnsZoneName = 'privatelink.dev.azuresynapse.net'
var sqlprivateDnsZoneName = 'privatelink.sql.azuresynapse.net'

param DeploySynapseWebPrivateEndpoint string

//deploy Azure Private Endpoints
module m_synapse_dev_private_endpoint 'private_endpoint.bicep' = {
  name: 'synapse_dev_private_endpoint'
  params: {
    location:location
    VnetforPrivateEndpointsRgName: VnetforPrivateEndpointsRgName
    VnetforPrivateEndpointsName: VnetforPrivateEndpointsName
    PrivateEndpointSubnetName: PrivateEndpointSubnetName
    UseManualPrivateLinkServiceConnections: UseManualPrivateLinkServiceConnections
    DNS_ZONE_SUBSCRIPTION_ID: DNS_ZONE_SUBSCRIPTION_ID
    PrivateDNSZoneRgName: PrivateDNSZoneRgName
    privateDnsZoneName:devprivateDnsZoneName
    privateDnsZoneConfigsName:replace(devprivateDnsZoneName,'.','-')
    resourceName: synapseWorkspaceName
    resourceID: synapseWorkspaceId
    privateEndpointgroupIds: [
      'Dev'
    ]
    PrivateEndpointId: PrivateEndpointId
  }
}

module m_synapse_sql_private_endpoint 'private_endpoint.bicep' = {
  name: 'synapse_sql_private_endpoint'
  params: {
    location:location
    VnetforPrivateEndpointsRgName: VnetforPrivateEndpointsRgName
    VnetforPrivateEndpointsName: VnetforPrivateEndpointsName
    PrivateEndpointSubnetName: PrivateEndpointSubnetName
    UseManualPrivateLinkServiceConnections: UseManualPrivateLinkServiceConnections
    DNS_ZONE_SUBSCRIPTION_ID: DNS_ZONE_SUBSCRIPTION_ID
    PrivateDNSZoneRgName: PrivateDNSZoneRgName
    privateDnsZoneName:sqlprivateDnsZoneName
    privateDnsZoneConfigsName:replace(sqlprivateDnsZoneName,'.','-')
    resourceName: synapseWorkspaceName
    resourceID: synapseWorkspaceId
    privateEndpointgroupIds: [
      'Sql'
    ]
    PrivateEndpointId: PrivateEndpointId
  }
}

module m_synapse_sqlOnDemand_private_endpoint 'private_endpoint.bicep' = {
  name: 'synapse_sqlOnDemand_private_endpoint'
  params: {
    location:location
    VnetforPrivateEndpointsRgName: VnetforPrivateEndpointsRgName
    VnetforPrivateEndpointsName: VnetforPrivateEndpointsName
    PrivateEndpointSubnetName: PrivateEndpointSubnetName
    UseManualPrivateLinkServiceConnections: UseManualPrivateLinkServiceConnections
    DNS_ZONE_SUBSCRIPTION_ID: DNS_ZONE_SUBSCRIPTION_ID
    PrivateDNSZoneRgName: PrivateDNSZoneRgName
    privateDnsZoneName:sqlprivateDnsZoneName
    privateDnsZoneConfigsName:replace(sqlprivateDnsZoneName,'.','-')
    resourceName: synapseWorkspaceName
    resourceID: synapseWorkspaceId
    privateEndpointgroupIds: [
      'SqlOnDemand'
    ]
    PrivateEndpointId: PrivateEndpointId
  }
  dependsOn: [
    m_synapse_sql_private_endpoint
  ]
}

module m_synapsePrivateLinkHub 'synapse_privatelinkhub.bicep' = if (DeploySynapseWebPrivateEndpoint == 'True') {
  name: 'synapse_privatelinkhub'
  params: {
    location: location
    VnetforPrivateEndpointsRgName: VnetforPrivateEndpointsRgName
    VnetforPrivateEndpointsName: VnetforPrivateEndpointsName
    PrivateEndpointSubnetName: PrivateEndpointSubnetName
    UseManualPrivateLinkServiceConnections: UseManualPrivateLinkServiceConnections
    DNS_ZONE_SUBSCRIPTION_ID: DNS_ZONE_SUBSCRIPTION_ID
    PrivateDNSZoneRgName: PrivateDNSZoneRgName
    PrivateEndpointId: PrivateEndpointId
  }
}
