// Copyright (c) Microsoft Corporation.
// Licensed under the MIT license.
param location string
param databricksWorkspaceName string
param r_databricksWorkspace_id string
param PrivateEndpointId string
param privateEndpointRg string
param UseManualPrivateLinkServiceConnections string

//dns zone info
param DNS_ZONE_SUBSCRIPTION_ID string
param PrivateDNSZoneRgName string
param privateDnsZoneName string

//backend pe
param VnetforPrivateEndpointsRgName string
param VnetforPrivateEndpointsName string
param PrivateEndpointSubnetName string

//frontend pe
param VnetForDatabricksTransitSubscriptionId string 
param VnetForDatabricksTransitRgName string
param VnetForDatabricksTransitName string
param DatabricksTransitPESubnetName string


module m_databricks_backend_private_endpoint 'private_endpoint.bicep' = {
  name: 'm_databricks_backend_private_endpoint'
  scope: resourceGroup(privateEndpointRg)
  params: {
    location:location
    VnetforPrivateEndpointsRgName: VnetforPrivateEndpointsRgName
    VnetforPrivateEndpointsName: VnetforPrivateEndpointsName
    PrivateEndpointSubnetName: PrivateEndpointSubnetName
    UseManualPrivateLinkServiceConnections: UseManualPrivateLinkServiceConnections
    DNS_ZONE_SUBSCRIPTION_ID: DNS_ZONE_SUBSCRIPTION_ID
    PrivateDNSZoneRgName: PrivateDNSZoneRgName
    privateDnsZoneName:privateDnsZoneName
    privateDnsZoneConfigsName:replace(privateDnsZoneName,'.','-')
    resourceName: '${databricksWorkspaceName}-be'
    resourceID: r_databricksWorkspace_id
    privateEndpointgroupIds: [
      'databricks_ui_api'
    ]
    PrivateEndpointId: PrivateEndpointId
  }
}

module m_databricks_frontend_private_endpoint 'private_endpoint.bicep' = {
  name: 'm_databricks_frontend_private_endpoint'
  scope: resourceGroup(privateEndpointRg)
  params: {
    location:location
    VnetforPrivateEndpointsSubscriptionId: VnetForDatabricksTransitSubscriptionId
    VnetforPrivateEndpointsRgName: VnetForDatabricksTransitRgName
    VnetforPrivateEndpointsName: VnetForDatabricksTransitName
    PrivateEndpointSubnetName: DatabricksTransitPESubnetName
    UseManualPrivateLinkServiceConnections: UseManualPrivateLinkServiceConnections
    DNS_ZONE_SUBSCRIPTION_ID: DNS_ZONE_SUBSCRIPTION_ID
    PrivateDNSZoneRgName: PrivateDNSZoneRgName
    privateDnsZoneName:privateDnsZoneName
    privateDnsZoneConfigsName:replace(privateDnsZoneName,'.','-')
    resourceName: '${databricksWorkspaceName}-fe'
    resourceID: r_databricksWorkspace_id
    privateEndpointgroupIds: [
      'databricks_ui_api'
    ]
    PrivateEndpointId: PrivateEndpointId
  }
  dependsOn: [
    m_databricks_backend_private_endpoint
  ]
}

