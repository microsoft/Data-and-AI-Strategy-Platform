// Copyright (c) Microsoft Corporation.
// Licensed under the MIT license.
param location string = resourceGroup().location

param logAnalyticsName string

@allowed([
  'Disabled'
  'Enabled'
])
param publicNetworkAccessForIngestion string

@allowed([
  'Disabled'
  'Enabled'
])
param publicNetworkAccessForQuery string

@allowed([
  'Free'
  'PerGB2018'
  'PerNode'
  'Premium'
  'Standalone'
  'Standard'
  ])
param sku_name string = 'PerGB2018'

param disableLocalAuth bool = false

param enableDataExport bool = true

param enableLogAccessUsingOnlyResourcePermissions bool = false

param immediatePurgeDataOn30Days bool = false

param retentionInDays int = 90

param dailyQuotaGb int = -1

@description('Public Networking Access')
param DeployResourcesWithPublicAccess string 
var publicNetworkAccessForIngestion_variable = (DeployResourcesWithPublicAccess == 'True')?'Enabled':publicNetworkAccessForIngestion
var publicNetworkAccessForQuery_variable = (DeployResourcesWithPublicAccess == 'True')?'Enabled':publicNetworkAccessForQuery

//for private link setup

resource r_loganalytics 'Microsoft.OperationalInsights/workspaces@2021-12-01-preview' = {
  name: logAnalyticsName
  location: location
  properties: {
    features: {
      disableLocalAuth: disableLocalAuth
      enableDataExport: enableDataExport
      enableLogAccessUsingOnlyResourcePermissions: enableLogAccessUsingOnlyResourcePermissions
      immediatePurgeDataOn30Days: immediatePurgeDataOn30Days
    }
    publicNetworkAccessForIngestion: publicNetworkAccessForIngestion_variable
    publicNetworkAccessForQuery: publicNetworkAccessForQuery_variable
    retentionInDays: retentionInDays
    sku: {
      name: sku_name
    }
    workspaceCapping: {
      dailyQuotaGb: dailyQuotaGb
    }
  }
}

//module m_privateLinkScope_private_endpoint 'private_endpoint_AzMonitor.bicep' = if (vnetDeployed == 'True') {
//  name: 'privateLinkScope_private_endpoint'
//  scope: resourceGroup(VnetVmResourceGroupName)
//  params: {
//    location:location
//    vnetName: vnetName
//    loganalytics_Name: logAnalyticsName
//    loganalytics_resourceID: r_loganalytics.id
//    privateEndpointgroupIds: [
//      'azuremonitor'
//    ]
//  }
//}
