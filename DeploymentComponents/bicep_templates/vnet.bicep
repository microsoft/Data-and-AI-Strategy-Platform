// Copyright (c) Microsoft Corporation.
// Licensed under the MIT license.
param location string = resourceGroup().location

param vnetName string

param vnetAddressSpace string

resource r_vnet 'Microsoft.Network/virtualNetworks@2022-01-01' = {
  name: vnetName
  location: location
  properties: {
    addressSpace: {
      addressPrefixes: [
        vnetAddressSpace
      ]
    }
    dhcpOptions: {
      dnsServers: []
    }
    subnets: []
    virtualNetworkPeerings: []
    enableDdosProtection: false
  }
}
