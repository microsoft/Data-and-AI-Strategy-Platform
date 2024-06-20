// Copyright (c) Microsoft Corporation.
// Licensed under the MIT license.
param location string = resourceGroup().location

param webAppName string

param webAppServicePlanName string

param webAppInsightsName string

param webAppStorageName string

param kind string

param linuxFxVersion string

param numberOfWorkers int
param acrUseManagedIdentityCreds bool

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

param DeployWebAppInVnet string
param VnetForResourcesRgName string
param VnetForResourcesName string
param WebAppSubnetName string

param deployWithPEIncomingRequests bool = false
var PeIntegration = (DeployWithCustomNetworking == 'True' && CreatePrivateEndpoints == 'True')?true:false
var WebAppInVnet = (DeployWithCustomNetworking == 'True' && DeployWebAppInVnet == 'True')?true:false

var privateEndpointRg = (CreatePrivateEndpointsInSameRgAsResource == 'True')?resourceGroup().name:VnetforPrivateEndpointsRgName

param DeployResourcesWithPublicAccess string

//dns zone
@secure()
param DNS_ZONE_SUBSCRIPTION_ID string
param PrivateDNSZoneRgName string

var WEBSITE_CONTENTOVERVNET = (WebAppInVnet)?1:0

var vnetRouteAllEnabled = (DeployResourcesWithPublicAccess == 'True')?false:true

param cosmosDbName string
param keyVaultName string
param staticWebAppName string
param serviceBusNamespaceName string
param emailCommunicationServicesName string
param cognitiveSearchName string

resource r_appinsights 'microsoft.insights/components@2020-02-02' existing = {
  name: webAppInsightsName
}

resource r_vnet 'Microsoft.Network/virtualNetworks@2022-01-01' existing = if (WebAppInVnet) {
  scope: resourceGroup(VnetForResourcesRgName)
  name: VnetForResourcesName
}

resource r_storageAccount 'Microsoft.Storage/storageAccounts@2021-09-01' existing = {
  name: webAppStorageName
}

resource r_fileShare 'Microsoft.Storage/storageAccounts/fileServices/shares@2021-09-01' = {
  name: '${r_storageAccount.name}/default/${toLower(webAppName)}'
}

resource r_logicAppSubnet 'Microsoft.Network/virtualNetworks/subnets@2022-01-01' existing = if (WebAppInVnet) {
  parent: r_vnet
  name: WebAppSubnetName
}

resource r_AppServicePlan 'Microsoft.Web/serverfarms@2022-03-01' existing = {
  name: webAppServicePlanName
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

resource r_webApp 'Microsoft.Web/sites@2022-03-01' = {
  name: webAppName
  kind: kind
  location: location
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    siteConfig: {
      appSettings: [
        {
          name: 'APPINSIGHTS_INSTRUMENTATIONKEY'
          value: r_appinsights.properties.InstrumentationKey
        }
        {
          name: 'APPLICATIONINSIGHTS_CONNECTION_STRING'
          value: r_appinsights.properties.ConnectionString
        }
        {
          name: 'ApplicationInsightsAgent_EXTENSION_VERSION'
          value: '~3'
        }
        {
          name: 'AzureWebJobsStorage'
          value: 'DefaultEndpointsProtocol=https;AccountName=${webAppStorageName};AccountKey=${listKeys(r_storageAccount.id, '2019-06-01').keys[0].value};EndpointSuffix=core.windows.net'
        }
        {
          name: 'WEBSITE_CONTENTAZUREFILECONNECTIONSTRING'
          value: 'DefaultEndpointsProtocol=https;AccountName=${webAppStorageName};AccountKey=${listKeys(r_storageAccount.id, '2019-06-01').keys[0].value};EndpointSuffix=core.windows.net'
        }
        {
          name: 'Storage__AccountName'
          value: webAppStorageName
        }
        {
          name: 'WEBSITE_CONTENTSHARE'
          value: toLower(webAppName)
        }
        {
          name: 'WEBSITE_CONTENTOVERVNET'
          value: '${WEBSITE_CONTENTOVERVNET}'
        }
        {
          name: 'WEBSITE_RUN_FROM_PACKAGE'
          value: '1'
        }
        {
          name: 'WEBSITE_ENABLE_SYNC_UPDATE_SITE'
          value: 'true'
        }
        {
          name: 'XDT_MicrosoftApplicationInsights_Mode'
          value: 'Recommended'
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
          name: 'Search__Endpoint'
          value: 'https://${cognitiveSearchName}.search.windows.net/'
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
          name: 'AzureAd__ClientId'
          value: ''
        }
        {
          name: 'AzureAd__Scopes__0'
          value: ''
        }
        {
          name: 'AzureAd__TenantId'
          value: tenant().tenantId
        }
        {
          name: 'CommunicationServiceConfiguration__PlatformContactRecipients'
          value: ''
        }
      ]
      linuxFxVersion: linuxFxVersion
      cors: {
        allowedOrigins: [
            '${https_prefix}${r_staticWebApp.properties.defaultHostname}'
            'https://localhost:4000'
        ]
      }
      numberOfWorkers: numberOfWorkers
      acrUseManagedIdentityCreds: acrUseManagedIdentityCreds
      alwaysOn: true
      http20Enabled: http20Enabled
      minimumElasticInstanceCount: minimumElasticInstanceCount
    }
    vnetRouteAllEnabled: (WebAppInVnet == false)?null:vnetRouteAllEnabled
    virtualNetworkSubnetId: (WebAppInVnet == false)?null:r_logicAppSubnet.id
    serverFarmId: r_AppServicePlan.id
    clientAffinityEnabled: false
    httpsOnly: true
  }
}

var privateDnsZoneName = 'privatelink.azurewebsites.net'
module m_logicapp_private_endpoint 'private_endpoint.bicep' = if (PeIntegration && deployWithPEIncomingRequests) {
  name: 'logicapp_private_endpoint'
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
    resourceName: webAppName
    resourceID: r_webApp.id
    privateEndpointgroupIds: [
      'sites'
    ]
    PrivateEndpointId: PrivateEndpointId
  }
}
