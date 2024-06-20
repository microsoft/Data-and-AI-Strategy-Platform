// Copyright (c) Microsoft Corporation.
// Licensed under the MIT license.
param location string = resourceGroup().location

param cosmosDbName string

param cosmosDbSqlDatabaseName string = 'DataStrategyDb'

param kind string

param databaseContainers array

resource r_CosmosDb 'Microsoft.DocumentDB/databaseAccounts@2022-08-15' = {
  name: cosmosDbName
  location: location
  kind: kind
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    publicNetworkAccess: 'Enabled'
    enableAutomaticFailover: false
    enableMultipleWriteLocations: false
    isVirtualNetworkFilterEnabled: false
    virtualNetworkRules: []
    disableKeyBasedMetadataWriteAccess: false
    enableFreeTier: false
    enableAnalyticalStorage: false
    analyticalStorageConfiguration: {
        schemaType: 'WellDefined'
    }
    databaseAccountOfferType: 'Standard'
    defaultIdentity: 'FirstPartyIdentity'
    networkAclBypass: 'None'
    disableLocalAuth: false
    enablePartitionMerge: false
    consistencyPolicy: {
        defaultConsistencyLevel: 'Session'
        maxIntervalInSeconds: 5
        maxStalenessPrefix: 100
    }
    locations: [
        {
            locationName: location
            failoverPriority: 0
            isZoneRedundant: false
        }
    ]
    cors: []
    capabilities: []
    ipRules: []
    backupPolicy: {
        type: 'Periodic'
        periodicModeProperties: {
            backupIntervalInMinutes: 240
            backupRetentionIntervalInHours: 8
            backupStorageRedundancy: 'Geo'
        }
    }
    networkAclBypassResourceIds: []
  }
}


resource r_cosmosDbSqlDatabase 'Microsoft.DocumentDB/databaseAccounts/sqlDatabases@2022-08-15' = {
  parent: r_CosmosDb
  name: cosmosDbSqlDatabaseName
  location: location
  properties: {
    options: {
      autoscaleSettings: {
        maxThroughput: 4000
      }
    }
    resource: {
      id: cosmosDbSqlDatabaseName
    }
  }
}

resource r_databaseContainer 'Microsoft.DocumentDB/databaseAccounts/sqlDatabases/containers@2022-08-15' = [for databaseContainer in databaseContainers: {
  parent: r_cosmosDbSqlDatabase
  name: databaseContainer.Name
  location: location
  properties: {
    resource: {
      id: databaseContainer.Name
      indexingPolicy: {
        indexingMode: 'consistent'
        automatic: true
        includedPaths: [
          {
            path: '/*'
          }
        ]
        excludedPaths: [
          {
            path: '/_etag/?'
          }
        ]
      }
      partitionKey: {
        kind: 'Hash'
        paths: [
          '/partitionKey'
        ]
        version: 2
      }
      uniqueKeyPolicy: {
        uniqueKeys: []
      }
      conflictResolutionPolicy: {
        conflictResolutionPath: '/_ts'
        mode: 'LastWriterWins'
      }
    }
  }
}]
