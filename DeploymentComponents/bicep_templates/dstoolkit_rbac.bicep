// Copyright (c) Microsoft Corporation.
// Licensed under the MIT license.
param keyVaultName string

param cosmosDbName string

param cosmosDbSqlDatabaseName string

param functionAppName string

param webAppName string

param webAppStorageName string

param servicePrincipalId string

param cognitiveSearchName string

param serviceBusNamespaceName string

resource r_FunctionApp 'Microsoft.Web/sites@2022-03-01' existing = {
  name: functionAppName
}

resource r_WebApp 'Microsoft.Web/sites@2022-03-01' existing = {
  name: webAppName
}

resource r_keyvault 'Microsoft.KeyVault/vaults@2021-11-01-preview' existing = {
  name: keyVaultName
}

resource r_CognitiveSearch 'Microsoft.Search/searchServices@2021-04-01-preview' existing = {
  name: cognitiveSearchName
}

resource r_serviceBusNamespace 'Microsoft.ServiceBus/namespaces@2022-10-01-preview' existing = {
  name: serviceBusNamespaceName
}

var azureRBACStorageKeyVaultSecretsUserRoleID = '4633458b-17de-408a-b874-0445c86b69e6' //Key Vault Secrets User

//Grant Azure Resource a Role Assignment as Secret Reader Role in the Key Vault
//https://docs.microsoft.com/en-us/azure/synapse-analytics/security/how-to-grant-workspace-managed-identity-permissions
resource r_functionAppKeyVault 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid(functionAppName, keyVaultName)
  scope: r_keyvault
  properties:{
    roleDefinitionId: resourceId('Microsoft.Authorization/roleDefinitions', azureRBACStorageKeyVaultSecretsUserRoleID)
    principalId: r_FunctionApp.identity.principalId
    principalType:'ServicePrincipal'
  }
}

resource r_webAppKeyVault 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid(webAppName, keyVaultName)
  scope: r_keyvault
  properties:{
    roleDefinitionId: resourceId('Microsoft.Authorization/roleDefinitions', azureRBACStorageKeyVaultSecretsUserRoleID)
    principalId: r_WebApp.identity.principalId
    principalType:'ServicePrincipal'
  }
}

var azureRBACSearchIndexDataContributorRoleID = '8ebe5a00-799e-43f5-93ac-243d3dce84a7' //Search Index Data Contributor

resource r_webAppCognitiveSearch 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid(cognitiveSearchName, webAppName)
  scope: r_CognitiveSearch
  properties:{
    roleDefinitionId: resourceId('Microsoft.Authorization/roleDefinitions', azureRBACSearchIndexDataContributorRoleID)
    principalId: r_WebApp.identity.principalId
    principalType:'ServicePrincipal'
  }
}


var azureRBACServiceBusDataSenderRoleID = '69a216fc-b8fb-44d8-bc22-1f3c2cd27a39' //Service Bus Data Sender

resource r_webAppServiceBusSender 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid(serviceBusNamespaceName, webAppName)
  scope: r_serviceBusNamespace
  properties:{
    roleDefinitionId: resourceId('Microsoft.Authorization/roleDefinitions', azureRBACServiceBusDataSenderRoleID)
    principalId: r_WebApp.identity.principalId
    principalType:'ServicePrincipal'
  }
}

resource r_functionAppServiceBusSender 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid(serviceBusNamespaceName, functionAppName, 'Sender')
  scope: r_serviceBusNamespace
  properties:{
    roleDefinitionId: resourceId('Microsoft.Authorization/roleDefinitions', azureRBACServiceBusDataSenderRoleID)
    principalId: r_FunctionApp.identity.principalId
    principalType:'ServicePrincipal'
  }
}

var azureRBACServiceBusDataReceiverRoleID = '4f6d3b9b-027b-4f4c-9142-0e5a2a2247e0' //Service Bus Data Receiver

resource r_functionAppServiceBusReceiver 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid(serviceBusNamespaceName, functionAppName, 'Receiver')
  scope: r_serviceBusNamespace
  properties:{
    roleDefinitionId: resourceId('Microsoft.Authorization/roleDefinitions', azureRBACServiceBusDataReceiverRoleID)
    principalId: r_FunctionApp.identity.principalId
    principalType:'ServicePrincipal'
  }
}


resource r_CosmosDb 'Microsoft.DocumentDB/databaseAccounts@2022-08-15' existing = {
  name: cosmosDbName
}

resource r_cosmosDbSqlDatabase 'Microsoft.DocumentDB/databaseAccounts/sqlDatabases@2022-08-15' existing = {
  parent: r_CosmosDb
  name: cosmosDbSqlDatabaseName
}

resource r_CosmosDbBuiltInDataContributor 'Microsoft.DocumentDB/databaseAccounts/sqlRoleDefinitions@2022-08-15' existing = {
  parent: r_CosmosDb
  name: '00000000-0000-0000-0000-000000000002'
}

resource r_cosmosDbSqlDatabaseFunction 'Microsoft.DocumentDB/databaseAccounts/sqlRoleAssignments@2022-08-15' = {
  parent: r_CosmosDb
  name: guid(cosmosDbName, functionAppName, 'Data Contributor')
  properties: {
    principalId: r_FunctionApp.identity.principalId
    roleDefinitionId: r_CosmosDbBuiltInDataContributor.id
    scope: r_cosmosDbSqlDatabase.id
  }
}

resource r_cosmosDbSqlDatabaseWebApp 'Microsoft.DocumentDB/databaseAccounts/sqlRoleAssignments@2022-08-15' = {
  parent: r_CosmosDb
  name: guid(cosmosDbName, webAppName, 'Data Contributor')
  properties: {
    principalId: r_WebApp.identity.principalId
    roleDefinitionId: r_CosmosDbBuiltInDataContributor.id
    scope: r_cosmosDbSqlDatabase.id
  }
  dependsOn: [
    r_cosmosDbSqlDatabaseFunction
  ]
}

var azureRBACCosmosDBAccountReaderRoleID = 'fbdf93bf-df7d-467e-a4d2-9458aa1360c8' //Cosmos DB Account Reader Role

resource r_CognitiveSearchCosmosDBAccountReader 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid(cosmosDbName, cognitiveSearchName, 'Reader')
  scope: r_CosmosDb
  properties:{
    roleDefinitionId: resourceId('Microsoft.Authorization/roleDefinitions', azureRBACCosmosDBAccountReaderRoleID)
    principalId: r_CognitiveSearch.identity.principalId
    principalType:'ServicePrincipal'
  }
}

resource r_webAppStorage 'Microsoft.Storage/storageAccounts@2021-09-01' existing = {
  name: webAppStorageName
}

var azureRBACStorageBlobDataContributorRoleID = 'ba92f5b4-2d11-453d-a403-e96b0029c9fe' //Storage Blob Data Contributor Role

//Grant Blob Storage Contributor to Service Principal on Web App Storage Account
resource r_dataLakeRoleAssignmentAADGroup 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid(r_webAppStorage.id, 'service_principal')
  scope: r_webAppStorage
  properties:{
    roleDefinitionId: resourceId('Microsoft.Authorization/roleDefinitions', azureRBACStorageBlobDataContributorRoleID)
    principalId: servicePrincipalId
    principalType:'ServicePrincipal'
  }
}

//Grant Blob Storage Contributor to Service Principal on Web App Storage Account
resource r_dataLakeRoleAssignmentwebApp 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid(r_webAppStorage.id, webAppName)
  scope: r_webAppStorage
  properties:{
    roleDefinitionId: resourceId('Microsoft.Authorization/roleDefinitions', azureRBACStorageBlobDataContributorRoleID)
    principalId: r_WebApp.identity.principalId
    principalType:'ServicePrincipal'
  }
}
