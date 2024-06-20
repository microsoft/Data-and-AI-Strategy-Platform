// Copyright (c) Microsoft Corporation.
// Licensed under the MIT license.
param privateDnsZoneName string
param vnet_id string

resource r_PrivateZone 'Microsoft.Network/privateDnsZones@2020-06-01' = {
  name: privateDnsZoneName
  location: 'global'
  tags: {
  }
  properties: {
  }
}

resource r_PrivateZoneVNETLink 'Microsoft.Network/privateDnsZones/virtualNetworkLinks@2020-06-01' = {
  parent: r_PrivateZone
  name: '${privateDnsZoneName}-link'
  location: 'global'
  properties: {
    virtualNetwork: {
      id: vnet_id
    }
    registrationEnabled: false
  }
}
