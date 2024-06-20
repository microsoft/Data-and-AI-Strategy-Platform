// Copyright (c) Microsoft Corporation.
// Licensed under the MIT license.
param location string = resourceGroup().location

param vnetName string

param loganalytics_Name string

param loganalytics_resourceID string

param privateEndpointgroupIds array

var blobprivateDnsZoneName = 'privatelink.blob.${environment().suffixes.storage}'

var privateLinkScopeName = 'azuremonitor-privatelinkscope'

resource r_privateLinkScope 'microsoft.insights/privateLinkScopes@2021-07-01-preview' = {
  name: privateLinkScopeName
  location: 'global'
  properties: {
    accessModeSettings: {
      ingestionAccessMode: 'Open'
      queryAccessMode: 'Open'
    }
  }
}

resource r_logAnalyticsPrivateLinkScope 'Microsoft.Insights/privateLinkScopes/scopedResources@2021-07-01-preview' = {
  name: loganalytics_Name
  parent: r_privateLinkScope
  properties: {
    linkedResourceId: loganalytics_resourceID
  }
}

resource r_vnet 'Microsoft.Network/virtualNetworks@2022-01-01' existing = {
  name: vnetName
}

resource r_PrivateEndpoint 'Microsoft.Network/privateEndpoints@2021-05-01' = {
  name: '${vnetName}-${privateLinkScopeName}-${first(privateEndpointgroupIds)}'
  location: location
  properties: {
    subnet: {
      id: '${r_vnet.id}/subnets/azurePaasPE'
    }
    customNetworkInterfaceName: '${vnetName}-${privateLinkScopeName}-${first(privateEndpointgroupIds)}-nic'
    privateLinkServiceConnections: [
      {
        name: '${vnetName}-${privateLinkScopeName}-${first(privateEndpointgroupIds)}'
        properties: {
          privateLinkServiceId: r_privateLinkScope.id
          groupIds: privateEndpointgroupIds
        }
      }
    ]
  }
  tags: {
  }
  dependsOn: [
    r_logAnalyticsPrivateLinkScope
  ]
}


resource r_PrivateZone_monitorazure 'Microsoft.Network/privateDnsZones@2020-06-01' = {
  name: 'privatelink.monitor.azure.com'
  location: 'global'
  tags: {
  }
  properties: {
  }
  dependsOn: [
    r_PrivateEndpoint
  ]
}

resource r_PrivateZoneVNETLink_monitorazure 'Microsoft.Network/privateDnsZones/virtualNetworkLinks@2020-06-01' = {
  parent: r_PrivateZone_monitorazure
  name: 'privatelink.monitor.azure.com-link'
  location: 'global'
  properties: {
    virtualNetwork: {
      id: r_vnet.id
    }
    registrationEnabled: false
  }
  dependsOn: [
    r_PrivateEndpointZoneGroup
  ]
}

resource r_PrivateZone_omsopinsights 'Microsoft.Network/privateDnsZones@2020-06-01' = {
  name: 'privatelink.oms.opinsights.azure.com'
  location: 'global'
  tags: {
  }
  properties: {
  }
  dependsOn: [
    r_PrivateEndpoint
  ]
}

resource r_PrivateZoneVNETLink_omsopinsights 'Microsoft.Network/privateDnsZones/virtualNetworkLinks@2020-06-01' = {
  parent: r_PrivateZone_omsopinsights
  name: 'privatelink.oms.opinsights.azure.com-link'
  location: 'global'
  properties: {
    virtualNetwork: {
      id: r_vnet.id
    }
    registrationEnabled: false
  }
  dependsOn: [
    r_PrivateEndpointZoneGroup
  ]
}

resource r_PrivateZone_odsopinsights 'Microsoft.Network/privateDnsZones@2020-06-01' = {
  name: 'privatelink.ods.opinsights.azure.com'
  location: 'global'
  tags: {
  }
  properties: {
  }
  dependsOn: [
    r_PrivateEndpoint
  ]
}

resource r_PrivateZoneVNETLink_odsopinsights 'Microsoft.Network/privateDnsZones/virtualNetworkLinks@2020-06-01' = {
  parent: r_PrivateZone_odsopinsights
  name: 'privatelink.ods.opinsights.azure.com-link'
  location: 'global'
  properties: {
    virtualNetwork: {
      id: r_vnet.id
    }
    registrationEnabled: false
  }
  dependsOn: [
    r_PrivateEndpointZoneGroup
  ]
}

resource r_PrivateZone_agentsvcazureautomation 'Microsoft.Network/privateDnsZones@2020-06-01' = {
  name: 'privatelink.agentsvc.azure-automation.net'
  location: 'global'
  tags: {
  }
  properties: {
  }
  dependsOn: [
    r_PrivateEndpoint
  ]
}

resource r_PrivateZoneVNETLink_agentsvcazureautomation 'Microsoft.Network/privateDnsZones/virtualNetworkLinks@2020-06-01' = {
  parent: r_PrivateZone_agentsvcazureautomation
  name: 'privatelink.agentsvc.azure-automation.net-link'
  location: 'global'
  properties: {
    virtualNetwork: {
      id: r_vnet.id
    }
    registrationEnabled: false
  }
  dependsOn: [
    r_PrivateEndpointZoneGroup
  ]
}

resource r_PrivateZone_Blob 'Microsoft.Network/privateDnsZones@2020-06-01' = {
  name: blobprivateDnsZoneName
  location: 'global'
  tags: {
  }
  properties: {
  }
  dependsOn: [
    r_PrivateEndpoint
  ]
}

resource r_PrivateZoneVNETLink_Blob 'Microsoft.Network/privateDnsZones/virtualNetworkLinks@2020-06-01' = {
  parent: r_PrivateZone_Blob
  name: '${blobprivateDnsZoneName}-link'
  location: 'global'
  properties: {
    virtualNetwork: {
      id: r_vnet.id
    }
    registrationEnabled: false
  }
  dependsOn: [
    r_PrivateEndpointZoneGroup

  ]
}

resource r_PrivateEndpointZoneGroup 'Microsoft.Network/privateEndpoints/privateDnsZoneGroups@2021-05-01' = {
  name: '${vnetName}-${privateLinkScopeName}-${first(privateEndpointgroupIds)}/default'
  properties: {
    privateDnsZoneConfigs: [
      {
        name: 'privatelink-monitor-azure-com'
        properties: {
          privateDnsZoneId: r_PrivateZone_monitorazure.id
        }
      }
      {
        name: 'privatelink-oms-opinsights-azure-com'
        properties: {
          privateDnsZoneId: r_PrivateZone_omsopinsights.id
        }
      }
      {
        name: 'privatelink-ods-opinsights-azure-com'
        properties: {
          privateDnsZoneId: r_PrivateZone_odsopinsights.id
        }
      }
      {
        name: 'privatelink-agentsvc-azure-automation-net'
        properties: {
          privateDnsZoneId: r_PrivateZone_agentsvcazureautomation.id
        }
      }
      {
        name: 'privatelink-blob-core-windows-net'
        properties: {
          privateDnsZoneId: r_PrivateZone_Blob.id
        }
      }
    ]
  }
  dependsOn: [
    r_PrivateEndpoint
    r_PrivateZone_monitorazure
    r_PrivateZone_omsopinsights
    r_PrivateZone_odsopinsights
    r_PrivateZone_agentsvcazureautomation
    r_PrivateZone_Blob
  ]
}
