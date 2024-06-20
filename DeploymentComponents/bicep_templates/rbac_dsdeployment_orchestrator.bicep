// Copyright (c) Microsoft Corporation.
// Licensed under the MIT license.
param env string

param Service_Principal_Infra_Object_ID string

param Assign_RBAC_for_CICD_Service_Principal string

param Service_Principal_CICD_Object_ID string

param Entra_Group_Admin_Group_ID string

param Entra_Group_Shared_Service_Group_ID string

param Assign_RBAC_for_Governance string

param Entra_Group_Governance_Group_ID string

param Assign_RBAC_for_Publishers string

param Entra_Groups_Data_Publishers string

param Assign_RBAC_for_Producers string

param Entra_Groups_Data_Producers string

param Assign_RBAC_for_Consumers string

param Entra_Groups_Data_Consumers string

param PrimaryRgName string

param DeployDataLake string

param dataLakeName string

param DeployLandingStorage string

param landingStorageName string

param DeployPurview string

param purviewName string

param DeployKeyVault string

param keyVaultName string

param DeployADF string

param dataFactoryName string 

param DeploySynapse string

param synapseWorkspaceName string

param DeployCognitiveService string

param cognitiveServiceName string

param DeployEventHubNamespace string

param eventHubNamespaceName string

param DeployStreamAnalytics string

param streamAnalyticsName string

param DeployLogicApp string

param logicAppRG string

param logicAppName string

param DeployMLWorkspace string

param MlRgName string

param mlWorkspaceName string

param DeployDatabricks string

param databricksWorkspaceName string

module m_data_rg_rbac 'rbac_dsdeployment_data.bicep' = {
  name: 'data_rg_rbac'
  scope: resourceGroup(PrimaryRgName)
  params: {
    env: env
    Service_Principal_Infra_Object_ID: Service_Principal_Infra_Object_ID
    Assign_RBAC_for_CICD_Service_Principal: Assign_RBAC_for_CICD_Service_Principal
    Service_Principal_CICD_Object_ID: Service_Principal_CICD_Object_ID
    Entra_Group_Admin_Group_ID: Entra_Group_Admin_Group_ID
    Entra_Group_Shared_Service_Group_ID: Entra_Group_Shared_Service_Group_ID
    Assign_RBAC_for_Governance: Assign_RBAC_for_Governance
    Entra_Group_Governance_Group_ID: Entra_Group_Governance_Group_ID
    Assign_RBAC_for_Publishers: Assign_RBAC_for_Publishers
    Entra_Groups_Data_Publishers: Entra_Groups_Data_Publishers
    Assign_RBAC_for_Producers: Assign_RBAC_for_Producers
    Entra_Groups_Data_Producers: Entra_Groups_Data_Producers  
    Assign_RBAC_for_Consumers: Assign_RBAC_for_Consumers
    Entra_Groups_Data_Consumers: Entra_Groups_Data_Consumers
    DeployDataLake: DeployDataLake
    dataLakeName: dataLakeName
    DeployLandingStorage: DeployLandingStorage
    landingStorageName: landingStorageName
    DeployPurview: DeployPurview
    purviewName: purviewName
    DeployKeyVault: DeployKeyVault
    keyVaultName: keyVaultName
    DeployADF: DeployADF
    dataFactoryName: dataFactoryName 
    DeploySynapse: DeploySynapse
    synapseWorkspaceName: synapseWorkspaceName
    DeployCognitiveService: DeployCognitiveService
    cognitiveServiceName: cognitiveServiceName
    DeployEventHubNamespace: DeployEventHubNamespace
    eventHubNamespaceName: eventHubNamespaceName
    DeployStreamAnalytics: DeployStreamAnalytics
    streamAnalyticsName: streamAnalyticsName
    DeployLogicApp: DeployLogicApp
    logicAppRG: logicAppRG
    logicAppName: logicAppName
    DeployDatabricks: DeployDatabricks
    databricksWorkspaceName: databricksWorkspaceName
  }
}

module m_logic_rg_rbac 'rbac_dsdeployment_logicapp.bicep' = if (DeployLogicApp == 'True') {
  name: 'logic_rg_rbac'
  scope: resourceGroup(logicAppRG)
  params: {
    Assign_RBAC_for_CICD_Service_Principal: Assign_RBAC_for_CICD_Service_Principal
    Service_Principal_CICD_Object_ID: Service_Principal_CICD_Object_ID
    Entra_Group_Shared_Service_Group_ID: Entra_Group_Shared_Service_Group_ID
    Assign_RBAC_for_Governance: Assign_RBAC_for_Governance
    Entra_Group_Governance_Group_ID: Entra_Group_Governance_Group_ID
    Assign_RBAC_for_Publishers: Assign_RBAC_for_Publishers
    Entra_Groups_Data_Publishers: Entra_Groups_Data_Publishers
    Assign_RBAC_for_Producers: Assign_RBAC_for_Producers
    Entra_Groups_Data_Producers: Entra_Groups_Data_Producers  
    Assign_RBAC_for_Consumers: Assign_RBAC_for_Consumers
    Entra_Groups_Data_Consumers: Entra_Groups_Data_Consumers
    logicAppName: logicAppName
    PrimaryRgName: PrimaryRgName
    DeployLandingStorage: DeployLandingStorage
    landingStorageName: landingStorageName
  }
}

module m_ml_rg_rbac 'rbac_dsdeployment_ml.bicep' = if (DeployMLWorkspace == 'True') {
  name: 'ml_rg_rbac'
  scope: resourceGroup(MlRgName)
  params: {
    Assign_RBAC_for_CICD_Service_Principal: Assign_RBAC_for_CICD_Service_Principal
    Service_Principal_CICD_Object_ID: Service_Principal_CICD_Object_ID
    Entra_Group_Shared_Service_Group_ID: Entra_Group_Shared_Service_Group_ID
    Assign_RBAC_for_Governance: Assign_RBAC_for_Governance
    Entra_Group_Governance_Group_ID: Entra_Group_Governance_Group_ID
    Assign_RBAC_for_Publishers: Assign_RBAC_for_Publishers
    Entra_Groups_Data_Publishers: Entra_Groups_Data_Publishers
    Assign_RBAC_for_Producers: Assign_RBAC_for_Producers
    Entra_Groups_Data_Producers: Entra_Groups_Data_Producers  
    Assign_RBAC_for_Consumers: Assign_RBAC_for_Consumers
    Entra_Groups_Data_Consumers: Entra_Groups_Data_Consumers
    mlWorkspaceName: mlWorkspaceName
    PrimaryRgName:PrimaryRgName
    dataLakeName:dataLakeName
    DeploySynapse: DeploySynapse
    synapseWorkspaceName: synapseWorkspaceName
    synapseWorkspaceEntraId: m_data_rg_rbac.outputs.synapseWorkspaceEntraId
  }
}
