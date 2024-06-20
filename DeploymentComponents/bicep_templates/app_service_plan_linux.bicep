// Copyright (c) Microsoft Corporation.
// Licensed under the MIT license.
param location string = resourceGroup().location

param appServicePlanName string

param appserviceplan_sku string

param appserviceplan_skuCode string

param reserved bool

param zoneRedundant bool

resource r_AppServicePlan 'Microsoft.Web/serverfarms@2022-03-01' = {
  name: appServicePlanName
  location: location
  kind: 'linux'
  sku: {
    tier: appserviceplan_sku
    name: appserviceplan_skuCode
  }
  properties: {
    reserved: reserved
    zoneRedundant: zoneRedundant
  }
  dependsOn: []
}
