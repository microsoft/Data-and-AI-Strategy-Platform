// Copyright (c) Microsoft Corporation.
// Licensed under the MIT license.
param location string = resourceGroup().location

param virtualMachineName string

param numOfVMs string

param virtualMachineSize string

param vmImagePublisher string = 'MicrosoftWindowsServer'

param vmImageOffer string = 'WindowsServer'

param vmImageSku string = '2022-datacenter-azure-edition'

param vmImageVersion string = 'latest'

param adminUsername string

@secure()
param adminPassword string

param enableAcceleratedNetworking bool

param osDiskType string

param osDiskDeleteOption string

param nicDeleteOption string

param patchMode string

param enableHotpatching bool

param zones array = [
    '1'
]

param VnetForResourcesRgName string 
param VnetForResourcesName string 
param JumpBoxSubnetName string

param AAD_Admin_Group_ID string

var azureRBACVirtualMachineUserLoginRoleID = '1c0163c0-47e6-4577-8991-ea5c82e286e4' //Virtual Machine Adminstrator Login

var numOfVmsArray = range(1, int(numOfVMs))

resource r_vnet 'Microsoft.Network/virtualNetworks@2022-01-01' existing = {
  scope: resourceGroup(VnetForResourcesRgName)
  name: VnetForResourcesName
}

var subnetRef = '${r_vnet.id}/subnets/${JumpBoxSubnetName}'

resource r_vm_NIC 'Microsoft.Network/networkInterfaces@2021-03-01' = [for vmId in numOfVmsArray: {
  name: '${virtualMachineName}-0${vmId}-nic'
  location: location
  properties: {
    ipConfigurations: [
      {
        name: 'ipconfig1'
        properties: {
          subnet: {
            id: subnetRef
          }
          privateIPAllocationMethod: 'Dynamic'
        }
      }
    ]
    enableAcceleratedNetworking: enableAcceleratedNetworking
  }
  dependsOn: []
}]

resource r_vm 'Microsoft.Compute/virtualMachines@2022-03-01' =  [for vmId in numOfVmsArray: {
  name: '${virtualMachineName}-0${vmId}'
  location: location
  zones: zones
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    hardwareProfile: {
      vmSize: virtualMachineSize
    }
    storageProfile: {
      osDisk: {
        createOption: 'fromImage'
        managedDisk: {
          storageAccountType: osDiskType
        }
        deleteOption: osDiskDeleteOption
      }
      imageReference: {
        publisher: vmImagePublisher
        offer: vmImageOffer
        sku: vmImageSku
        version: vmImageVersion
      }
    }
    networkProfile: {
      networkInterfaces: [
        {
          id: r_vm_NIC[vmId-1].id
          properties: {
            deleteOption: nicDeleteOption
          }
        }
      ]
    }
    osProfile: {
      computerName: '${take(virtualMachineName,12)}-0${vmId}'
      adminUsername: adminUsername
      adminPassword: adminPassword
      windowsConfiguration: {
        enableAutomaticUpdates: true
        provisionVMAgent: true
        patchSettings: {
          enableHotpatching: enableHotpatching
          patchMode: patchMode
        }
      }
      allowExtensionOperations: true
    }
    diagnosticsProfile: {
      bootDiagnostics: {
        enabled: true
      }
    }
    licenseType: 'Windows_Client'
  }
  dependsOn: [
    r_vm_NIC
  ]
}]

resource r_IaaSAntimalware 'Microsoft.Compute/virtualMachines/extensions@2022-03-01' = [for vmId in numOfVmsArray: {
  name: '${virtualMachineName}-0${vmId}/IaaSAntimalware'
  location: location
  properties: {
    autoUpgradeMinorVersion: true
    publisher: 'Microsoft.Azure.Security'
    type: 'IaaSAntimalware'
    typeHandlerVersion: '1.3'
    settings: {
      AntimalwareEnabled: true
      RealtimeProtectionEnabled: 'true'
      ScheduledScanSettings: {
        isEnabled: 'true'
        day: '7'
        time: '120'
        scanType: 'Quick'
      }
      Exclusions: {
        Paths: null
        Extensions: null
        Processes: null
      }
    }
  }
  dependsOn: [
    r_vm
  ]
}]

resource r_AADLoginForWindows 'Microsoft.Compute/virtualMachines/extensions@2022-03-01' = [for vmId in numOfVmsArray: {
  name: '${virtualMachineName}-0${vmId}/AADLoginForWindows'
  location: location
  properties: {
    publisher: 'Microsoft.Azure.ActiveDirectory'
    type: 'AADLoginForWindows'
    typeHandlerVersion: '1.0'
  }
  dependsOn: [
    r_IaaSAntimalware
  ]
}]

//Grant Virtual Machine Adminstrator Login to Admin AAD Group on VM
resource r_dataLakeRoleAssignmentAADGroup 'Microsoft.Authorization/roleAssignments@2022-04-01' = [for vmId in numOfVmsArray: {
  name: guid('${virtualMachineName}-0${vmId}', 'admin_group')
  scope: r_vm[vmId-1]
  properties:{
    roleDefinitionId: resourceId('Microsoft.Authorization/roleDefinitions', azureRBACVirtualMachineUserLoginRoleID)
    principalId: AAD_Admin_Group_ID
    principalType:'Group'
  }
}]
