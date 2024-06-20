// Copyright (c) Microsoft Corporation.
// Licensed under the MIT license.
@description('Location for all resources.')
param location string = resourceGroup().location

param fabricCapacityName string

param adminEntraId string

@allowed([
  'F2'
  'F4'
  'F8'
  'F16'
  'F32'
  'F64'
  'F128'
  'F256'
  'F512'
  'F1024'
  'F2048'
])
param sku string

resource r_fabricCapacity 'Microsoft.Fabric/capacities@2022-07-01-preview' = {
  name: fabricCapacityName
  location: location
  sku: {
    name: sku
    tier: 'Fabric'
  }
  properties: {
    administration: {
      members: [
        adminEntraId
      ]
    }
  }
}
