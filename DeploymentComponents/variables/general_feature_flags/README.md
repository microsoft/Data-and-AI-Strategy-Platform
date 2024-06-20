# Feature Flag Definitions

| Id | Feature Flag | Description    |     
| :---  | :---         | :---           |
| 1 | DeployDevEnvironment   | Whether a dev environment is deployed    |
| 2 | DeployTestEnvironment    | Whether a test/qa/pre-prod environment is deployed       |
| 3 | DeployProdEnvironment   | Whether a prod environment is deployed       |
| 4 | DeployResourcesWithPublicAccess     | Whether resources are deployed with public network access. i.e. 0.0.0.0/0 networking access. Credentials will still be needed to access resources     | 
| 5 | DeployWithCustomNetworking | Whether some or all resources will be integrated with a new or existing virtual network and/or have IP rule filters applied at applicable resources. If true, all additional networking setup will need to take place under the "networking_setup" folder |
| 6 | Assign_RBAC_On_Deployment | Whether RBAC and ACLs are assigned during deployment. This is required for users to be able to access the resources and for resources to "speak to one another". For example: assigning storage blob contributor to the Synapse managed identity on the data lake storage account  |
| 7 | ServicePrincipalHasOwnerRBACAtSubscription   | Flag only needed for Purview deployment currently. If the service principal does NOT have owner rights at the subscription, ingestion private endpoints cannot be created for Purview.     |
| 8 | DeployFabricCapacity  | Whether a Microsoft Fabric Capacity is deployed/redeployed       |
| 9 | DeployDataLake    | Whether the Data Lake is redeployed. It should always be deployed initially       |
| 10 | DeployLandingStorage    | Whether Landing Storage is redeployed. It should always be deployed initially       |
| 11 | DeployKeyVault    | Whether Key Vault is redeployed. It should always be deployed initially       |
| 12 | DeployAzureSQL    | Whether Azure SQL is redeployed. It should always be deployed initially       |
| 13 | DeployAzureSQLArtifacts    | Whether Azure SQL tables and stored procedures are redeployed. They should always be deployed initially       |
| 14 | UseDatabricksForIngestionNotebooks    | If False, ADF will reference notebooks in Databricks. Otherwise, ADF will reference notebooks in Synapse     | 
| 15 | DeployADF    | Whether ADF is redeployed. It should always be deployed initially unless EnvironmentWillNotIncludeADF is true      |
| 16 | DeployADFArtifacts    | Whether ADF artifacts like pipelines and linked services are redeployed. They should always be deployed initially unless EnvironmentWillNotIncludeADF is true      | 
| 17 | DeploySynapse    | Whether Synapse is redeployed. It should always be deployed initially |
| 18 | DeploySynapsePools    | Whether Synapse Spark Pools are redeployed. It should always be deployed initially |
| 19 | DeploySynapseSqlPools | Whether Synapse Serverless SQL Pools are redeployed. |
| 20 | DeploySynapseArtifacts    | Whether Synapse artifacts like pipelines and linked services are redeployed. They should always be deployed initially | 
| 21 | DeploySynapseWithDataExfiltrationProtection    | Whether to enable exfiltration protection in Synapse. You *cannot* orchestrate Azure Machine Learning Workspace activities using Synapse if enabled | 
| 22 | DeployPurview    | Whether Purview is deployed/redeployed      |
| 23 | DeployDatabricks    | Whether Databricks is deployed/redeployed      |
| 24 | DeployDatabricksCompute    | Whether Databricks all-purpose compute is deployed      |
| 25 | DatabricksUsesUnityCatalog    | Whether the Databricks workspace is unity catalog enabled      |
| 26 | DeployLogicApp   | Whether the Logic App and its associated resources like application insights are redeployed. It should always be deployed initially     |
| 27 | DeployLogicAppArtifacts   | Whether the Logic App workflows are redeployed. They should always be deployed initially      |
| 28 | DeployLogAnalytics   | Whether Log Analytics is deployed/redeployed      |
| 29 | DeployMLWorkspace  | Whether an Azure ML Workspace and its associated artifacts like container registry are deployed or redeployed |
| 30 | DeployMLCompute  | Whether compute clusters for an Azure ML workspace are deployed or redeployed |
| 31 | DeployCognitiveService  | Whether Cognitive Service is deployed/redeployed       | 
| 32 | DeployEventHubNamespace  | Whether an Event Hub Namespace is deployed/redeployed       | 
| 33 | DeployStreamAnalytics  | Whether Stream Analytics is deployed/redeployed       |
| 34 | DeployOpenAIServiceAndAiSearch  | Whether Azure OpenAI and Associated Cognitive Service is deployed/redeployed       |
| 35 | DeployOpenAIDemoApp  | Whether Azure OpenAI demo app is deployed. Template from this [repo](https://github.com/Azure-Samples/azure-search-openai-demo)       |
| 36 | DeployDataScienceToolkit  | Whether DeployDataScienceToolkit application is deployed/redeployed       |