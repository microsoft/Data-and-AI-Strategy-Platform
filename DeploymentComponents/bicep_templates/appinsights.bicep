// Copyright (c) Microsoft Corporation.
// Licensed under the MIT license.
param location string = resourceGroup().location

param appInsightsName string

param DeployLogAnalytics string

param logAnalyticsName string

param logAnalyticsRG string

param publicNetworkAccessForIngestion string

param publicNetworkAccessForQuery string

param RetentionInDays int

@description('Public Networking Access')
param DeployResourcesWithPublicAccess string 
var publicNetworkAccessForIngestion_variable = (DeployResourcesWithPublicAccess == 'True')?'Enabled':publicNetworkAccessForIngestion
var publicNetworkAccessForQuery_variable = (DeployResourcesWithPublicAccess == 'True')?'Enabled':publicNetworkAccessForQuery

resource r_loganalytics 'Microsoft.OperationalInsights/workspaces@2021-06-01' existing = if (DeployLogAnalytics == 'True') {
  scope: resourceGroup(logAnalyticsRG)
  name: logAnalyticsName
}

resource r_appinsights 'microsoft.insights/components@2020-02-02' = {
  name: appInsightsName
  location: location
  kind: 'web'
  properties: {
    Application_Type: 'web'
    RetentionInDays: RetentionInDays
    WorkspaceResourceId: (DeployLogAnalytics == 'True')?r_loganalytics.id:null
    IngestionMode: (DeployLogAnalytics == 'True')?'LogAnalytics':'ApplicationInsights'
    publicNetworkAccessForIngestion: publicNetworkAccessForIngestion_variable
    publicNetworkAccessForQuery: publicNetworkAccessForQuery_variable
  }
}
