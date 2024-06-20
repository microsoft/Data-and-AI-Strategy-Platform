// Copyright (c) Microsoft Corporation.
// Licensed under the MIT license.
param location string = resourceGroup().location

//logic app and app service plan params
param logicAppName string

param logicAppServicePlanName string
param logicAppServicePlanResourceGroupName string = resourceGroup().name

param logicAppAppInsights string

param logicAppStorage string

param use32BitWorkerProcess bool

param ftpsState string

param netFrameworkVersion string

param azureSQLServerName string
param azureSQLServerDBName string

param storageAccountName string

param dataLakeName string
param landingStorageName string
param PrimaryRgName string

//vnet integration
param DeployWithCustomNetworking string
param CreatePrivateEndpoints string
param CreatePrivateEndpointsInSameRgAsResource string
param UseManualPrivateLinkServiceConnections string
param VnetforPrivateEndpointsRgName string
param VnetforPrivateEndpointsName string
param PrivateEndpointSubnetName string
param PrivateEndpointId string

param DeployLogicAppInVnet string
param VnetForResourcesRgName string
param VnetForResourcesName string
param LogicAppSubnetName string

param deployWithPEIncomingRequests bool = false
var PeIntegration = (DeployWithCustomNetworking == 'True' && CreatePrivateEndpoints == 'True')?true:false
var LogicAppInVnet = (DeployWithCustomNetworking == 'True' && DeployLogicAppInVnet == 'True')?true:false

var privateEndpointRg = (CreatePrivateEndpointsInSameRgAsResource == 'True')?resourceGroup().name:VnetforPrivateEndpointsRgName

param DeployResourcesWithPublicAccess string

//dns zone
@secure()
param DNS_ZONE_SUBSCRIPTION_ID string
param PrivateDNSZoneRgName string

var WEBSITE_CONTENTOVERVNET = (LogicAppInVnet)?1:0

var vnetRouteAllEnabled = (DeployResourcesWithPublicAccess == 'True')?false:true

resource r_appinsights 'microsoft.insights/components@2020-02-02' existing = {
  name: logicAppAppInsights
}

resource r_vnet 'Microsoft.Network/virtualNetworks@2022-01-01' existing = if (LogicAppInVnet) {
  scope: resourceGroup(VnetForResourcesRgName)
  name: VnetForResourcesName
}

resource r_storageAccount 'Microsoft.Storage/storageAccounts@2021-09-01' existing = {
  name: storageAccountName
}

resource r_fileShare 'Microsoft.Storage/storageAccounts/fileServices/shares@2021-09-01' = {
  name: '${r_storageAccount.name}/default/${toLower(logicAppName)}'
}

resource r_logicAppSubnet 'Microsoft.Network/virtualNetworks/subnets@2022-01-01' existing = if (LogicAppInVnet) {
  parent: r_vnet
  name: LogicAppSubnetName
}

resource r_AppServicePlan 'Microsoft.Web/serverfarms@2022-03-01' existing = {
  scope: resourceGroup(logicAppServicePlanResourceGroupName)
  name: logicAppServicePlanName
}


resource r_LogicApp 'Microsoft.Web/sites@2022-03-01' = {
  name: logicAppName
  kind: 'functionapp,workflowapp'
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
          value: 'node'
        }
        {
          name: 'WEBSITE_NODE_DEFAULT_VERSION'
          value: '~14'
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
          value: 'DefaultEndpointsProtocol=https;AccountName=${logicAppStorage};AccountKey=${listKeys(r_storageAccount.id, '2019-06-01').keys[0].value};EndpointSuffix=core.windows.net'
        }
        {
          name: 'WEBSITE_CONTENTAZUREFILECONNECTIONSTRING'
          value: 'DefaultEndpointsProtocol=https;AccountName=${logicAppStorage};AccountKey=${listKeys(r_storageAccount.id, '2019-06-01').keys[0].value};EndpointSuffix=core.windows.net'
        }
        {
          name: 'WEBSITE_CONTENTSHARE'
          value: toLower(logicAppName)
        }
        {
          name: 'AzureFunctionsJobHost__extensionBundle__id'
          value: 'Microsoft.Azure.Functions.ExtensionBundle.Workflows'
        }
        {
          name: 'AzureFunctionsJobHost__extensionBundle__version'
          value: '[1.*, 2.0.0)'
        }
        {
          name: 'APP_KIND'
          value: 'workflowApp'
        }
        {
          name: 'sql_databaseName'
          value: azureSQLServerDBName
        }
        {
          name: 'sql_serverName'
          value: '${azureSQLServerName}${environment().suffixes.sqlServerHostname}'
        }
        {
          name: 'WEBSITE_CONTENTOVERVNET'
          value: '${WEBSITE_CONTENTOVERVNET}'
        }
        {
          name: 'WEBSITE_RUN_FROM_PACKAGE'
          value: '0'
        }
        {
          name: 'ServiceProviders.Sql.QueryTimeout'
          value: '00:02:00'
        }
      ]
      use32BitWorkerProcess: use32BitWorkerProcess
      ftpsState: ftpsState
      netFrameworkVersion: netFrameworkVersion
      functionsRuntimeScaleMonitoringEnabled: true
    }
    vnetRouteAllEnabled: (LogicAppInVnet == false)?null:vnetRouteAllEnabled
    virtualNetworkSubnetId: (LogicAppInVnet == false)?null:r_logicAppSubnet.id
    serverFarmId: r_AppServicePlan.id
    clientAffinityEnabled: false
    httpsOnly: true
  }
}

resource r_sqlAPIConn 'Microsoft.Web/connections@2018-07-01-preview' = {
  name: 'LogicAppSqlConn'
  location: location
  kind: 'V2'
  properties: {
    displayName: 'sql'
    authenticatedUser: {}
    parameterValueSet:{
      name: 'oauthMI'
      values: {}
    }
    api: {
      id: '/subscriptions/${subscription().subscriptionId}/providers/Microsoft.Web/locations/${location}/managedApis/sql'
    }
  }
}

resource r_sqlAPIConn_AccessPolicies 'Microsoft.Web/connections/accessPolicies@2018-07-01-preview' = {
  parent: r_sqlAPIConn
  name: 'LogicAppSqlConnAccessPolicies'
  location: location
  properties: {
    principal: {
      type: 'ActiveDirectory'
      identity: {
         objectId: r_LogicApp.identity.principalId
         tenantId: tenant().tenantId
      }
   }
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
    resourceName: logicAppName
    resourceID: r_LogicApp.id
    privateEndpointgroupIds: [
      'sites'
    ]
    PrivateEndpointId: PrivateEndpointId
  }
}


