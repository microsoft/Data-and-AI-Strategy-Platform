// Copyright (c) Microsoft Corporation.
// Licensed under the MIT license.
param keyVaultName string

param secretName string

@secure()
param secretValue string

resource r_keyvault 'Microsoft.KeyVault/vaults@2021-11-01-preview' existing = {
  name: keyVaultName
}

resource r_keyvaultSecret 'Microsoft.KeyVault/vaults/secrets@2021-11-01-preview' = {
  parent: r_keyvault
  name: secretName
  properties: {
    value: secretValue
  }
}
