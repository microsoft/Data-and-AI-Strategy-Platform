// Copyright (c) Microsoft Corporation.
// Licensed under the MIT license.
param location string = resourceGroup().location

param purviewName string

param tags string

var tagsObject = json(tags)

@description('Public Networking Access')
param DeployResourcesWithPublicAccess string 
var publicNetworkAccess = (DeployResourcesWithPublicAccess == 'True')?'Enabled':'Disabled'

//logging
param DeployLogAnalytics string
param logAnalyticsName string

//for private link setup
param ServicePrincipalHasOwnerRBACAtSubscription string
param DeployWithCustomNetworking string
param CreatePrivateEndpoints string
param CreatePrivateEndpointsInSameRgAsResource string
param UseManualPrivateLinkServiceConnections string
param VnetforPrivateEndpointsRgName string
param VnetforPrivateEndpointsName string
param PrivateEndpointSubnetName string
param DeployPurviewPrivateEndpoints string
param DeployPurviewIngestionPrivateEndpoints string
param PrivateEndpointId string

var vnetIntegration = (DeployWithCustomNetworking == 'True' && CreatePrivateEndpoints == 'True')?true:false
var privateEndpointRg = (CreatePrivateEndpointsInSameRgAsResource == 'True')?resourceGroup().name:VnetforPrivateEndpointsRgName

var ingestionUseManualPrivateLinkServiceConnections = (ServicePrincipalHasOwnerRBACAtSubscription=='True')?UseManualPrivateLinkServiceConnections:'True' 

//dns zone
@secure()
param DNS_ZONE_SUBSCRIPTION_ID string
param PrivateDNSZoneRgName string
var portalprivateDnsZoneName = 'privatelink.purviewstudio.azure.com'
var accountprivateDnsZoneName = 'privatelink.purview.azure.com'

resource r_purview 'Microsoft.Purview/accounts@2021-07-01' = {
    name: purviewName
    location: location
    tags: tagsObject
    identity: {
      type: 'SystemAssigned'
    }
    properties: {
      managedResourceGroupName: '${purviewName}-managed-rg'
      publicNetworkAccess: publicNetworkAccess
    }
}

resource r_loganalytics 'Microsoft.OperationalInsights/workspaces@2021-06-01' existing = if (DeployLogAnalytics == 'True') {
  name: logAnalyticsName
}

resource r_diagnostics 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = if (DeployLogAnalytics == 'True') {
  scope: r_purview
  name: 'purview-diagnostic-loganalytics'
  properties: {
    workspaceId: r_loganalytics.id
    logs: [
      {
        categoryGroup: 'audit'
        enabled: true
      }
      {
        categoryGroup: 'allLogs'
        enabled: true
      }
    ]
    metrics: [
      {
        category: 'AllMetrics'
        enabled: false
      }
    ]
  }
}


module m_purview_portal_endpoint 'private_endpoint.bicep' = if (vnetIntegration && DeployPurviewPrivateEndpoints == 'True') {
  name: 'purview_portal_endpoint'
  scope: resourceGroup(privateEndpointRg)
  params: {
    location:location
    VnetforPrivateEndpointsRgName: VnetforPrivateEndpointsRgName
    VnetforPrivateEndpointsName: VnetforPrivateEndpointsName
    PrivateEndpointSubnetName: PrivateEndpointSubnetName
    UseManualPrivateLinkServiceConnections: UseManualPrivateLinkServiceConnections
    DNS_ZONE_SUBSCRIPTION_ID: DNS_ZONE_SUBSCRIPTION_ID
    PrivateDNSZoneRgName: PrivateDNSZoneRgName
    privateDnsZoneName:portalprivateDnsZoneName
    privateDnsZoneConfigsName:replace(portalprivateDnsZoneName,'.','-')
    resourceName: purviewName
    resourceID: r_purview.id
    privateEndpointgroupIds: [
      'portal'
    ]
    PrivateEndpointId: PrivateEndpointId
  }
}


module m_purview_account_endpoint 'private_endpoint.bicep' = if (vnetIntegration && DeployPurviewPrivateEndpoints == 'True') {
  name: 'purview_account_endpoint'
  scope: resourceGroup(privateEndpointRg)
  params: {
    location:location
    VnetforPrivateEndpointsRgName: VnetforPrivateEndpointsRgName
    VnetforPrivateEndpointsName: VnetforPrivateEndpointsName
    PrivateEndpointSubnetName: PrivateEndpointSubnetName
    UseManualPrivateLinkServiceConnections: UseManualPrivateLinkServiceConnections
    DNS_ZONE_SUBSCRIPTION_ID: DNS_ZONE_SUBSCRIPTION_ID
    PrivateDNSZoneRgName: PrivateDNSZoneRgName
    privateDnsZoneName:accountprivateDnsZoneName
    privateDnsZoneConfigsName:replace(accountprivateDnsZoneName,'.','-')
    resourceName: purviewName
    resourceID: r_purview.id
    privateEndpointgroupIds: [
      'account'
    ]
    PrivateEndpointId: PrivateEndpointId
  }
}

var purviewStorageName = split(r_purview.properties.managedResources.storageAccount,'/')[length(split(r_purview.properties.managedResources.storageAccount,'/'))-1]
var blobprivateDnsZoneName = 'privatelink.blob.${environment().suffixes.storage}'
var queueprivateDnsZoneName = 'privatelink.queue.${environment().suffixes.storage}'

module m_purview_ingestion_blob_endpoint 'private_endpoint.bicep' = if (vnetIntegration && DeployPurviewIngestionPrivateEndpoints == 'True') {
  name: 'purview_ingestion_blob_endpoint'
  scope: resourceGroup(privateEndpointRg)
  params: {
    location:location
    VnetforPrivateEndpointsRgName: VnetforPrivateEndpointsRgName
    VnetforPrivateEndpointsName: VnetforPrivateEndpointsName
    PrivateEndpointSubnetName: PrivateEndpointSubnetName
    UseManualPrivateLinkServiceConnections: ingestionUseManualPrivateLinkServiceConnections
    DNS_ZONE_SUBSCRIPTION_ID: DNS_ZONE_SUBSCRIPTION_ID
    PrivateDNSZoneRgName: PrivateDNSZoneRgName
    privateDnsZoneName:blobprivateDnsZoneName
    privateDnsZoneConfigsName:replace(blobprivateDnsZoneName,'.','-')
    resourceName: purviewStorageName
    resourceID: r_purview.properties.managedResources.storageAccount
    privateEndpointgroupIds: [
      'blob'
    ]
    PrivateEndpointId: PrivateEndpointId
  }
}

module m_purview_ingestion_queue_endpoint 'private_endpoint.bicep' = if (vnetIntegration && DeployPurviewIngestionPrivateEndpoints == 'True') {
  name: 'purview_ingestion_queue_endpoint'
  scope: resourceGroup(privateEndpointRg)
  params: {
    location:location
    VnetforPrivateEndpointsRgName: VnetforPrivateEndpointsRgName
    VnetforPrivateEndpointsName: VnetforPrivateEndpointsName
    PrivateEndpointSubnetName: PrivateEndpointSubnetName
    UseManualPrivateLinkServiceConnections: ingestionUseManualPrivateLinkServiceConnections
    DNS_ZONE_SUBSCRIPTION_ID: DNS_ZONE_SUBSCRIPTION_ID
    PrivateDNSZoneRgName: PrivateDNSZoneRgName
    privateDnsZoneName:queueprivateDnsZoneName
    privateDnsZoneConfigsName:replace(queueprivateDnsZoneName,'.','-')
    resourceName: purviewStorageName
    resourceID: r_purview.properties.managedResources.storageAccount
    privateEndpointgroupIds: [
      'queue'
    ]
    PrivateEndpointId: PrivateEndpointId
  }
}

var purviewEventHubNamespaceName = split(r_purview.properties.managedResources.eventHubNamespace,'/')[length(split(r_purview.properties.managedResources.eventHubNamespace,'/'))-1]
var eventhubPrivateDnsZone='privatelink.servicebus.windows.net'

module m_purview_ingestion_eventhub_namespace_endpoint 'private_endpoint.bicep' = if (vnetIntegration && DeployPurviewIngestionPrivateEndpoints == 'True') {
  name: 'purview_ingestion_eventhub_namespace_endpoint'
  scope: resourceGroup(privateEndpointRg)
  params: {
    location:location
    VnetforPrivateEndpointsRgName: VnetforPrivateEndpointsRgName
    VnetforPrivateEndpointsName: VnetforPrivateEndpointsName
    PrivateEndpointSubnetName: PrivateEndpointSubnetName
    UseManualPrivateLinkServiceConnections: ingestionUseManualPrivateLinkServiceConnections
    DNS_ZONE_SUBSCRIPTION_ID: DNS_ZONE_SUBSCRIPTION_ID
    PrivateDNSZoneRgName: PrivateDNSZoneRgName
    privateDnsZoneName:eventhubPrivateDnsZone
    privateDnsZoneConfigsName:replace(eventhubPrivateDnsZone,'.','-')
    resourceName: purviewEventHubNamespaceName
    resourceID: r_purview.properties.managedResources.eventHubNamespace
    privateEndpointgroupIds: [
      'namespace'
    ]
    PrivateEndpointId: PrivateEndpointId
  }
}
