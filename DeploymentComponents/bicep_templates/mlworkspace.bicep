// Copyright (c) Microsoft Corporation.
// Licensed under the MIT license.
param location string = resourceGroup().location

param mlWorkspaceName string

param mlStorageAccountName string

param dataLakeName string

param appInsightsName string

param containerRegistryName string

param keyVaultName string

param PrimaryRgName string

@description('Public Networking Access')
param RedeploymentAfterNetworkingIsSetUp string
//always enabled initially so ML Artifacts artifacts can be deployed from GitHub Runner. 
//Public network access is then turned off later in current deployment
//unless self hosted agent has access to vnet. something that would occur after initial deployment
var publicNetworkAccess = (RedeploymentAfterNetworkingIsSetUp == 'False')?'Enabled':'Disabled'

param hbiWorkspace bool

param DataLakeContainerNames array

//for private link setup
param DeployWithCustomNetworking string
param CreatePrivateEndpoints string
param CreatePrivateEndpointsInSameRgAsResource string
param UseManualPrivateLinkServiceConnections string
param VnetforPrivateEndpointsRgName string
param VnetforPrivateEndpointsName string
param PrivateEndpointSubnetName string
param PrivateEndpointId string
param DeployMLWorkspaceInManagedVnet string

var vnetIntegration = (DeployWithCustomNetworking == 'True' && CreatePrivateEndpoints == 'True')?true:false
var DeployInManagedVnet = (DeployWithCustomNetworking == 'True' && DeployMLWorkspaceInManagedVnet == 'True')?true:false
var privateEndpointRg = (CreatePrivateEndpointsInSameRgAsResource == 'True')?resourceGroup().name:VnetforPrivateEndpointsRgName

//logging
param DeployLogAnalytics string
param logAnalyticsRG string
param logAnalyticsName string

//dns zone
@secure()
param DNS_ZONE_SUBSCRIPTION_ID string
param PrivateDNSZoneRgName string
var privateDnsZoneName1 = 'privatelink.api.azureml.ms'
var privateDnsZoneName2 = 'privatelink.notebooks.azure.net'

resource r_dataLake 'Microsoft.Storage/storageAccounts@2021-09-01' existing = {
  scope: resourceGroup(PrimaryRgName)
  name: dataLakeName
}

resource r_mlStorageAccount 'Microsoft.Storage/storageAccounts@2021-08-01' existing = {
  name: mlStorageAccountName
}

var managedNetwork = {
    isolationMode: 'AllowOnlyApprovedOutbound'
    outboundRules: {
      '${mlWorkspaceName}_${dataLakeName}_dfs': {
        type: 'PrivateEndpoint'
        destination: {
            serviceResourceId: r_dataLake.id
            subresourceTarget: 'dfs'
            sparkEnabled: true
        }
        status: 'Active'
        category: 'UserDefined'
      }
      '${mlWorkspaceName}_${dataLakeName}_blob': {
        type: 'PrivateEndpoint'
        destination: {
            serviceResourceId: r_dataLake.id
            subresourceTarget: 'blob'
            sparkEnabled: true
        }
        status: 'Active'
        category: 'UserDefined'
      }
      '${mlWorkspaceName}_${mlStorageAccountName}_queue': {
        type: 'PrivateEndpoint'
        destination: {
            serviceResourceId: r_mlStorageAccount.id
            subresourceTarget: 'queue'
            sparkEnabled: false
        }
        status: 'Active'
        category: 'UserDefined'
      }
      '${mlWorkspaceName}_${mlStorageAccountName}_table': {
        type: 'PrivateEndpoint'
        destination: {
            serviceResourceId: r_mlStorageAccount.id
            subresourceTarget: 'table'
            sparkEnabled: false
        }
        status: 'Active'
        category: 'UserDefined'
      }
      star_anaconda: {
        type: 'FQDN'
        destination: '*.anaconda.com'
        status: 'Active'
        category: 'UserDefined'
      }
      anaconda: {
        type: 'FQDN'
        destination: 'anaconda.com'
        status: 'Active'
        category: 'UserDefined'
      }
      pypi: {
        type: 'FQDN'
        destination: 'pypi.org'
        status: 'Active'
        category: 'UserDefined'
      }
      star_pytorch: {
        type: 'FQDN'
        destination: '*.pytorch.org'
        status: 'Active'
        category: 'UserDefined'
      }
      pytorch: {
        type: 'FQDN'
        destination: 'pytorch.org'
        status: 'Active'
        category: 'UserDefined'
      }
      star_tensorflow: {
        type: 'FQDN'
        destination: '*.tensorflow.org'
        status: 'Active'
        category: 'UserDefined'
      } 
      star_vscode: {
        type: 'FQDN'
        destination: '*.vscode.dev'
        status: 'Active'
        category: 'UserDefined'
      } 
      vscode_blob_core_windows_net: {
        type: 'FQDN'
        destination: 'vscode.blob.core.windows.net'
        status: 'Active'
        category: 'UserDefined'
      } 
      star_gallerycdn_vsassets_io: {
        type: 'FQDN'
        destination: '*.gallerycdn.vsassets.io'
        status: 'Active'
        category: 'UserDefined'
      } 
      raw_githubusercontent_com: {
        type: 'FQDN'
        destination: 'raw.githubusercontent.com'
        status: 'Active'
        category: 'UserDefined'
      } 
      star_vscode_unpkg_net: {
        type: 'FQDN'
        destination: '*.vscode-unpkg.net'
        status: 'Active'
        category: 'UserDefined'
      } 
      star_vscode_cdn_net: {
        type: 'FQDN'
        destination: '*.vscode-cdn.net'
        status: 'Active'
        category: 'UserDefined'
      } 
      star_vscodeexperiments_azureedge_net: {
        type: 'FQDN'
        destination: '*.vscodeexperiments.azureedge.net'
        status: 'Active'
        category: 'UserDefined'
      } 
      default_exp_tas_com: {
        type: 'FQDN'
        destination: 'default.exp-tas.com'
        status: 'Active'
        category: 'UserDefined'
      } 
      code_visualstudio_com: {
        type: 'FQDN'
        destination: 'code.visualstudio.com'
        status: 'Active'
        category: 'UserDefined'
      } 
      update_code_visualstudio_com: {
        type: 'FQDN'
        destination: 'update.code.visualstudio.com'
        status: 'Active'
        category: 'UserDefined'
      } 
      star_vo_msecnd_net: {
        type: 'FQDN'
        destination: '*.vo.msecnd.net'
        status: 'Active'
        category: 'UserDefined'
      } 
      marketplace_visualstudio_com: {
        type: 'FQDN'
        destination: 'marketplace.visualstudio.com'
        status: 'Active'
        category: 'UserDefined'
      }
    }
    status: {
      status: 'Active'
      sparkReady: true
    }
  }

resource r_keyvault 'Microsoft.KeyVault/vaults@2021-11-01-preview' existing = {
  name: keyVaultName
}

resource r_appinsights 'microsoft.insights/components@2020-02-02' existing = {
  name: appInsightsName
}

resource r_containerRegistry 'Microsoft.ContainerRegistry/registries@2021-09-01' existing = {
  name: containerRegistryName
}

resource r_mlworkspace 'Microsoft.MachineLearningServices/workspaces@2023-06-01-preview' = {
  name: mlWorkspaceName
  location: location
  sku: {
    name: 'Basic'
    tier: 'Basic'
  }
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    friendlyName: mlWorkspaceName
    storageAccount: r_mlStorageAccount.id
    keyVault: r_keyvault.id
    applicationInsights: r_appinsights.id
    containerRegistry: r_containerRegistry.id
    hbiWorkspace: hbiWorkspace
    v1LegacyMode: false
    publicNetworkAccess: publicNetworkAccess
    systemDatastoresAuthMode: 'identity'
    managedNetwork: (DeployInManagedVnet == false) ? null : managedNetwork
  }
}

resource r_dataLake_adls_datastores 'Microsoft.MachineLearningServices/workspaces/datastores@2023-06-01-preview' = [for DataLakeContainerName in DataLakeContainerNames: {
  name: 'ds_adls_${DataLakeContainerName}'
  parent: r_mlworkspace
  properties: {
    credentials: {
      credentialsType: 'None'
    }
    description: 'Datastore for the Azure Data Lake Gen2 Account'
    properties: {}
    tags: {}
    datastoreType: 'AzureDataLakeGen2'
    accountName: dataLakeName
    filesystem: DataLakeContainerName
    serviceDataAccessAuthIdentity: 'WorkspaceSystemAssignedIdentity'
  }
}]

resource r_dataLake_blob_datastores 'Microsoft.MachineLearningServices/workspaces/datastores@2023-06-01-preview' = [for DataLakeContainerName in DataLakeContainerNames: {
  name: 'ds_blob_${DataLakeContainerName}'
  parent: r_mlworkspace
  properties: {
    credentials: {
      credentialsType: 'None'
    }
    description: 'Datastore for the Azure Data Lake Gen2 Account'
    properties: {}
    tags: {}
    datastoreType: 'AzureBlob'
    accountName: dataLakeName
    containerName: DataLakeContainerName
    serviceDataAccessAuthIdentity: 'WorkspaceSystemAssignedIdentity'
  }
}]

resource r_loganalytics 'Microsoft.OperationalInsights/workspaces@2021-06-01' existing = if (DeployLogAnalytics == 'True') {
  scope: resourceGroup(logAnalyticsRG)
  name: logAnalyticsName
}

resource r_diagnostics 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = if (DeployLogAnalytics == 'True') {
  scope: r_mlworkspace
  name: '${mlWorkspaceName}-diagnostic-loganalytics'
  properties: {
    workspaceId: r_loganalytics.id
    logs: [
      {
        categoryGroup: 'allLogs'
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

module m_aml_private_endpoint 'private_endpoint_ML.bicep' = if (vnetIntegration) {
  name: 'aml_private_endpoint'
  scope: resourceGroup(privateEndpointRg)
  params: {
    location:location
    VnetforPrivateEndpointsRgName: VnetforPrivateEndpointsRgName
    VnetforPrivateEndpointsName: VnetforPrivateEndpointsName
    PrivateEndpointSubnetName: PrivateEndpointSubnetName
    UseManualPrivateLinkServiceConnections: UseManualPrivateLinkServiceConnections
    DNS_ZONE_SUBSCRIPTION_ID: DNS_ZONE_SUBSCRIPTION_ID
    PrivateDNSZoneRgName: PrivateDNSZoneRgName
    privateDnsZoneName1:privateDnsZoneName1
    privateDnsZoneConfigsName1:replace(privateDnsZoneName1,'.','-')
    privateDnsZoneName2:privateDnsZoneName2
    privateDnsZoneConfigsName2:replace(privateDnsZoneName2,'.','-')
    resourceName: mlWorkspaceName
    resourceID: r_mlworkspace.id
    privateEndpointgroupIds: [
      'amlworkspace'
    ]
    mlStorageName: mlStorageAccountName
    mlWorkspacePrincipalId: r_mlworkspace.identity.principalId
    PrivateEndpointId: PrivateEndpointId
  }
}

