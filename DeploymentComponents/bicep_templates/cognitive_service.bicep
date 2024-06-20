// Copyright (c) Microsoft Corporation.
// Licensed under the MIT license.

@description('That name is the name of our application.')
param cognitiveServiceName string

@description('Location for all resources.')
param location string = resourceGroup().location

@allowed([
  'CognitiveServices'
  'FormRecognizer'
  'OpenAI'
])
param kind string = 'FormRecognizer'

@allowed([
  'S0'
])
param sku string = 'S0'

@description('Disable use of API Keys and only allow AAD Auth')
param disableLocalAuth bool = true

param deployments array = []

param DeployKeyVault string

param keyVaultRgName string

param keyVaultName string

@description('Public Networking Access')
param DeployResourcesWithPublicAccess string 

//ip firewall rules
param AllowAccessToIpRange string
param IpRangeCidr string
var ipRangeFilter = (DeployWithCustomNetworking == 'True' && AllowAccessToIpRange == 'True')?true:false

var publicNetworkAccess = (DeployResourcesWithPublicAccess == 'True' || ipRangeFilter)?'Enabled':'Disabled'
var defaultAction = (DeployResourcesWithPublicAccess == 'True' && ipRangeFilter == false)?'Allow':'Deny'

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
var privateDnsZoneName = 'privatelink.cognitiveservices.azure.com'

//logging
param DeployLogAnalytics string
param logAnalyticsRG string
param logAnalyticsName string

resource r_cognitiveService 'Microsoft.CognitiveServices/accounts@2022-10-01' = {
  name: cognitiveServiceName
  location: location
  sku: {
    name: sku
  }
  identity: {
    type: 'SystemAssigned'
  }
  kind: kind
  properties: {
    publicNetworkAccess: publicNetworkAccess
    disableLocalAuth: disableLocalAuth
    customSubDomainName: cognitiveServiceName
    apiProperties: {
      statisticsEnabled: false
    }
    networkAcls: {
      defaultAction: defaultAction
      ipRules: (ipRangeFilter==false)?null:[
        {
          value: IpRangeCidr
        }
      ]
    }
  }
}

@batchSize(1)
resource r_deployment 'Microsoft.CognitiveServices/accounts/deployments@2023-05-01' = [for deployment in deployments: {
  parent: r_cognitiveService
  name: deployment.name
  properties: {
    model: deployment.model
    raiPolicyName: contains(deployment, 'raiPolicyName') ? deployment.raiPolicyName : null
  }
  sku: contains(deployment, 'sku') ? deployment.sku : {
    name: 'Standard'
    capacity: 20
  }
}]

module m_cognitiveService_kv_secret 'key_vault_create_secret.bicep' = if (DeployKeyVault == 'True') {
  name: 'cognitiveService_kv_secret'
  scope: resourceGroup(keyVaultRgName)
  params: {
    keyVaultName: keyVaultName
    secretName: '${cognitiveServiceName}-key1'
    secretValue: r_cognitiveService.listKeys().key1
  }
}

module m_cognitiveService_private_endpoint 'private_endpoint.bicep' = if (vnetIntegration) {
  name: 'cognitiveService_private_endpoint'
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
    resourceName: cognitiveServiceName
    resourceID: r_cognitiveService.id
    privateEndpointgroupIds: [
      'account'
    ]
    PrivateEndpointId: PrivateEndpointId
  }
}

resource r_loganalytics 'Microsoft.OperationalInsights/workspaces@2021-06-01' existing = if (DeployLogAnalytics == 'True') {
  scope: resourceGroup(logAnalyticsRG)
  name: logAnalyticsName
}

resource r_diagnostics 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = if (DeployLogAnalytics == 'True') {
  scope: r_cognitiveService
  name: 'cognitiveService-diagnostic-loganalytics'
  properties: {
    workspaceId: r_loganalytics.id
    logs: [
      {
        categoryGroup: 'Audit'
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
