// Copyright (c) Microsoft Corporation.
// Licensed under the MIT license.
param location string = resourceGroup().location

param synapseWorkspaceName string

//synapse pools that can be deployed from Bicep
param computePools array

resource r_synapseWorkspace 'Microsoft.Synapse/workspaces@2021-06-01' existing = {
  name: synapseWorkspaceName
}

resource r_sparkPool 'Microsoft.Synapse/workspaces/bigDataPools@2021-06-01' = [for computePool in computePools: {
  name: computePool.PoolName
  parent: r_synapseWorkspace
  location: location
  properties: {
    nodeCount: computePool.nodeCount
    isComputeIsolationEnabled: computePool.isComputeIsolationEnabled
    nodeSizeFamily: computePool.nodeSizeFamily
    nodeSize: computePool.nodeSize
    autoScale: {
      enabled: computePool.autoScaleEnabled
      minNodeCount: computePool.autoScaleMinNodeCount
      maxNodeCount: computePool.autoScaleMaxNodeCount
    }
    cacheSize: computePool.cacheSize
    dynamicExecutorAllocation: {
      enabled: computePool.dynamicExecutorAllocationEnabled
      minExecutors: computePool.dynamicExecutorAllocationMinExecutors
      maxExecutors: computePool.dynamicExecutorAllocationMaxExecutors
    }
    autoPause: {
      enabled: computePool.autoPauseEnabled
      delayInMinutes: computePool.autoPauseDelayInMinutes
    }
    sparkVersion: computePool.sparkVersion
    sessionLevelPackagesEnabled: computePool.sessionLevelPackagesEnabled
  }
}]
