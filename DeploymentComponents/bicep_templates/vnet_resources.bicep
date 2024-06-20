// Copyright (c) Microsoft Corporation.
// Licensed under the MIT license.
param location string = resourceGroup().location

param vnetName string

param bastionName string

param DeployMLWorkspace string

//bastion
param DeployVMswithBastion string
param bastionHostScaleUnits int = 2
param enableIpConnect bool
param enableTunneling bool
param enableShareableLink bool
param enableKerberos bool
param disableCopyPaste bool

//firewall
param enableAzureFirewall bool
param azureFirewallTier string

//subnet names
param LogicAppSubnetName string
param PrivateEndpointSubnetName string
//param AKSSubnetName string
param JumpBoxSubnetName string

//subnet address space
param vnetAddressSpace string
var vnetAddressSpaceStart = join(take(split(vnetAddressSpace,'.'),2),'.')
var jumpBoxSubnetAddressSpace = '${vnetAddressSpaceStart}.0.0/24'
var azurePAASResourcesSubnetAddressSpace = '${vnetAddressSpaceStart}.2.0/23'
var bastionSubnetAddressSpace = '${vnetAddressSpaceStart}.4.0/24'
var firewallSubnetAddressSpace = '${vnetAddressSpaceStart}.5.0/24'
var firewallManagementSubnetAddressSpace = '${vnetAddressSpaceStart}.6.0/24'
//var mlAksSubnetAddressSpace = '${vnetAddressSpaceStart}.8.0/21'
var logicAppSubnetAddressSpace = '${vnetAddressSpaceStart}.16.0/24'

var DefaultNsgRules = [
  //{
  //  name: 'AllowVirtualNetworkOutbound'
  //  properties: {
  //    protocol: '*'
  //    sourcePortRange: '*'
  //    destinationPortRange: '*'
  //    sourceAddressPrefix: 'VirtualNetwork'
  //    destinationAddressPrefix: 'VirtualNetwork'
  //    access: 'Allow'
  //    priority: 4095
  //    direction: 'Outbound'
  //  }
  //}
  //{
  //  name: 'DenyAllOutbound'
  //  properties: {
  //    protocol: '*'
  //    sourcePortRange: '*'
  //    destinationPortRange: '*'
  //    sourceAddressPrefix: '*'
  //    destinationAddressPrefix: '*'
  //    access: 'Deny'
  //    priority: 4096
  //    direction: 'Outbound'
  //  }
  //}
]

var nsgMLStudioSubnetNsgRules = [
  {
    name: 'AllowInbound_BatchNodeManagement_29877'
    properties: {
      protocol: 'TCP'
      sourcePortRange: '*'
      destinationPortRange: '29877'
      sourceAddressPrefix: 'BatchNodeManagement'
      destinationAddressPrefix: 'VirtualNetwork'
      access: 'Allow'
      priority: 201
      direction: 'Inbound'
    }
  }
  {
    name: 'AllowInbound_BatchNodeManagement_29876'
    properties: {
      protocol: 'TCP'
      sourcePortRange: '*'
      destinationPortRange: '29876'
      sourceAddressPrefix: 'BatchNodeManagement'
      destinationAddressPrefix: 'VirtualNetwork'
      access: 'Allow'
      priority: 210
      direction: 'Inbound'
    }
  }
  {
    name: 'AllowInbound_AzureMachineLearning_44224'
    properties: {
      protocol: 'TCP'
      sourcePortRange: '*'
      destinationPortRange: '44224'
      sourceAddressPrefix: 'AzureMachineLearning'
      destinationAddressPrefix: 'VirtualNetwork'
      access: 'Allow'
      priority: 220
      direction: 'Inbound'
    }
  }
  {
    name: 'AllowOutbound_AzureActiveDirectory'
    properties: {
      protocol: 'TCP'
      sourcePortRange: '*'
      destinationPortRanges: [
        '80'
        '443'
      ] 
      sourceAddressPrefix: 'VirtualNetwork'
      destinationAddressPrefix: 'AzureActiveDirectory'
      access: 'Allow'
      priority: 140
      direction: 'Outbound'
    }
  }
  {
    name: 'AllowOutbound_AzureMachineLearning'
    properties: {
      protocol: 'TCP'
      sourcePortRange: '*'
      destinationPortRanges: [
        '443'
        '8787'
        '18881'
      ] 
      sourceAddressPrefix: 'VirtualNetwork'
      destinationAddressPrefix: 'AzureMachineLearning'
      access: 'Allow'
      priority: 150
      direction: 'Outbound'
    }
  }
  {
    name: 'AllowOutbound_AzureResourceManager'
    properties: {
      protocol: 'TCP'
      sourcePortRange: '*'
      destinationPortRange: '443'
      sourceAddressPrefix: 'VirtualNetwork'
      destinationAddressPrefix: 'AzureResourceManager'
      access: 'Allow'
      priority: 160
      direction: 'Outbound'
    }
  }
  {
    name: 'AllowOutbound_Storage'
    properties: {
      protocol: 'TCP'
      sourcePortRange: '*'
      destinationPortRanges: [
        '443'
        '445'
      ] 
      sourceAddressPrefix: 'VirtualNetwork'
      destinationAddressPrefix: 'Storage'
      access: 'Allow'
      priority: 170
      direction: 'Outbound'
    }
  }
  {
    name: 'AllowOutbound_AzureFrontDoor_FrontEnd'
    properties: {
      protocol: 'TCP'
      sourcePortRange: '*'
      destinationPortRange: '443'
      sourceAddressPrefix: 'VirtualNetwork'
      destinationAddressPrefix: 'AzureFrontDoor.Frontend'
      access: 'Allow'
      priority: 180
      direction: 'Outbound'
    }
  }
  {
    name: 'AllowOutbound_MicrosoftContainerRegistry'
    properties: {
      protocol: 'TCP'
      sourcePortRange: '*'
      destinationPortRange: '443'
      sourceAddressPrefix: 'VirtualNetwork'
      destinationAddressPrefix: 'MicrosoftContainerRegistry'
      access: 'Allow'
      priority: 190
      direction: 'Outbound'
    }
  }
  {
    name: 'AllowOutbound_AzureMonitor'
    properties: {
      protocol: 'TCP'
      sourcePortRange: '*'
      destinationPortRange: '443'
      sourceAddressPrefix: 'VirtualNetwork'
      destinationAddressPrefix: 'AzureMonitor'
      access: 'Allow'
      priority: 200
      direction: 'Outbound'
    }
  }     
]

var PaasResourcesNsgRuleswithSynapse = [
  {
    name: 'AllowOutbound_AzureActiveDirectory'
    properties: {
      protocol: 'TCP'
      sourcePortRange: '*'
      destinationPortRanges: [
        '80'
        '443'
      ] 
      sourceAddressPrefix: 'VirtualNetwork'
      destinationAddressPrefix: 'AzureActiveDirectory'
      access: 'Allow'
      priority: 140
      direction: 'Outbound'
    }
  }
  {
    name: 'AllowOutbound_AzureResourceManager'
    properties: {
      protocol: 'TCP'
      sourcePortRange: '*'
      destinationPortRange: '443'
      sourceAddressPrefix: 'VirtualNetwork'
      destinationAddressPrefix: 'AzureResourceManager'
      access: 'Allow'
      priority: 160
      direction: 'Outbound'
    }
  }
  {
    name: 'AllowOutbound_AzureFrontDoor_FrontEnd'
    properties: {
      protocol: 'TCP'
      sourcePortRange: '*'
      destinationPortRange: '443'
      sourceAddressPrefix: 'VirtualNetwork'
      destinationAddressPrefix: 'AzureFrontDoor.Frontend'
      access: 'Allow'
      priority: 180
      direction: 'Outbound'
    }
  }
  {
    name: 'AllowOutbound_AzureMonitor'
    properties: {
      protocol: 'TCP'
      sourcePortRange: '*'
      destinationPortRange: '443'
      sourceAddressPrefix: 'VirtualNetwork'
      destinationAddressPrefix: 'AzureMonitor'
      access: 'Allow'
      priority: 200
      direction: 'Outbound'
    }
  }
]

//var aksSubnetNSGRules = [
//  {
//    name: 'AllowOutbound_MicrosoftContainerRegistry'
//    properties: {
//      protocol: 'TCP'
//      sourcePortRange: '*'
//      destinationPortRange: '443'
//      sourceAddressPrefix: 'VirtualNetwork'
//      destinationAddressPrefix: 'MicrosoftContainerRegistry'
//      access: 'Allow'
//      priority: 100
//      direction: 'Outbound'
//    }
//  }
//]

resource r_nsgjumpBoxSubnet 'Microsoft.Network/networkSecurityGroups@2022-01-01' = if (DeployVMswithBastion == 'True') {
  name: '${vnetName}-${JumpBoxSubnetName}-NSG'
  location: location
  properties: {
    securityRules: []
  }
}

resource r_nsgLogicAppsSubnet 'Microsoft.Network/networkSecurityGroups@2022-01-01' = {
  name: '${vnetName}-${LogicAppSubnetName}-NSG'
  location: location
  properties: {
    securityRules: []
  }
}


resource r_nsgazurePAASResourcesSubnet 'Microsoft.Network/networkSecurityGroups@2022-01-01' = {
  name: '${vnetName}-${PrivateEndpointSubnetName}-NSG'
  location: location
  properties: {
    securityRules: (DeployMLWorkspace == 'True')?concat(DefaultNsgRules, nsgMLStudioSubnetNsgRules):concat(DefaultNsgRules, PaasResourcesNsgRuleswithSynapse)
  }
}

//resource r_nsgmlStudioAKSSubnet 'Microsoft.Network/networkSecurityGroups@2022-01-01' = {
//  name: '${vnetName}-${AKSSubnetName}-NSG'
//  location: location
//  properties: {
//    securityRules: concat(DefaultNsgRules, aksSubnetNSGRules)
//  }
//}


resource r_bastionip 'Microsoft.Network/publicIpAddresses@2022-01-01' = if (DeployVMswithBastion == 'True') {
  name: '${bastionName}-ip'
  location: location
  sku: {
    name: 'Standard'
  }
  properties: {
    publicIPAllocationMethod: 'Static'
  }
  tags: {
  }
}

resource r_firewallip 'Microsoft.Network/publicIpAddresses@2022-01-01' = if (enableAzureFirewall) {
  name: '${vnetName}-firewall-ip'
  location: location
  sku: {
    name: 'Standard'
  }
  properties: {
    publicIPAllocationMethod: 'Static'
  }
  tags: {
  }
}

resource r_firewallManagementip 'Microsoft.Network/publicIpAddresses@2022-01-01' = if (enableAzureFirewall && azureFirewallTier == 'Basic') {
  name: '${vnetName}-firewall-management-ip'
  location: location
  sku: {
    name: 'Standard'
  }
  properties: {
    publicIPAllocationMethod: 'Static'
  }
  tags: {
  }
}

resource r_routeTable 'Microsoft.Network/routeTables@2022-01-01' = if (enableAzureFirewall) {
  name: '${vnetName}-routetable'
  location: location
  properties: {
    disableBgpRoutePropagation: false
    routes: [
    ]
  }
}

resource r_vnet 'Microsoft.Network/virtualNetworks@2022-01-01' existing = {
  name: vnetName
}

resource r_jumpBoxSubnet 'Microsoft.Network/virtualNetworks/subnets@2020-11-01' = if (DeployVMswithBastion == 'True') {
  parent: r_vnet
  name: JumpBoxSubnetName
  properties: {
    addressPrefix: jumpBoxSubnetAddressSpace
    networkSecurityGroup: {
      id: r_nsgjumpBoxSubnet.id
    }
    routeTable: (enableAzureFirewall==false)?null:{
      id: r_routeTable.id
    }
    serviceEndpoints: []
    delegations: []
    privateEndpointNetworkPolicies: 'Disabled'
    privateLinkServiceNetworkPolicies: 'Disabled'
  }
}

resource r_AzurePaasResourcesSubnet 'Microsoft.Network/virtualNetworks/subnets@2020-11-01' = {
  parent: r_vnet
  name: PrivateEndpointSubnetName
  properties: {
    addressPrefix: azurePAASResourcesSubnetAddressSpace
    networkSecurityGroup: {
      id: r_nsgazurePAASResourcesSubnet.id
    }
    serviceEndpoints: []
    delegations: []
    privateEndpointNetworkPolicies: 'Disabled'
    privateLinkServiceNetworkPolicies: 'Disabled'
  }
  dependsOn: [
    r_jumpBoxSubnet
  ]
}

resource r_bastionSubnet 'Microsoft.Network/virtualNetworks/subnets@2020-11-01' = if (DeployVMswithBastion == 'True') {
  parent: r_vnet
  name: 'AzureBastionSubnet'
  properties: {
    addressPrefix: bastionSubnetAddressSpace
    serviceEndpoints: []
    delegations: []
    privateEndpointNetworkPolicies: 'Disabled'
    privateLinkServiceNetworkPolicies: 'Disabled'
  }
  dependsOn: [
    r_AzurePaasResourcesSubnet
  ]
}

//resource r_mlAksSubnet 'Microsoft.Network/virtualNetworks/subnets@2020-11-01' = if (DeployMLWorkspace == 'True') {
//  parent: r_vnet
//  name: AKSSubnetName
//  properties: {
//    addressPrefix: mlAksSubnetAddressSpace
//    networkSecurityGroup: {
//      id: r_nsgmlStudioAKSSubnet.id
//    }
//    serviceEndpoints: []
//    delegations: []
//    privateEndpointNetworkPolicies: 'Disabled'
//    privateLinkServiceNetworkPolicies: 'Disabled'
//  }
//  dependsOn: [
//    r_bastionSubnet
//  ]
//}

resource r_logicAppSubnet 'Microsoft.Network/virtualNetworks/subnets@2022-01-01' = {
  parent: r_vnet
  name: LogicAppSubnetName
  properties: {
    addressPrefix: logicAppSubnetAddressSpace
    networkSecurityGroup: {
      id: r_nsgLogicAppsSubnet.id
    }
    delegations: [
      {
        name: 'delegation'
        id: '${r_vnet.id}/subnets/${LogicAppSubnetName}/delegations/delegation'
        properties: {
          serviceName: 'Microsoft.Web/serverfarms'
        }
        type: 'Microsoft.Network/virtualNetworks/subnets/delegations'
      }
    ]
    privateEndpointNetworkPolicies: 'Disabled'
    privateLinkServiceNetworkPolicies: 'Disabled'
  }
  dependsOn: [
    
  ]
}

resource r_AzureFirewallSubnet 'Microsoft.Network/virtualNetworks/subnets@2020-11-01' = if (enableAzureFirewall) {
  parent: r_vnet
  name: 'AzureFirewallSubnet'
  properties: {
    addressPrefix: firewallSubnetAddressSpace
    serviceEndpoints: []
    delegations: []
    privateEndpointNetworkPolicies: 'Disabled'
    privateLinkServiceNetworkPolicies: 'Disabled'
  }
  dependsOn: [
    r_logicAppSubnet
  ]
}

resource r_firewallMgmtSubnet 'Microsoft.Network/virtualNetworks/subnets@2020-11-01' = if (enableAzureFirewall && azureFirewallTier == 'Basic') {
  parent: r_vnet
  name: 'AzureFirewallManagementSubnet'
  properties: {
    addressPrefix: firewallManagementSubnetAddressSpace
    serviceEndpoints: []
    delegations: []
    privateEndpointNetworkPolicies: 'Disabled'
    privateLinkServiceNetworkPolicies: 'Disabled'
  }
  dependsOn: [
    r_AzureFirewallSubnet
  ]
}

resource r_Bastion 'Microsoft.Network/bastionHosts@2022-01-01' = if (DeployVMswithBastion == 'True') {
  name: bastionName
  sku: {
    name: 'Standard'
  }
  location: location
  properties: {
    enableIpConnect: enableIpConnect
    enableTunneling: enableTunneling
    enableShareableLink: enableShareableLink
    enableKerberos: enableKerberos
    disableCopyPaste: disableCopyPaste
    ipConfigurations: [
      {
        name: 'IpConf'
        properties: {
          subnet: {
            id: '${r_vnet.id}/subnets/AzureBastionSubnet'
          }
          publicIPAddress: {
            id: r_bastionip.id
          }
        }
      }
    ]
    scaleUnits: bastionHostScaleUnits
  }
  tags: {
  }
  dependsOn: [
    r_bastionSubnet
  ]
}

resource r_firewallPolicy 'Microsoft.Network/firewallPolicies@2020-11-01' = if (enableAzureFirewall) {
  name: '${vnetName}-firewall-policy'
  location: location
  properties: {
    sku: {
      tier: azureFirewallTier
    }
    threatIntelMode: (azureFirewallTier == 'Basic')?null:'Deny'
  }
}

resource r_firewallApplicationRules 'Microsoft.Network/firewallPolicies/ruleCollectionGroups@2020-11-01' = if (enableAzureFirewall) {
  parent: r_firewallPolicy
  name: 'DefaultApplicationRuleCollectionGroup'
  properties: {
    priority: 300
    ruleCollections: [
      {
        ruleCollectionType: 'FirewallPolicyFilterRuleCollection'
        action: {
          type: 'Allow'
        }
        rules: [
          {
            ruleType: 'ApplicationRule'
            name: 'allow-outbound-internet'
            protocols: [
              {
                protocolType: 'Https'
                port: 443
              }
            ]
            fqdnTags: []
            webCategories: []
            targetFqdns: [
              '*'
            ]
            targetUrls: []
            terminateTLS: false
            sourceAddresses: [
              jumpBoxSubnetAddressSpace
            ]
            destinationAddresses: []
            sourceIpGroups: []
          }
        ]
        name: 'allow-outbound-internet'
        priority: 300
      }
    ]
  }
}


resource r_azureFirewall 'Microsoft.Network/azureFirewalls@2022-01-01' = if (enableAzureFirewall) {
  name: '${vnetName}-firewall'
  location: location
  properties: {
    sku: {
      tier: azureFirewallTier
    }
    ipConfigurations: [
      {
        name: 'IpConf'
        properties: {
          subnet: {
            id: '${r_vnet.id}/subnets/AzureFirewallSubnet'
          }
          publicIPAddress: {
            id: r_firewallip.id
          }
        }
      }
    ]
    managementIpConfiguration: (azureFirewallTier != 'Basic')?null:{
        name: 'IpConf'
        properties: {
          subnet: {
            id: '${r_vnet.id}/subnets/AzureFirewallManagementSubnet'
          }
          publicIPAddress: {
            id: r_firewallManagementip.id
          }
        }
    }
    firewallPolicy: {
      id: r_firewallPolicy.id
    }
  }
  dependsOn: [
    r_firewallMgmtSubnet
  ]
}

resource r_routetoFirewall 'Microsoft.Network/routeTables/routes@2022-01-01' = if (enableAzureFirewall) {
  parent: r_routeTable
  name: 'route-to-firewall'
  properties: {
    addressPrefix: '0.0.0.0/0'
    nextHopType: 'VirtualAppliance'
    nextHopIpAddress: (enableAzureFirewall==false)?null:r_azureFirewall.properties.ipConfigurations[0].properties.privateIPAddress
    hasBgpOverride: false
  }
  dependsOn: [
    r_routeTable
  ]
}
