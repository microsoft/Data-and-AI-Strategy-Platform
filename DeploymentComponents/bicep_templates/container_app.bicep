// Copyright (c) Microsoft Corporation.
// Licensed under the MIT license.
@description('Location for all resources.')
param location string = resourceGroup().location

param containerAppName string

param containerAppEnvironmentName string 

param containers array

@secure()
param secrets object = {
  arrayValue: []
}

param registries array
param ingress object


resource r_ContainerAppEnvironment 'Microsoft.App/managedEnvironments@2023-05-01' existing = {
  name: containerAppEnvironmentName
}

resource r_ContainerApp 'Microsoft.App/containerapps@2023-05-01' = {
  name: containerAppName
  location: location
  properties: {
    environmentId: r_ContainerAppEnvironment.id
    configuration: {
      registries: registries
      activeRevisionsMode: 'Single'
      ingress: ingress
    }
    template: {
      containers: containers
      scale: {
        minReplicas: 0
      }
    }
    workloadProfileName: 'Consumption'
  }
}

