// Copyright (c) Microsoft Corporation.
// Licensed under the MIT license.
@description('Location for all resources.')
param location string = resourceGroup().location

@description('Name of the EventHub namespace')
param eventHubNamespaceName string

@description('Name of the exiting Storage Account to archieve captures')
param landingStorageName string

@description('Your existing storage container that you want the blobs archived in')
param blobContainerName string = 'landing'

@description('The messaging tier for Event Hub namespace')
@allowed([
  'Standard'
])
param eventhubSku string = 'Standard'

@description('MessagingUnits for premium namespace')
@allowed([
  1
  2
  4
])
param skuCapacity int = 1

@description('Enable or disable AutoInflate')
param isAutoInflateEnabled bool = true

@description('Upper limit of throughput units when AutoInflate is enabled, vaule should be within 0 to 20 throughput units.')
@minValue(0)
@maxValue(20)
param maximumThroughputUnits int = 10

param minimumTlsVersion string = '1.2'

param kafkaEnabled bool

param createEventHubsOnDeployment bool

param eventHubs array

@description('Public Networking Access')
param DeployResourcesWithPublicAccess string 

param AllowAccessToIpRange string
param IpRangeCidr string
var ipRangeFilter = (DeployWithCustomNetworking == 'True' && AllowAccessToIpRange == 'True')?true:false

var publicNetworkAccess = (DeployResourcesWithPublicAccess == 'True' || ipRangeFilter)?'Enabled':'Disabled'
var defaultAction = (DeployResourcesWithPublicAccess == 'True' && ipRangeFilter == false)?'Allow':'Deny'

param trustedServiceAccessEnabled bool = true 

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
var eventhubPrivateDnsZone='privatelink.servicebus.windows.net'

resource r_eventHubNamespace 'Microsoft.EventHub/namespaces@2021-11-01' = {
  name: eventHubNamespaceName
  location: location
  identity: {
    type: 'SystemAssigned'
  }
  sku: {
    name: eventhubSku
    tier: eventhubSku
    capacity: skuCapacity
  }
  properties: {
    isAutoInflateEnabled: isAutoInflateEnabled
    maximumThroughputUnits: maximumThroughputUnits
    kafkaEnabled: kafkaEnabled
  }
}

resource r_eventHubNetworkRuleSets 'Microsoft.EventHub/namespaces/networkRuleSets@2021-11-01' = {
  name: 'default'
  parent: r_eventHubNamespace
  properties: {
    defaultAction: defaultAction
    ipRules: (ipRangeFilter==false)?null:[
      {
        action: 'Allow'
        ipMask: IpRangeCidr
      }
    ]
    publicNetworkAccess: publicNetworkAccess
    trustedServiceAccessEnabled: trustedServiceAccessEnabled
  }
}

resource r_blobStorage 'Microsoft.Storage/storageAccounts@2021-08-01' existing = {
  name: landingStorageName
}


resource r_eventHubNamespace_eventHub 'Microsoft.EventHub/Namespaces/eventhubs@2021-11-01' = [for eventHub in eventHubs: if (createEventHubsOnDeployment) {
  parent: r_eventHubNamespace
  name: eventHub.eventHubName
  properties: {
    messageRetentionInDays: eventHub.messageRetentionInDays
    partitionCount: eventHub.partitionCount
    captureDescription: (eventHub.enableCapture==false)?null:{
      enabled: eventHub.captureEnabled
      skipEmptyArchives: eventHub.skipEmptyArchives
      encoding: 'Avro'
      intervalInSeconds: eventHub.captureTime
      sizeLimitInBytes: eventHub.captureSize
      destination: {
        name: 'EventHubArchive.AzureBlockBlob'
        properties: {
          storageAccountResourceId: r_blobStorage.id
          blobContainer: blobContainerName
          archiveNameFormat: eventHub.captureNameFormat
        }
      }
    }
  }
}]

module m_eventhub_private_endpoint 'private_endpoint.bicep' = if (vnetIntegration) {
  name: 'eventhub_private_endpoint'
  scope: resourceGroup(privateEndpointRg)
  params: {
    location:location
    VnetforPrivateEndpointsRgName: VnetforPrivateEndpointsRgName
    VnetforPrivateEndpointsName: VnetforPrivateEndpointsName
    PrivateEndpointSubnetName: PrivateEndpointSubnetName
    UseManualPrivateLinkServiceConnections: UseManualPrivateLinkServiceConnections
    DNS_ZONE_SUBSCRIPTION_ID: DNS_ZONE_SUBSCRIPTION_ID
    PrivateDNSZoneRgName: PrivateDNSZoneRgName
    privateDnsZoneName:eventhubPrivateDnsZone
    privateDnsZoneConfigsName:replace(eventhubPrivateDnsZone,'.','-')
    resourceName: eventHubNamespaceName
    resourceID: r_eventHubNamespace.id
    privateEndpointgroupIds: [
      'namespace'
    ]
    PrivateEndpointId: PrivateEndpointId
  }
}
