// Copyright (c) Microsoft Corporation.
// Licensed under the MIT license.
param location string = resourceGroup().location

param appServicePlanName string

param appserviceplan_sku string

param appserviceplan_skuCode string

param maximumElasticWorkerCount int

param zoneRedundant bool

resource r_AppServicePlan 'Microsoft.Web/serverfarms@2022-03-01' = {
  name: appServicePlanName
  location: location
  kind: ''
  sku: {
    tier: appserviceplan_sku
    name: appserviceplan_skuCode
  }
  properties: {
    maximumElasticWorkerCount: maximumElasticWorkerCount
    zoneRedundant: zoneRedundant
  }
  dependsOn: []
}
