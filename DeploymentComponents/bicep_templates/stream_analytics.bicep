// Copyright (c) Microsoft Corporation.
// Licensed under the MIT license.
@description('Location for all resources.')
param location string = resourceGroup().location

param streamAnalyticsName string

param sku string = 'standard'

param streamingUnits int

param compatibilityLevel string

resource r_StreamAnalytics 'Microsoft.StreamAnalytics/StreamingJobs@2021-10-01-preview' = {
  name: streamAnalyticsName
  location: location
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    sku: {
      name: sku
    }
    outputErrorPolicy: 'stop'
    eventsOutOfOrderPolicy: 'adjust'
    eventsOutOfOrderMaxDelayInSeconds: 0
    eventsLateArrivalMaxDelayInSeconds: 5
    contentStoragePolicy: 'SystemAccount'
    jobType: 'Cloud'
    dataLocale: 'en-US'
    transformation: {
      properties: {
          streamingUnits: streamingUnits
          query: 'SELECT\r\n    *\r\nINTO\r\n    [YourOutputAlias]\r\nFROM\r\n    [YourInputAlias]'
      }
      name: 'Transformation'
    }
    compatibilityLevel: compatibilityLevel
  }
}


