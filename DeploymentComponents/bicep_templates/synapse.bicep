// Copyright (c) Microsoft Corporation.
// Licensed under the MIT license.
param location string = resourceGroup().location

param synapseWorkspaceName string 

param DeploySynapseWithDataExfiltrationProtection string

param tags string

var tagsObject = json(tags)

param dataLakeName string

param purviewName string

param DeployPurview string

param enableDiagnostics bool = true

param enableSQLAuditLogging bool = true

param DeployLogAnalytics string

param logAnalyticsName string

param configureGit bool

param gitAccountName string = ''

param gitRepositoryName string = ''

//for private link setup
param DeployWithCustomNetworking string
param CreatePrivateEndpoints string
param CreatePrivateEndpointsInSameRgAsResource string
param UseManualPrivateLinkServiceConnections string
param VnetforPrivateEndpointsRgName string
param VnetforPrivateEndpointsName string
param PrivateEndpointSubnetName string
param DeploySynapseWebPrivateEndpoint string
param PrivateEndpointId string

var vnetIntegration = (DeployWithCustomNetworking == 'True' && CreatePrivateEndpoints == 'True')?true:false
var privateEndpointRg = (CreatePrivateEndpointsInSameRgAsResource == 'True')?resourceGroup().name:VnetforPrivateEndpointsRgName

@description('Public Networking Access')
param DeployResourcesWithPublicAccess string 
//always enabled initially so Synapse artifacts can be deployed from GitHub Runner
//Public network access is then turned off later in current deployment
//unless self hosted agent has access to vnet. something that would occur after initial deployment
param RedeploymentAfterNetworkingIsSetUp string

//ip firewall rules
param AllowAccessToIpRange string
param IpRangeStart string
param IpRangeEnd string

var ipRangeFilter = (DeployWithCustomNetworking == 'True' && AllowAccessToIpRange == 'True')?true:false

var publicNetworkAccess = (RedeploymentAfterNetworkingIsSetUp == 'False' || ipRangeFilter)?'Enabled':'Disabled'

//dns zone
@secure()
param DNS_ZONE_SUBSCRIPTION_ID string
param PrivateDNSZoneRgName string

//for additional synapse deployments
param PrimaryRg string = resourceGroup().name

resource r_datalake 'Microsoft.Storage/storageAccounts@2021-08-01' existing = {
  scope: resourceGroup(PrimaryRg)
  name: dataLakeName
}

var synapseContainerName = 'synapseworkspacelogs'

//Create Synapse logging container
module m_storage_account_create_container 'storage_account_create_container.bicep' = {
  name: 'storage_create_container'
  scope: resourceGroup(PrimaryRg)
  params: {
    storageAccountName: dataLakeName
    containerName: synapseContainerName
  }
}

resource r_purview 'Microsoft.Purview/accounts@2021-07-01' existing = if (DeployPurview == 'True') {
  scope: resourceGroup(PrimaryRg)
  name: purviewName
}

resource r_synapseWorkspace 'Microsoft.Synapse/workspaces@2021-06-01' = {
  name: synapseWorkspaceName
  location: location
  tags: tagsObject
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    trustedServiceBypassEnabled: true
    azureADOnlyAuthentication: true
    defaultDataLakeStorage: {
      accountUrl: r_datalake.properties.primaryEndpoints.dfs
      createManagedPrivateEndpoint: false
      filesystem: synapseContainerName
      resourceId: r_datalake.id
    }
    managedResourceGroupName: '${synapseWorkspaceName}-managed-rg'
    managedVirtualNetwork: 'default'
    managedVirtualNetworkSettings: {
      preventDataExfiltration: (DeploySynapseWithDataExfiltrationProtection == 'True')?true:false
    }
    publicNetworkAccess: publicNetworkAccess
    purviewConfiguration: (DeployPurview != 'True')?null:{
      purviewResourceId: r_purview.id
    }
    workspaceRepositoryConfiguration: (configureGit == false)?null:{
      accountName: gitAccountName
      collaborationBranch: 'main'
      repositoryName: gitRepositoryName
      rootFolder: '${synapseWorkspaceName}/'
      type: 'WorkspaceGitHubConfiguration'
    }
  }
}

resource r_ManagedVnetIntegrationRuntime 'Microsoft.Synapse/workspaces/integrationRuntimes@2021-06-01' = {
  name: 'ManagedVnetIntegrationRuntime'
  parent: r_synapseWorkspace
  properties: {
    type: 'Managed'
    typeProperties: {
      computeProperties: {
        location: 'AutoResolve'
        dataFlowProperties: {
            computeType: 'General'
            coreCount: 8
            timeToLive: 10
            cleanup: false
        }
        //copyComputeScaleProperties: {
        //  dataIntegrationUnit: 16
        //  timeToLive: 5
        //}
        //pipelineExternalComputeScaleProperties: {
        //  timeToLive: 10
        //}
      }
    }
    managedVirtualNetwork: {
      type: 'ManagedVirtualNetworkReference'
      referenceName: 'default'
    }
  }
}

// Firewall Allow Azure Sevices
// Checks box for "Allow Azure services and resources to access this workspace"
// So GitHub Runner can access Synapse when deploying artifacts
resource r_synapseWorkspaceFirewallAllowAzure 'Microsoft.Synapse/workspaces/firewallRules@2021-06-01' = if (RedeploymentAfterNetworkingIsSetUp == 'False') {
  name: 'AllowAllWindowsAzureIps'
  parent: r_synapseWorkspace
  properties:{
    startIpAddress: '0.0.0.0'
    endIpAddress: '0.0.0.0'
  }
}

//if public access is requested at deployment
resource r_synapseWorkspaceFirewallAllowAll 'Microsoft.Synapse/workspaces/firewallRules@2021-06-01' = if (DeployResourcesWithPublicAccess == 'True') {
  name: 'AllowAll'
  parent: r_synapseWorkspace
  properties:{
    startIpAddress: '0.0.0.0'
    endIpAddress: '255.255.255.255'
  }
}

//Allow Access to Custom IP Range
resource r_synapseWorkspaceFirewallAllowCustom 'Microsoft.Synapse/workspaces/firewallRules@2021-06-01' = if (ipRangeFilter) {
  name: 'AllowCustom'
  parent: r_synapseWorkspace
  properties:{
    startIpAddress: IpRangeStart
    endIpAddress: IpRangeEnd
  }
}

resource r_loganalytics 'Microsoft.OperationalInsights/workspaces@2021-06-01' existing = if (DeployLogAnalytics == 'True') {
  scope: resourceGroup(PrimaryRg)
  name: logAnalyticsName
}

resource r_diagnostics 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = if (enableDiagnostics && DeployLogAnalytics == 'True') {
  scope: r_synapseWorkspace
  name: 'synapse-diagnostic-loganalytics'
  properties: {
    workspaceId: r_loganalytics.id
    logs: [
      {
        category: 'SynapseRbacOperations'
        enabled: true
      }
      {
        category: 'GatewayApiRequests'
        enabled: true
      }
      {
        category: 'BuiltinSqlReqsEnded'
        enabled: true
      }
      {
        category: 'IntegrationPipelineRuns'
        enabled: true
      }
      {
        category: 'IntegrationActivityRuns'
        enabled: true
      }
      {
        category: 'IntegrationTriggerRuns'
        enabled: true
      }
    ]
  }
}

resource r_diagnosticSettings 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = if (enableSQLAuditLogging && DeployLogAnalytics == 'True') {
  scope: r_synapseWorkspace
  name: 'synapse-audit-loganalytics'
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

resource r_auditingSettings 'Microsoft.Synapse/workspaces/auditingSettings@2021-06-01' = if (enableSQLAuditLogging && DeployLogAnalytics == 'True') {
  parent: r_synapseWorkspace
  name: 'default'
  properties: {
    state: 'Enabled'
    isAzureMonitorTargetEnabled: true
  }
}

//deploy Azure Private Endpoints
module m_synapse_networking 'synapse_networking.bicep' = if (vnetIntegration) {
  name: 'synapse_networking'
  scope: resourceGroup(privateEndpointRg)
  params: {
    location:location
    synapseWorkspaceName: synapseWorkspaceName
    synapseWorkspaceId: r_synapseWorkspace.id
    VnetforPrivateEndpointsRgName: VnetforPrivateEndpointsRgName
    VnetforPrivateEndpointsName: VnetforPrivateEndpointsName
    PrivateEndpointSubnetName: PrivateEndpointSubnetName
    UseManualPrivateLinkServiceConnections: UseManualPrivateLinkServiceConnections
    DNS_ZONE_SUBSCRIPTION_ID: DNS_ZONE_SUBSCRIPTION_ID
    PrivateDNSZoneRgName: PrivateDNSZoneRgName
    DeploySynapseWebPrivateEndpoint: DeploySynapseWebPrivateEndpoint
    PrivateEndpointId: PrivateEndpointId
  }
}
