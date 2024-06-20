// Copyright (c) Microsoft Corporation.
// Licensed under the MIT license.
@description('The location of AKS resource.')
param location string = resourceGroup().location

@description('The name of the Managed Cluster resource.')
param aksClusterName string

@description('Free = 99.5% uptime. Paid = 99.9% uptime.')
@allowed([
  'Free'
  'Paid'
])
param clusterTier string

@description('Disk size (in GiB) to provision for each of the agent pool nodes. This value ranges from 0 to 1023. Specifying 0 will apply the default disk size for that agentVMSize.')
@minValue(0)
@maxValue(1023)
param osDiskSizeGB int = 0

@description('The version of Kubernetes.')
param kubernetesVersion string

@description('Determine if/how Kubernetes is auto upgraded.')
@allowed([
  'node-image'
  'none'
  'patch'
  'rapid'
  'stable'
])
param kubernetesAutomaticUpgrade string

@description('Boolean flag to turn on and off of RBAC.')
param enableRBAC bool

@description('An array of AAD group object ids to give administrative access.')
param adminGroupObjectID string

@description('Enable or disable Azure RBAC.')
param azureRbac bool

@description('Enable or disable local accounts.')
param disableLocalAccounts bool

@description('Enable private network access to the Kubernetes cluster.')
param DeployResourcesWithPublicAccess string 
var enablePrivateCluster = (DeployResourcesWithPublicAccess == 'True')?false:true

@description('Boolean flag to turn on and off http application routing.')
param enableHttpApplicationRouting bool

@description('Boolean flag to turn on and off Azure Policy addon.')
param enableAzurePolicy bool = false

@description('Boolean flag to turn on and off secret store CSI driver.')
param enableSecretStoreCSIDriver bool = false

@description('A CIDR notation IP range from which to assign service cluster IPs.')
param serviceCidr string

@description('Containers DNS server IP address.')
param dnsServiceIP string

@description('A CIDR notation IP for Docker bridge.')
param dockerBridgeCidr string

@description('the maximum number of pods per node.')
param maxPods int

@description('vm sku for node pool')
param vm_sku string

param nodecount int

param enableAutoScaling bool
param minnodecount int
param maxnodecount int

//vnet integration
param DeployWithCustomNetworking string
param DeployAKSInVnet string
param VnetForResourcesRgName string
param VnetForResourcesName string
param AksSubnetName string

param mlWorkspaceName string
param existingAksName string

@secure()
param servicePrincipalObjectId string

//networking
param AksUseKubenetNetworking string

var vnetIntegration = (DeployWithCustomNetworking == 'True' && DeployAKSInVnet == 'True')?true:false

var networkingType = (DeployWithCustomNetworking == 'True' && DeployAKSInVnet == 'True' && AksUseKubenetNetworking == 'False')?'azure':'kubenet'

var vnet_networkProfile = {
  networkPlugin: 'azure'
  serviceCidr: serviceCidr
  dnsServiceIP: dnsServiceIP
  dockerBridgeCidr: dockerBridgeCidr
  loadBalancerSku: 'standard'
}

var kubenet_networkProfile = {
  networkPlugin: 'kubenet'
  serviceCidr: '10.0.0.0/16'
  dnsServiceIP: '10.0.0.10'
  dockerBridgeCidr: '172.17.0.1/16'
  loadBalancerSku: 'standard'
}

resource r_vnet 'Microsoft.Network/virtualNetworks@2022-01-01' existing = if (vnetIntegration) {
  scope: resourceGroup(VnetForResourcesRgName)
  name: VnetForResourcesName
}

resource r_akssubnet 'Microsoft.Network/virtualNetworks/subnets@2022-01-01' existing = if (vnetIntegration) {
  parent: r_vnet
  name: AksSubnetName
}

resource r_aksCluster 'Microsoft.ContainerService/managedClusters@2022-06-01' = {
  location: location
  name: aksClusterName
  identity: {
    type: 'SystemAssigned'
  }
  sku: {
    name: 'Basic'
    tier: clusterTier
  }
  tags: {
  }
  properties: {
    kubernetesVersion: kubernetesVersion
    enableRBAC: enableRBAC
    dnsPrefix: '${aksClusterName}-dns'
    nodeResourceGroup: '${aksClusterName}-node-rg'
    agentPoolProfiles: [
      {
        name: 'agentpool'
        osDiskSizeGB: osDiskSizeGB
        count: (enableAutoScaling)?minnodecount:nodecount
        enableAutoScaling: enableAutoScaling
        minCount: (enableAutoScaling)?minnodecount:null
        maxCount: (enableAutoScaling)?maxnodecount:null
        vmSize: vm_sku
        osType: 'Linux'
        storageProfile: 'ManagedDisks'
        type: 'VirtualMachineScaleSets'
        mode: 'System'
        maxPods: maxPods
        availabilityZones: []
        nodeTaints: []
        vnetSubnetID: (vnetIntegration==false)?null:r_akssubnet.id
      }
    ]
    networkProfile: (networkingType == 'kubenet')?kubenet_networkProfile:vnet_networkProfile
    disableLocalAccounts: disableLocalAccounts
    aadProfile: {
      managed: true
      adminGroupObjectIDs: [
        adminGroupObjectID
      ]
      enableAzureRBAC: azureRbac
    }
    apiServerAccessProfile: {
      enablePrivateCluster: enablePrivateCluster
    }
    autoUpgradeProfile: {
      upgradeChannel: kubernetesAutomaticUpgrade
    }
    addonProfiles: {
      httpApplicationRouting: {
        enabled: enableHttpApplicationRouting
      }
      azurepolicy: {
        enabled: enableAzurePolicy
      }
      azureKeyvaultSecretsProvider: {
        enabled: enableSecretStoreCSIDriver
        config: null
      }
    }
  }
  dependsOn: []
}

var kubernetesRBACAdmin = '3498e952-d568-435e-9b2c-8d77e338d7f7'

resource r_servicePrincipalKubernetesAdmin 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid(r_aksCluster.id, 'servicePrincipal')
  scope: r_aksCluster
  properties:{
    roleDefinitionId: resourceId('Microsoft.Authorization/roleDefinitions', kubernetesRBACAdmin)
    principalId: servicePrincipalObjectId
    principalType: 'ServicePrincipal'
  }
}

resource r_adminGroupKubernetesAdmin 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid(r_aksCluster.id, 'adminGroup')
  scope: r_aksCluster
  properties:{
    roleDefinitionId: resourceId('Microsoft.Authorization/roleDefinitions', kubernetesRBACAdmin)
    principalId: adminGroupObjectID
    principalType:'Group'
  }
}

module rbac_networkContributor 'rbac_networkContributor.bicep' = if (vnetIntegration) {
  name: 'rbac_networkContributor'
  scope: resourceGroup(VnetForResourcesRgName)
  params: {
    aksClusterName: aksClusterName
    aksPrincipalId: r_aksCluster.identity.principalId
    vnetName: VnetForResourcesName
  }
  dependsOn: [
    r_aksCluster
  ]
}

//azure cli v1 step
//resource r_AKSCompute 'Microsoft.MachineLearningServices/workspaces/computes@2022-05-01' = if (existingAksName == '') {
//  name: '${mlWorkspaceName}/AksCluster01'
//  location: location
//  properties: {
//    computeType: 'AKS'
//    resourceId: r_aksCluster.id
//    properties: {
//      aksNetworkingConfiguration: (networkingType == 'kubenet')?null:{
//        subnetId: r_akssubnet.id
//      }
//    }
//  }
//  dependsOn: [
//    r_aksCluster
//  ]
//}
