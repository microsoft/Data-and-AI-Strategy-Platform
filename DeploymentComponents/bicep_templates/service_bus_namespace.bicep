// Copyright (c) Microsoft Corporation.
// Licensed under the MIT license.
param location string = resourceGroup().location

param serviceBusNamespaceName string

param sku_name string

param disableLocalAuth bool

param zoneRedundant bool

param premiumMessagingPartitions int

param serviceBusNamespaceQueues array

@description('Public Networking Access')
param DeployResourcesWithPublicAccess string 

var publicNetworkAccess = (DeployResourcesWithPublicAccess == 'True'?'Enabled':'Disabled')

resource r_serviceBusNamespace 'Microsoft.ServiceBus/namespaces@2022-10-01-preview' = {
  name: serviceBusNamespaceName
  location: location
  sku: {
    name: sku_name
  }
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    disableLocalAuth: disableLocalAuth
    minimumTlsVersion: '1.2'
    premiumMessagingPartitions: premiumMessagingPartitions
    publicNetworkAccess: publicNetworkAccess
    zoneRedundant: zoneRedundant
  }
}

resource r_serviceBusNamespaceQueues 'Microsoft.ServiceBus/namespaces/queues@2022-10-01-preview' = [for serviceBusNamespaceQueue in serviceBusNamespaceQueues: {
  parent: r_serviceBusNamespace
  name: serviceBusNamespaceQueue.Name
  properties: {
    maxMessageSizeInKilobytes: 256
    lockDuration: 'PT30S'
    maxSizeInMegabytes: 1024
    requiresDuplicateDetection: false
    requiresSession: false
    defaultMessageTimeToLive: 'P14D'
    deadLetteringOnMessageExpiration: false
    enableBatchedOperations: true
    duplicateDetectionHistoryTimeWindow: 'PT10M'
    maxDeliveryCount: 10
    status: 'Active'
    enablePartitioning: false
    enableExpress: false
  }
}]
