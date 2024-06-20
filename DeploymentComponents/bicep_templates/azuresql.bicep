// Copyright (c) Microsoft Corporation.
// Licensed under the MIT license.
param location string = resourceGroup().location

param azureSQLServerName string

param azureSQLServerDBName string

@allowed([
  'Disabled'
  'Enabled'
])
param restrictOutboundNetworkAccess string

@allowed([
  '1.2'
])
param minimalTlsVersion string

param maxSizeBytes int

@allowed([
  'Geo'
  'GeoZone'
  'Local'
  'Zone'
])
param requestedBackupStorageRedundancy string

param databaseCollation string

@allowed([
  'DATABASE_DEFAULT'
  'SQL_Latin1_General_CP1_CI_AS'
])
param catalogCollation string

param AADType string = 'Application'

param AADName string

param AADID string

param DeployLogAnalytics string

param logAnalyticsName string

param enableAuditLogging bool

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
var privateDnsZoneName = 'privatelink${environment().suffixes.sqlServerHostname}'

@description('Public Networking Access')
param DeployResourcesWithPublicAccess string 
//always enabled initially so SQL artifacts can be deployed from GitHub Runner
//Public network access is then turned off later in current deployment
//unless self hosted agent has access to vnet. something that would occur after initial deployment
param RedeploymentAfterNetworkingIsSetUp string

//ip firewall rules
param AllowAccessToIpRange string
param IpRangeStart string
param IpRangeEnd string

var ipRangeFilter = (DeployWithCustomNetworking == 'True' && AllowAccessToIpRange == 'True')?true:false

var publicNetworkAccess = (RedeploymentAfterNetworkingIsSetUp == 'False' || ipRangeFilter)?'Enabled':'Disabled'

//for additional synapse deployments
param PrimaryRg string = resourceGroup().name

resource r_azureSQLServer 'Microsoft.Sql/servers@2022-05-01-preview' = {
  name: azureSQLServerName
  location: location
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    administrators: {
      administratorType: 'ActiveDirectory'
      azureADOnlyAuthentication: true
      login: AADName
      principalType: AADType
      sid: AADID
      tenantId: tenant().tenantId
    }
    minimalTlsVersion: minimalTlsVersion
    publicNetworkAccess: publicNetworkAccess
    restrictOutboundNetworkAccess: restrictOutboundNetworkAccess
  }
}

resource r_azureSQLServerDB 'Microsoft.Sql/servers/databases@2022-05-01-preview' = {
  name: azureSQLServerDBName
  parent: r_azureSQLServer
  location: location
  sku: {
    name: 'Basic'
    tier: 'Basic'
  }
  properties: {
    catalogCollation: catalogCollation
    collation: databaseCollation
    maxSizeBytes: maxSizeBytes
    requestedBackupStorageRedundancy: requestedBackupStorageRedundancy
  }
}

// Firewall Allow Azure Sevices
// Checks box for "Allow Azure services and resources to access this workspace"
// So GitHub Runner can access SQL when deploying artifacts
resource r_AllowAllWindowsAzureIpsFirewallRule 'Microsoft.Sql/servers/firewallRules@2022-05-01-preview' = if (RedeploymentAfterNetworkingIsSetUp == 'False') {
  name: 'AllowAllWindowsAzureIps'
  parent: r_azureSQLServer
  properties:{
    startIpAddress: '0.0.0.0'
    endIpAddress: '0.0.0.0'
  }
}

//if public access is requested at deployment
resource r_AllowAll 'Microsoft.Sql/servers/firewallRules@2022-05-01-preview' = if (DeployResourcesWithPublicAccess == 'True') {
  name: 'AllowAll'
  parent: r_azureSQLServer
  properties:{
    startIpAddress: '0.0.0.0'
    endIpAddress: '255.255.255.255'
  }
}

//Allow Access to Custom IP Range
resource r_AllowCustom 'Microsoft.Sql/servers/firewallRules@2022-05-01-preview' = if (ipRangeFilter) {
  name: 'AllowCustom'
  parent: r_azureSQLServer
  properties:{
    startIpAddress: IpRangeStart
    endIpAddress: IpRangeEnd
  }
}


resource r_loganalytics 'Microsoft.OperationalInsights/workspaces@2021-06-01' existing = if (DeployLogAnalytics == 'True') {
  scope: resourceGroup(PrimaryRg)
  name: logAnalyticsName
}

resource r_masterDb 'Microsoft.Sql/servers/databases@2022-05-01-preview' = {
  parent: r_azureSQLServer
  location: location
  name: 'master'
  properties: {}
}


resource r_diagnosticSettings 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = if (enableAuditLogging && DeployLogAnalytics == 'True') {
  scope: r_masterDb
  name: 'sql-audit-loganalytics'
  properties: {
    workspaceId: r_loganalytics.id
    logs: [
      {
        category: 'SQLSecurityAuditEvents'
        enabled: true
      }
    ]
  }
}

resource r_auditingSettings 'Microsoft.Sql/servers/auditingSettings@2022-05-01-preview' = if (enableAuditLogging && DeployLogAnalytics == 'True') {
  parent: r_azureSQLServer
  name: 'default'
  properties: {
    state: 'Enabled'
    isAzureMonitorTargetEnabled: true
  }
}


module m_azuresql_private_endpoint 'private_endpoint.bicep' = if (vnetIntegration) {
  name: 'azuresql_private_endpoint'
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
    resourceName: azureSQLServerName
    resourceID: r_azureSQLServer.id
    privateEndpointgroupIds: [
      'sqlServer'
    ]
    PrivateEndpointId: PrivateEndpointId
  }
}
