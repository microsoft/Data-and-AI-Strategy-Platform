// Copyright (c) Microsoft Corporation.
// Licensed under the MIT license.
param location string = resourceGroup().location

param containerRegistryName string

//resource parameters
param sku_name string
param adminUserEnabled bool
param dataEndpointEnabled bool
param zoneRedundancy string
param softDeleteEnabled string
param softDeleteRetentionDays int

//for private link setup
param DeployWithCustomNetworking string
param CreatePrivateEndpoints string
param CreatePrivateEndpointsInSameRgAsResource string
param UseManualPrivateLinkServiceConnections string
param VnetforPrivateEndpointsRgName string
param VnetforPrivateEndpointsName string
param PrivateEndpointSubnetName string
param PrivateEndpointId string

var vnetIntegration = (DeployWithCustomNetworking == 'True' && CreatePrivateEndpoints == 'True')?true:false
var privateEndpointRg = (CreatePrivateEndpointsInSameRgAsResource == 'True')?resourceGroup().name:VnetforPrivateEndpointsRgName

//dns zone
@secure()
param DNS_ZONE_SUBSCRIPTION_ID string
param PrivateDNSZoneRgName string
var privateDnsZoneName = 'privatelink${environment().suffixes.acrLoginServer}'

var sku_name_variable = (vnetIntegration)?'Premium':sku_name

@description('Public Networking Access')
param DeployResourcesWithPublicAccess string 

//ip firewall rules
param AllowAccessToIpRange string
param IpRangeCidr string
var ipRangeFilter = (DeployWithCustomNetworking == 'True' && AllowAccessToIpRange == 'True')?true:false

var publicNetworkAccess = (DeployResourcesWithPublicAccess == 'True' || ipRangeFilter)?'Enabled':'Disabled'
var defaultAction = (DeployResourcesWithPublicAccess == 'True' && ipRangeFilter == false)?'Allow':'Deny'

var networkRuleSet = {
  defaultAction: defaultAction
  ipRules: (ipRangeFilter==false)?null:[
    {
      action: 'Allow'
      value: IpRangeCidr
    }
  ]
}

resource r_mlContainerRegistry 'Microsoft.ContainerRegistry/registries@2022-02-01-preview' = {
  name: containerRegistryName
  location: location
  tags: {}
  sku: {
    name: sku_name_variable
  }
  properties: {
    adminUserEnabled: adminUserEnabled
    dataEndpointEnabled: dataEndpointEnabled
    publicNetworkAccess: publicNetworkAccess
    networkRuleSet: (sku_name_variable!='Premium')?null:networkRuleSet
    zoneRedundancy: (sku_name_variable!='Premium')?null:zoneRedundancy
    policies: (sku_name_variable!='Premium')?null:{
      softDeletePolicy: {
        status: softDeleteEnabled
        retentionDays: softDeleteRetentionDays
      }
    }
  }
}

module m_containerRegistry_private_endpoint 'private_endpoint.bicep' = if (vnetIntegration) {
  name: 'containerRegistry_private_endpoint'
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
    resourceName: containerRegistryName
    resourceID: r_mlContainerRegistry.id
    privateEndpointgroupIds: [
      'registry'
    ]
    PrivateEndpointId: PrivateEndpointId
  }
}

