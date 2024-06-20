// Copyright (c) Microsoft Corporation.
// Licensed under the MIT license.
param location string = resourceGroup().location

param functionAppName string

param functionAppServicePlanName string

param functionAppInsightsName string

param functionAppStorageName string

param kind string

param linuxFxVersion string

param numberOfWorkers int
param alwaysOn bool
param http20Enabled bool
param minimumElasticInstanceCount int

//vnet integration
param DeployWithCustomNetworking string
param CreatePrivateEndpoints string
param CreatePrivateEndpointsInSameRgAsResource string
param UseManualPrivateLinkServiceConnections string
param VnetforPrivateEndpointsRgName string
param VnetforPrivateEndpointsName string
param PrivateEndpointSubnetName string
param PrivateEndpointId string

param DeployFunctionAppInVnet string
param VnetForResourcesRgName string
param VnetForResourcesName string
param FunctionAppSubnetName string

param deployWithPEIncomingRequests bool = false
var PeIntegration = (DeployWithCustomNetworking == 'True' && CreatePrivateEndpoints == 'True')?true:false
var FunctionAppInVnet = (DeployWithCustomNetworking == 'True' && DeployFunctionAppInVnet == 'True')?true:false

var privateEndpointRg = (CreatePrivateEndpointsInSameRgAsResource == 'True')?resourceGroup().name:VnetforPrivateEndpointsRgName

param DeployResourcesWithPublicAccess string

param cosmosDbName string
param keyVaultName string
param staticWebAppName string
param serviceBusNamespaceName string
param emailCommunicationServicesName string

//dns zone
@secure()
param DNS_ZONE_SUBSCRIPTION_ID string
param PrivateDNSZoneRgName string

var WEBSITE_CONTENTOVERVNET = (FunctionAppInVnet)?1:0

var vnetRouteAllEnabled = (DeployResourcesWithPublicAccess == 'True')?false:true

resource r_appinsights 'microsoft.insights/components@2020-02-02' existing = {
  name: functionAppInsightsName
}

resource r_vnet 'Microsoft.Network/virtualNetworks@2022-01-01' existing = if (FunctionAppInVnet) {
  scope: resourceGroup(VnetForResourcesRgName)
  name: VnetForResourcesName
}

resource r_storageAccount 'Microsoft.Storage/storageAccounts@2021-09-01' existing = {
  name: functionAppStorageName
}

resource r_fileShare 'Microsoft.Storage/storageAccounts/fileServices/shares@2021-09-01' = {
  name: '${r_storageAccount.name}/default/${toLower(functionAppName)}'
}

resource r_functionAppSubnet 'Microsoft.Network/virtualNetworks/subnets@2022-01-01' existing = if (FunctionAppInVnet) {
  parent: r_vnet
  name: FunctionAppSubnetName
}

resource r_AppServicePlan 'Microsoft.Web/serverfarms@2022-03-01' existing = {
  name: functionAppServicePlanName
}

resource r_CosmosDb 'Microsoft.DocumentDB/databaseAccounts@2022-08-15' existing = {
  name: cosmosDbName
}

resource r_staticWebApp 'Microsoft.Web/staticSites@2022-03-01' existing = {
  name: staticWebAppName
}

resource r_emailServicesDomain 'Microsoft.Communication/emailServices/domains@2022-07-01-preview' existing = {
  name: '${emailCommunicationServicesName}/AzureManagedDomain'
}

var https_prefix = 'https://' 

resource r_FunctionApp 'Microsoft.Web/sites@2022-03-01' = {
  name: functionAppName
  kind: kind
  location: location
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    siteConfig: {
      appSettings: [
        {
          name: 'FUNCTIONS_EXTENSION_VERSION'
          value: '~4'
        }
        {
          name: 'FUNCTIONS_WORKER_RUNTIME'
          value: 'dotnet'
        }
        {
          name: 'WEBSITE_ENABLE_SYNC_UPDATE_SITE'
          value: 'true'
        }
        {
          name: 'WEBSITES_ENABLE_APP_SERVICE_STORAGE'
          value: 'true'
        }
        {
          name: 'APPINSIGHTS_INSTRUMENTATIONKEY'
          value: r_appinsights.properties.InstrumentationKey
        }
        {
          name: 'APPLICATIONINSIGHTS_CONNECTION_STRING'
          value: r_appinsights.properties.ConnectionString
        }
        {
          name: 'AzureWebJobsStorage'
          value: 'DefaultEndpointsProtocol=https;AccountName=${functionAppStorageName};AccountKey=${listKeys(r_storageAccount.id, '2019-06-01').keys[0].value};EndpointSuffix=core.windows.net'
        }
        {
          name: 'WEBSITE_CONTENTAZUREFILECONNECTIONSTRING'
          value: 'DefaultEndpointsProtocol=https;AccountName=${functionAppStorageName};AccountKey=${listKeys(r_storageAccount.id, '2019-06-01').keys[0].value};EndpointSuffix=core.windows.net'
        }
        {
          name: 'WEBSITE_CONTENTSHARE'
          value: toLower(functionAppName)
        }
        {
          name: 'WEBSITE_CONTENTOVERVNET'
          value: '${WEBSITE_CONTENTOVERVNET}'
        }
        {
          name: 'ServiceBusConnection__FullyQualifiedNamespace'
          value: '${serviceBusNamespaceName}.servicebus.windows.net'
        }
        {
          name: 'KeyVault'
          value: keyVaultName
        }
        {
          name: 'Cosmos__Endpoint'
          value: r_CosmosDb.properties.documentEndpoint
        }
        {
          name: 'AppUrl'
          value: '${https_prefix}${r_staticWebApp.properties.defaultHostname}'
        }
        {
          name: 'CommunicationServiceConfiguration__EmailSender'
          value: 'donotreply@${r_emailServicesDomain.properties.fromSenderDomain}'
        }
        {
          name: 'GitHubConfiguration__AppId'
          value: ''
        }
        {
          name: 'GitHubConfiguration__InstallationId'
          value: ''
        }
        {
          name: 'GitHubConfiguration__Organization'
          value: ''
        }
        {
          name: 'GitHubConfiguration__TokenExpiration'
          value: ''
        }
        {
          name: 'GitHubConfiguration__UsePAT'
          value: 'false'
        }
        {
          name: 'AssetsEnrichmentQueuerTriggerTime'
          value: ''
        }
        {
          name: 'AssetsStatisticsQueuerTriggerTime'
          value: ''
        }
      ]
      linuxFxVersion: linuxFxVersion
      numberOfWorkers: numberOfWorkers
      alwaysOn: alwaysOn
      http20Enabled: http20Enabled
      minimumElasticInstanceCount: minimumElasticInstanceCount
    }
    vnetRouteAllEnabled: (FunctionAppInVnet == false)?null:vnetRouteAllEnabled
    virtualNetworkSubnetId: (FunctionAppInVnet == false)?null:r_functionAppSubnet.id
    serverFarmId: r_AppServicePlan.id
    clientAffinityEnabled: false
    httpsOnly: true
  }
}

var privateDnsZoneName = 'privatelink.azurewebsites.net'
module m_functionapp_private_endpoint 'private_endpoint.bicep' = if (PeIntegration && deployWithPEIncomingRequests) {
  name: 'function_private_endpoint'
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
    resourceName: functionAppName
    resourceID: r_FunctionApp.id
    privateEndpointgroupIds: [
      'sites'
    ]
    PrivateEndpointId: PrivateEndpointId
  }
}
