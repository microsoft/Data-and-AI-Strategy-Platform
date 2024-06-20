// Copyright (c) Microsoft Corporation.
// Licensed under the MIT license.
param location string = resourceGroup().location

param appServiceName string

// Reference Properties
param keyVaultName string
param applicationInsightsName string
param appServicePlanName string
param openAiServiceName string
param AISearchName string
param storageAccountName string

//private networking
param DeployWithCustomNetworking string
param CreatePrivateEndpoints string
param CreatePrivateEndpointsInSameRgAsResource string
param UseManualPrivateLinkServiceConnections string
param VnetforPrivateEndpointsRgName string
param VnetforPrivateEndpointsName string
param PrivateEndpointSubnetName string
param DNS_ZONE_SUBSCRIPTION_ID string
param PrivateDNSZoneRgName string
param PrivateEndpointId string
param VnetForResourcesRgName string
param VnetForResourcesName string
param DeployOpenAiDemoAppInVnet string
param OpenAiDemoAppSubnetName string
param DeployResourcesWithPublicAccess string
param DeployLogAnalytics string
param logAnalyticsRG string
param logAnalyticsName string 

var PeIntegration = (DeployWithCustomNetworking == 'True' && CreatePrivateEndpoints == 'True')?true:false
var OpenAiDemoAppInVnet = (DeployWithCustomNetworking == 'True' && DeployOpenAiDemoAppInVnet == 'True')?true:false

var privateEndpointRg = (CreatePrivateEndpointsInSameRgAsResource == 'True')?resourceGroup().name:VnetforPrivateEndpointsRgName

var WEBSITE_CONTENTOVERVNET = (OpenAiDemoAppInVnet)?1:0

var vnetRouteAllEnabled = (DeployResourcesWithPublicAccess == 'True')?false:true

param useGPT4V bool = false

// Runtime Properties
@allowed([
  'dotnet', 'dotnetcore', 'dotnet-isolated', 'node', 'python', 'java', 'powershell', 'custom'
])
param runtimeName string = 'python'
param runtimeVersion string = '3.11'
param runtimeNameAndVersion string = '${runtimeName}|${runtimeVersion}'

// Microsoft.Web/sites Properties
param kind string = 'app,linux'

// Microsoft.Web/sites/config
param allowedOrigins array = []
param additionalScopes array = []
param additionalAllowedAudiences array = []
param allowedApplications array = []
param alwaysOn bool = true
param appCommandLine string = 'python3 -m gunicorn main:app'

param clientAffinityEnabled bool = false
param enableOryxBuild bool = contains(kind, 'linux')
param functionAppScaleLimit int = -1
param linuxFxVersion string = runtimeNameAndVersion
param minimumElasticInstanceCount int = -1
param numberOfWorkers int = -1
param scmDoBuildDuringDeployment bool = true
param use32BitWorkerProcess bool = false
param ftpsState string = 'FtpsOnly'
param healthCheckPath string = ''
param clientAppId string = ''
param serverAppId string = ''
@secure()
param clientSecretSettingName string = ''
var authenticationIssuerUri = '${environment().authentication.loginEndpoint}${tenant().tenantId}/v2.0'

var msftAllowedOrigins = [ 'https://portal.azure.com', 'https://ms.portal.azure.com' ]
var loginEndpoint = environment().authentication.loginEndpoint
var loginEndpointFixed = lastIndexOf(loginEndpoint, '/') == length(loginEndpoint) - 1 ? substring(loginEndpoint, 0, length(loginEndpoint) - 1) : loginEndpoint
var allMsftAllowedOrigins = !(empty(clientAppId)) ? union(msftAllowedOrigins, [loginEndpointFixed]) : msftAllowedOrigins

// .default must be the 1st scope for On-Behalf-Of-Flow combined consent to work properly
// Please see https://learn.microsoft.com/entra/identity-platform/v2-oauth2-on-behalf-of-flow#default-and-combined-consent
var requiredScopes = ['api://${serverAppId}/.default', 'openid', 'profile', 'email', 'offline_access']
var requiredAudiences = ['api://${serverAppId}']

resource r_keyVault 'Microsoft.KeyVault/vaults@2022-07-01' existing = {
  name: keyVaultName
}

resource r_applicationInsights 'Microsoft.Insights/components@2020-02-02' existing = {
  name: applicationInsightsName
}

resource r_AppServicePlan 'Microsoft.Web/serverfarms@2022-03-01' existing = {
  name: appServicePlanName
}

//app settings
param useAuthentication bool = false 
param enforceAccessControl bool = false
param searchQueryLanguage string = 'en-us'
param searchQuerySpeller string = 'lexicon'
param searchIndexName string = 'gptkbindex'

var AppInsightConnectionString = r_applicationInsights.properties.ConnectionString

var appSettings = {
  AZURE_STORAGE_ACCOUNT: storageAccountName
  AZURE_STORAGE_CONTAINER: 'raw'
  AZURE_SEARCH_INDEX: searchIndexName
  AZURE_SEARCH_SERVICE: AISearchName
  AZURE_VISION_ENDPOINT: ''
  VISION_SECRET_NAME: ''
  AZURE_KEY_VAULT_NAME: keyVaultName
  AZURE_SEARCH_QUERY_LANGUAGE: searchQueryLanguage
  AZURE_SEARCH_QUERY_SPELLER: searchQuerySpeller
  APPLICATIONINSIGHTS_CONNECTION_STRING: AppInsightConnectionString
  // Shared by all OpenAI deployments
  OPENAI_HOST: 'azure'
  AZURE_OPENAI_EMB_MODEL_NAME: 'text-embedding-ada-002'
  AZURE_OPENAI_CHATGPT_MODEL: 'gpt-35-turbo'
  AZURE_OPENAI_GPT4V_MODEL: ''
  // Specific to Azure OpenAI
  AZURE_OPENAI_SERVICE: openAiServiceName
  AZURE_OPENAI_CHATGPT_DEPLOYMENT: 'chatGpt35Turbo0613'
  AZURE_OPENAI_EMB_DEPLOYMENT: 'textEmbeddingAda002'
  AZURE_OPENAI_GPT4V_DEPLOYMENT: ''
  // Optional login and document level access control system
  AZURE_USE_AUTHENTICATION: string(useAuthentication)
  AZURE_ENFORCE_ACCESS_CONTROL: string(enforceAccessControl)
  AZURE_SERVER_APP_ID: serverAppId
  AZURE_SERVER_APP_SECRET: '@Microsoft.KeyVault(VaultName=${keyVaultName};SecretName=OpenAiAppServerSecret)'
  AZURE_CLIENT_APP_ID: clientAppId
  AZURE_CLIENT_APP_SECRET: '@Microsoft.KeyVault(VaultName=${keyVaultName};SecretName=OpenAiAppClientSecret)'
  AZURE_TENANT_ID: tenant().tenantId
  AZURE_AUTH_TENANT_ID: tenant().tenantId
  AZURE_AUTHENTICATION_ISSUER_URI: authenticationIssuerUri
  // CORS support, for frontends on other hosts
  ALLOWED_ORIGIN: string(allowedOrigins)
  USE_GPT4V: string(useGPT4V)
  SCM_DO_BUILD_DURING_DEPLOYMENT: string(scmDoBuildDuringDeployment)
  ENABLE_ORYX_BUILD: string(enableOryxBuild)
  PYTHON_ENABLE_GUNICORN_MULTIWORKERS: 'true'
  AZURE_KEY_VAULT_ENDPOINT: r_keyVault.properties.vaultUri
  WEBSITE_CONTENTOVERVNET: WEBSITE_CONTENTOVERVNET
}

resource r_vnet 'Microsoft.Network/virtualNetworks@2022-01-01' existing = if (OpenAiDemoAppInVnet) {
  scope: resourceGroup(VnetForResourcesRgName)
  name: VnetForResourcesName
}

resource r_openAiAppSubnet 'Microsoft.Network/virtualNetworks/subnets@2022-01-01' existing = if (OpenAiDemoAppInVnet) {
  parent: r_vnet
  name: OpenAiDemoAppSubnetName
}

resource r_appService 'Microsoft.Web/sites@2022-03-01' = {
  name: appServiceName
  tags: {
    'azd-service-name': 'backend'
  }
  location: location
  kind: kind
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    serverFarmId: r_AppServicePlan.id
    siteConfig: {
      linuxFxVersion: linuxFxVersion
      alwaysOn: alwaysOn
      ftpsState: ftpsState
      minTlsVersion: '1.2'
      appCommandLine: appCommandLine
      numberOfWorkers: numberOfWorkers != -1 ? numberOfWorkers : null
      minimumElasticInstanceCount: minimumElasticInstanceCount != -1 ? minimumElasticInstanceCount : null
      use32BitWorkerProcess: use32BitWorkerProcess
      functionAppScaleLimit: functionAppScaleLimit != -1 ? functionAppScaleLimit : null
      healthCheckPath: healthCheckPath
      cors: {
        allowedOrigins: union(allMsftAllowedOrigins, allowedOrigins)
      }
    }
    virtualNetworkSubnetId: (OpenAiDemoAppInVnet == false)?null:r_openAiAppSubnet.id
    vnetRouteAllEnabled: (OpenAiDemoAppInVnet == false)?null:vnetRouteAllEnabled
    clientAffinityEnabled: clientAffinityEnabled
    httpsOnly: true
  }

  resource configAppSettings 'config' = {
    name: 'appsettings'
    properties: appSettings
  }

  resource configLogs 'config' = {
    name: 'logs'
    properties: {
      applicationLogs: { fileSystem: { level: 'Verbose' } }
      detailedErrorMessages: { enabled: true }
      failedRequestsTracing: { enabled: true }
      httpLogs: { fileSystem: { enabled: true, retentionInDays: 1, retentionInMb: 35 } }
    }
    dependsOn: [
      configAppSettings
    ]
  }

  resource basicPublishingCredentialsPoliciesFtp 'basicPublishingCredentialsPolicies' = {
    name: 'ftp'
    properties: {
      allow: false
    }
  }

  resource basicPublishingCredentialsPoliciesScm 'basicPublishingCredentialsPolicies' = {
    name: 'scm'
    properties: {
      allow: false
    }
  }

  resource configAuth 'config' = if (!(empty(clientAppId))) {
    name: 'authsettingsV2'
    properties: {
      globalValidation: {
        requireAuthentication: true
        unauthenticatedClientAction: 'RedirectToLoginPage'
        redirectToProvider: 'azureactivedirectory'
      }
      identityProviders: {
        azureActiveDirectory: {
          enabled: true
          registration: {
            clientId: clientAppId
            clientSecretSettingName: clientSecretSettingName
            openIdIssuer: authenticationIssuerUri
          }
          login: {
            loginParameters: ['scope=${join(union(requiredScopes, additionalScopes), ' ')}']
          }
          validation: {
            allowedAudiences: union(requiredAudiences, additionalAllowedAudiences)
            defaultAuthorizationPolicy: {
              allowedApplications: allowedApplications
            }
          }
        }
      }
      login: {
        tokenStore: {
          enabled: true
        }
      }
    }
  }
}

var privateDnsZoneName = 'privatelink.azurewebsites.net'
module m_openai_app_private_endpoint 'private_endpoint.bicep' = if (PeIntegration) {
  name: 'openai_app_private_endpoint'
  scope: resourceGroup(privateEndpointRg)
  params: {
    location:location
    VnetforPrivateEndpointsRgName: VnetforPrivateEndpointsRgName
    VnetforPrivateEndpointsName: VnetforPrivateEndpointsName
    PrivateEndpointSubnetName: PrivateEndpointSubnetName
    UseManualPrivateLinkServiceConnections: UseManualPrivateLinkServiceConnections
    DNS_ZONE_SUBSCRIPTION_ID: DNS_ZONE_SUBSCRIPTION_ID
    PrivateDNSZoneRgName: PrivateDNSZoneRgName
    privateDnsZoneName:privateDnsZoneName
    privateDnsZoneConfigsName:replace(privateDnsZoneName,'.','-')
    resourceName: r_appService.name
    resourceID: r_appService.id
    privateEndpointgroupIds: [
      'sites'
    ]
    PrivateEndpointId: PrivateEndpointId
  }
}
