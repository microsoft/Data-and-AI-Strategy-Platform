// Copyright (c) Microsoft Corporation.
// Licensed under the MIT license.
param location string = resourceGroup().location

param mlWorkspaceName string

param dataLakeName string

param PrimaryRgName string

param Assign_RBAC_On_Deployment string

//ml cluster
param imageBuildComputeCluster object
param computeClusters array

//private access
param DeployWithCustomNetworking string
param CreatePrivateEndpoints string

param DeployMLWorkspaceInCustomerVnet string
param VnetForResourcesRgName string
param VnetForResourcesName string
param MLComputeSubnetName string

var vnetIntegration = (DeployWithCustomNetworking == 'True' && CreatePrivateEndpoints == 'True')?true:false
var DeployInCustomVnet = (DeployWithCustomNetworking == 'True' && DeployMLWorkspaceInCustomerVnet == 'True')?true:false

var subnetId = '/subscriptions/${subscription().subscriptionId}/resourceGroups/${VnetForResourcesRgName}/providers/Microsoft.Network/virtualNetworks/${VnetForResourcesName}/subnets/${MLComputeSubnetName}'

resource r_mlworkspace 'Microsoft.MachineLearningServices/workspaces@2023-06-01-preview' existing = {
  name: mlWorkspaceName
}

resource r_mlImageCompute 'Microsoft.MachineLearningServices/workspaces/computes@2023-06-01-preview' = {
  name: imageBuildComputeCluster.ClusterName
  parent: r_mlworkspace
  location: location
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    disableLocalAuth: imageBuildComputeCluster.disableLocalAuth
    computeType: 'AmlCompute'
    properties: {
      vmSize: imageBuildComputeCluster.VMSize
      vmPriority: imageBuildComputeCluster.mlComputevmPriority
      enableNodePublicIp: (vnetIntegration)?false:true
      osType: imageBuildComputeCluster.mlComputevmOSType
      remoteLoginPortPublicAccess: imageBuildComputeCluster.mlComputeremoteLoginPortPublicAccess
      scaleSettings: {
        minNodeCount: imageBuildComputeCluster.minNodeCount
        maxNodeCount: imageBuildComputeCluster.maxNodeCount
        nodeIdleTimeBeforeScaleDown: imageBuildComputeCluster.mlComputerscaleSettingsIdleTimeBeforeScaleDown
      }
      subnet: (DeployInCustomVnet == false) ? null : {
        id: subnetId
      }
    }
  }
  dependsOn: [
  ]
}

resource r_mlCompute 'Microsoft.MachineLearningServices/workspaces/computes@2023-06-01-preview' = [for computeCluster in computeClusters: {
  name: computeCluster.ClusterName
  parent: r_mlworkspace
  location: location
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    disableLocalAuth: computeCluster.disableLocalAuth
    computeType: 'AmlCompute'
    properties: {
      vmSize: computeCluster.VMSize
      vmPriority: computeCluster.mlComputevmPriority
      enableNodePublicIp: (vnetIntegration)?false:true
      osType: computeCluster.mlComputevmOSType
      remoteLoginPortPublicAccess: computeCluster.mlComputeremoteLoginPortPublicAccess
      scaleSettings: {
        minNodeCount: computeCluster.minNodeCount
        maxNodeCount: computeCluster.maxNodeCount
        nodeIdleTimeBeforeScaleDown: computeCluster.mlComputerscaleSettingsIdleTimeBeforeScaleDown
      }
      subnet: (DeployInCustomVnet == false) ? null : {
        id: subnetId
      }
    }
  }
  dependsOn: [
  ]
}]

//give ml compute cluster rbac reader rights to data lake
module r_mlCompteClusterDataLake_rbac 'rbac_storage_reader.bicep' = [for computeCluster in computeClusters: if (Assign_RBAC_On_Deployment == 'True') {
  scope: resourceGroup(PrimaryRgName)
  name: '${computeCluster.ClusterName}_datalake_rbac_reader'
  params: {
    azureResourceName: '${mlWorkspaceName}-${computeCluster.ClusterName}-${r_mlCompute[computeCluster.id].identity.principalId}-datalake-rbac-reader'
    storageAccountName: dataLakeName
    principalId: r_mlCompute[computeCluster.id].identity.principalId
  }
}]

//give ml compute cluster rbac contributor rights to curated zone of data lake
module r_mlCompteClusterCuratedZone_rbac 'rbac_storage_contrib_container.bicep' = [for computeCluster in computeClusters: if (Assign_RBAC_On_Deployment == 'True') {
  scope: resourceGroup(PrimaryRgName)
  name: '${computeCluster.ClusterName}_datalake_Contributor_Curated_Zone'
  params: {
    azureResourceName: '${mlWorkspaceName}-${computeCluster.ClusterName}-${r_mlCompute[computeCluster.id].identity.principalId}-datalake-Contributor-Curated-Zone'
    storageAccountName: dataLakeName
    containerName: 'curated'
    principalId: r_mlCompute[computeCluster.id].identity.principalId
    principalType: 'ServicePrincipal'
  }
}]
