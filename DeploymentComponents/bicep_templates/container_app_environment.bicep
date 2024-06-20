// Copyright (c) Microsoft Corporation.
// Licensed under the MIT license.
@description('Location for all resources.')
param location string = resourceGroup().location

param containerAppEnvironmentName string 

param zoneRedundant bool

param DeployContainerAppEnvironmentInVnet string
param VnetForResourcesRgName string
param VnetForResourcesName string
param ContainerAppEnvironmentSubnetName string

var vnetConfigurationIfTrue = {
  infrastructureSubnetId: '/subscriptions/${subscription().subscriptionId}/resourceGroups/${VnetForResourcesRgName}/providers/Microsoft.Network/virtualNetworks/${VnetForResourcesName}/subnets/${ContainerAppEnvironmentSubnetName}'
  internal: true
}

resource r_ContainerAppEnvironment 'Microsoft.App/managedEnvironments@2023-05-01' = {
  name: containerAppEnvironmentName
  location: location
  properties: {
    appLogsConfiguration: {
      destination: 'azure-monitor'
    }
    workloadProfiles: [
      {
        name: 'Consumption'
        workloadProfileType: 'Consumption'
      }
    ]
    vnetConfiguration: (DeployContainerAppEnvironmentInVnet == 'False') ? null : vnetConfigurationIfTrue
    zoneRedundant: zoneRedundant
  }
}
