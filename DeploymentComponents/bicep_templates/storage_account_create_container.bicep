// Copyright (c) Microsoft Corporation.
// Licensed under the MIT license.
param storageAccountName string

param containerName string

resource r_storageAccount 'Microsoft.Storage/storageAccounts@2021-08-01' existing = {
  name: storageAccountName
}

resource r_storageAccountBlobServices 'Microsoft.Storage/storageAccounts/blobServices@2021-09-01' existing = {
  name: 'default'
  parent: r_storageAccount
}

resource r_storageAccountContainer 'Microsoft.Storage/storageAccounts/blobServices/containers@2021-09-01' = {
  name: containerName
  parent: r_storageAccountBlobServices
}
