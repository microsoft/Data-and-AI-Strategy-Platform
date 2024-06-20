// Copyright (c) Microsoft Corporation.
// Licensed under the MIT license.

param emailCommunicationServicesName string

param emailServicesDomainName string = 'AzureManagedDomain'

param communicationServicesName string

param dataLocation string = 'United States'

param domainManagement string = 'AzureManaged'

param userEngagementTracking string = 'Disabled'

param webTitle string

param keyVaultName string

resource r_emailServices 'Microsoft.Communication/emailServices@2022-07-01-preview' = {
  name: emailCommunicationServicesName
  location: 'Global'
  properties: {
    dataLocation: dataLocation
  }
}

resource r_emailServicesDomain 'Microsoft.Communication/emailServices/domains@2022-07-01-preview' = {
  parent: r_emailServices
  name: emailServicesDomainName
  location: 'Global'
  properties: {
    domainManagement: domainManagement
    userEngagementTracking: userEngagementTracking
    validSenderUsernames: {
      donotreply:webTitle
    }
  }
}

resource r_communicationServices 'Microsoft.Communication/communicationServices@2022-07-01-preview' = {
  name: communicationServicesName
  location: 'Global'
  properties: {
    dataLocation: dataLocation
    linkedDomains: [
      r_emailServicesDomain.id
    ]
  }
}

resource r_keyvault 'Microsoft.KeyVault/vaults@2021-11-01-preview' existing = {
  name: keyVaultName
}

resource r_keyvaultSecret 'Microsoft.KeyVault/vaults/secrets@2021-11-01-preview' = {
  parent: r_keyvault
  name: 'CommunicationServiceConfiguration--ConnectionString'
  properties: {
    value: r_communicationServices.listKeys().primaryConnectionString
  }
}
