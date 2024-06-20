// Copyright (c) Microsoft Corporation.
// Licensed under the MIT license.
@description('Location for all resources.')
param location string = resourceGroup().location

@description('Public Networking Access')
param DeployResourcesWithPublicAccess string 

@description('The name of the Azure Databricks workspace to create.')
param databricksWorkspaceName string

@description('The pricing tier of workspace.')
@allowed([
  'standard'
  'premium'
])
param pricingTier string = 'premium'

param tags string

var tagsObject = json(tags)

//logging
param DeployLogAnalytics string
param logAnalyticsRG string
param logAnalyticsName string

//vnet integration
param DeployWithCustomNetworking string
param CreatePrivateEndpoints string
param CreatePrivateEndpointsInSameRgAsResource string
param UseManualPrivateLinkServiceConnections string
param VnetforPrivateEndpointsRgName string
param VnetforPrivateEndpointsName string
param PrivateEndpointSubnetName string
param PrivateEndpointId string

param DeployDatabricksInVnet string
param VnetForDatabricksRgName string
param VnetForDatabricksName string
param DatabricksPrivateSubnetName string
param DatabricksPublicSubnetName string

param VnetForDatabricksTransitSubscriptionId string
param VnetForDatabricksTransitRgName string
param VnetForDatabricksTransitName string
param DatabricksTransitPESubnetName string

//dns zone
@secure()
param DNS_ZONE_SUBSCRIPTION_ID string
param PrivateDNSZoneRgName string
var privateDnsZoneName = 'privatelink.azuredatabricks.net'

var PeIntegration = (DeployWithCustomNetworking == 'True' && CreatePrivateEndpoints == 'True')?true:false
var DatabricksInVnet = (DeployWithCustomNetworking == 'True' && DeployDatabricksInVnet == 'True')?true:false
var publicNetworkAccessForWorkspace = (DeployResourcesWithPublicAccess == 'True')?'Enabled':'Disabled'
var privateEndpointRg = (CreatePrivateEndpointsInSameRgAsResource == 'True')?resourceGroup().name:VnetforPrivateEndpointsRgName

var managedResourceGroupName = 'databricks-rg-${databricksWorkspaceName}-${uniqueString(databricksWorkspaceName, resourceGroup().id)}'

resource managedResourceGroup 'Microsoft.Resources/resourceGroups@2021-04-01' existing = {
  scope: subscription()
  name: managedResourceGroupName
}

var requiredNsgRules = (DeployWithCustomNetworking == 'True' && CreatePrivateEndpoints == 'True')?'NoAzureDatabricksRules':'AllRules'

var VnetId = '/subscriptions/${subscription().subscriptionId}/resourceGroups/${VnetForDatabricksRgName}/providers/Microsoft.Network/virtualNetworks/${VnetForDatabricksName}'

var databricksParamsCustomNetworking = {
  customVirtualNetworkId: {
    value: VnetId
  }
  customPublicSubnetName: {
    value: DatabricksPublicSubnetName
  }
  customPrivateSubnetName: {
    value: DatabricksPrivateSubnetName
  }
  enableNoPublicIp: {
    value: (DeployResourcesWithPublicAccess == 'True') ? false : true
  }
}

var databricksParamsNoCustomNetworking = {
  enableNoPublicIp: {
    value: (DeployResourcesWithPublicAccess == 'True') ? false : true
  }
}

resource r_databricksWorkspace 'Microsoft.Databricks/workspaces@2023-02-01' = {
  name: databricksWorkspaceName
  location: location
  tags: tagsObject
  sku: {
    name: pricingTier
  }
  properties: {
    publicNetworkAccess: publicNetworkAccessForWorkspace
    requiredNsgRules: (DatabricksInVnet == false || DeployResourcesWithPublicAccess == 'True') ? null : requiredNsgRules
    managedResourceGroupId: managedResourceGroup.id
    parameters: (DatabricksInVnet) ? databricksParamsCustomNetworking : databricksParamsNoCustomNetworking
  }
}

resource r_loganalytics 'Microsoft.OperationalInsights/workspaces@2021-06-01' existing = if (DeployLogAnalytics == 'True') {
  scope: resourceGroup(logAnalyticsRG)
  name: logAnalyticsName
}

resource r_diagnostics 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = if (DeployLogAnalytics == 'True') {
  scope: r_databricksWorkspace
  name: '${databricksWorkspaceName}-diagnostic-loganalytics'
  properties: {
    workspaceId: r_loganalytics.id
    logs: [
      {
        categoryGroup: 'allLogs'
        enabled: true
      }
    ]
  }
}

module m_databricks_private_endpoints 'databricks_pe.bicep' = if (PeIntegration) {
  name: 'm_databricks_private_endpoints'
  scope: resourceGroup(privateEndpointRg)
  params: {
    location:location
    privateEndpointRg: privateEndpointRg
    VnetforPrivateEndpointsRgName: VnetforPrivateEndpointsRgName
    VnetforPrivateEndpointsName: VnetforPrivateEndpointsName
    PrivateEndpointSubnetName: PrivateEndpointSubnetName
    VnetForDatabricksTransitSubscriptionId: VnetForDatabricksTransitSubscriptionId
    VnetForDatabricksTransitRgName: VnetForDatabricksTransitRgName
    VnetForDatabricksTransitName: VnetForDatabricksTransitName
    DatabricksTransitPESubnetName: DatabricksTransitPESubnetName
    UseManualPrivateLinkServiceConnections: UseManualPrivateLinkServiceConnections
    DNS_ZONE_SUBSCRIPTION_ID: DNS_ZONE_SUBSCRIPTION_ID
    PrivateDNSZoneRgName: PrivateDNSZoneRgName
    privateDnsZoneName:privateDnsZoneName
    databricksWorkspaceName: databricksWorkspaceName
    r_databricksWorkspace_id: r_databricksWorkspace.id
    PrivateEndpointId: PrivateEndpointId
  }
}
