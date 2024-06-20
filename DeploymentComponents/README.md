# 1. Deploy the Azure Infrastructure and Data Pipeline Related Artifacts
1. [Create a Service Principal](https://learn.microsoft.com/en-us/azure/active-directory/develop/howto-create-service-principal-portal)
1. Assign Service Principal with Subscription Rights. There's 2 Options
    - Assign the Service Principal RBAC Owner rights at the Subscription(s)
    - Pre-create all Resource Groups and Assign the Service Principal Owner RBAC Owner rights at each Resource Group

1. [Create a federated credential for the service principal](https://learn.microsoft.com/en-us/azure/developer/github/connect-from-azure?tabs=azure-portal%2Cwindows#add-federated-credentials)
    - If you're using environments:
        - Please use an entity type of environment
        - You will need to create a new federated credential for each environment you're deploying
            - The IP kit deploys up to 3 environments: **development**, **test**, and **production**
    - If you're not using environments
        - Please use a Branch entity type of **main**

1. [Create an Azure Active Directory (AAD) group](https://learn.microsoft.com/en-us/azure/active-directory/fundamentals/concept-learn-about-groups) and add all project team members, or, if only you will be interacting with the deployed resources, yourself

1. If you're using GitHub environments, then [create the below environments in your GitHub Repo](https://docs.github.com/en/actions/deployment/targeting-different-environments/using-environments-for-deployment#creating-an-environment)
    - **development**
    - **test**
    - **production**

1. If you're using environments, [add the below secrets to each environment you're deploying](https://docs.github.com/en/actions/security-guides/using-secrets-in-github-actions#creating-secrets-for-an-environment). If you're not using environments, [Add the following Repository Secrets](https://docs.github.com/en/actions/security-guides/encrypted-secrets#creating-encrypted-secrets-for-a-repository) *with the same name*
    - **TENANT_ID** - [how to find](https://learn.microsoft.com/en-us/azure/active-directory/fundamentals/active-directory-how-to-find-tenant#find-tenant-id-through-the-azure-portal)
    - **SUBSCRIPTION_ID** - [how to find](https://learn.microsoft.com/en-us/azure/azure-portal/get-subscription-tenant-id#find-your-azure-subscription)
    - **SERVICE_PRINCIPAL_CLIENT_ID** (From Step 1) - [how to find](https://learn.microsoft.com/en-us/azure/active-directory/develop/app-objects-and-service-principals#application-object)
1. Create the below secrets *with the same name* if you're creating private endpoints
    - **DNS_ZONE_SUBSCRIPTION_ID**
1. Create the below secrets *with the same name* if you're deploying VM's with Bastion
    - **VM_USERNAME**
    - **VM_PASSWORD**

1. For each environment you're deploying, update the [feature flag variable file](variables/general_feature_flags/) to indicate which resources you are deploying or behavior of resources
    - If you're deploying Role-Based Access Control (RBAC), please refer [here](rbac.md) for what RBAC is deployed 
    - If you're deploying the pre-built data pipelines, you must enable Data Factory, Landing Storage, Data Lake, Azure SQL and either Synapse or Databricks

1. For each environment you're deploying, update the [general variable file](variables/general_variables/) with the resource names for the resources you indicated you are deploying based on the feature flag file. Also add required tags, Azure location, and resource group names.
    - All non Logic App/Azure Machine Learning/OpenAI resources will be deployed to the resource group inputted in the *PrimaryRg* variable
    - The *PrimaryRg* variable is required. If you're only deploying Logic App/Azure Machine Learning/OpenAI resources, set the *PrimaryRg* variable as the same name as one of the other resource groups
    - Note that most Azure resource names need to be globally unique, but keep the SQL Database name as "MetadataControl"
    - The following variable values can only contain letters and numbers and must be between 3 and 24 characters long
        - *dataLakeName*
        - *landingStorageName*
        - *logicAppStorageName*
        - *mlStorageName*
    - The following variable values must be between 3 and 24 characters long
        - *keyVaultName*
    - The following variable values can only contain letters and numbers
        - *mlContainerRegistryName*
        - *fabricCapacityName*
    - If Key Vault or Container Registry are deleted and need to be redeployed, please change the resource name
        - this is due to soft delete policies

1. If you're deploying the resources securely with no public access and private endpoints, please update the [networking setup variable files](variables/networking_setup/) **and** set the *DeployWithCustomNetworking* feature flag in the [feature flag variable file](variables/general_feature_flags/) to *true*
    - The best practice is to connect to an existing spoke Virtual Network(s) for private endpoints and vnet injection. Please refer [here](networking.md) for an overview of the networking requirements

1. Update the [entra assignments](variables/entra_assignments/) variable files
    - Only the **Entra_Group_Admin** and **Entra_Group_Shared_Service** groups are required. If you only have one group from Step 3 above, you can put the same information for both variables

1. Confirm the following resource providers are registered in your Azure Subscription. If not, [register them](https://docs.microsoft.com/en-us/azure/azure-resource-manager/management/resource-providers-and-types#register-resource-provider-1)
    - *Microsoft.EventGrid*
    - If you're deploying Purview: *Microsoft.Purview*, *Microsoft.EventHub*

1. Trigger the **data-strategy-orchestrator** GitHub Action. If you're unfamiliar with triggering a GitHub Action, follow these [instructions](https://docs.github.com/en/actions/managing-workflow-runs/manually-running-a-workflow).
    - Please do not use the "rerun" job functionality. Always execute the job using method in above instructions

# 2. Complete the Post Deployment Tasks

## Azure SQL
1. Execute the below stored procedure in the deployed Azure SQL Database(s)
    - Login with AAD. SQL Auth is disabled.
```sql
EXEC [dbo].[AddManagedIdentitiesAsUsers]
```

## Synapse
1. Execute the below stored procedure in the Synapse Serverless Database **StoredProcDB** 
    - Login with AAD. SQL Auth is disabled post deployment.
```sql
EXEC [dbo].[AddManagedIdentitiesAsUsers]
```
2. If you're deploying the logic app, run the following precreated SQL script in the Synapse portal: **RunForLogicApp**

## Purview
1. Add the ADF and Synapse managed identities as [Data Curator's in the Root Collection of Purview](https://learn.microsoft.com/en-us/azure/synapse-analytics/catalog-and-governance/quickstart-connect-azure-purview#set-up-authentication)
    - This is required for lineage
2. When lake DBs are created, you will need to execute the below commands for Purview to scan
```sql
CREATE LOGIN [PurviewAccountName] FROM EXTERNAL PROVIDER;
CREATE USER [PurviewAccountName] FOR LOGIN [PurviewAccountName];
ALTER ROLE db_datareader ADD MEMBER [PurviewAccountName]; 
```
#### If your deploying all resources with no public access behind a virtual network and your service principal didn't have Owner RBAC rights on the **Subscription**

3. Get Owner of Subscription to Provide AAD Group with Contributor Access to Purview Managed Resource Group

##### if you set the feature flag, *DeployPurviewIngestionPrivateEndpoints*, to true

4. Within the Azure Portal, navigate to Purview's managed Storage Account and Event Hub. For each resource, approve the pending Private Endpoint connections created by the GitHub Action.

#### If your deploying all resources with no public access behind a virtual network
5. Set up a [Managed VNET Integration Runtime](https://learn.microsoft.com/en-us/azure/purview/catalog-managed-vnet#deployment-steps) to scan [supported Azure data sources](https://learn.microsoft.com/en-us/azure/purview/catalog-managed-vnet#supported-data-sources)
6. Set up a [Self-Hosted Integration Runtime](https://learn.microsoft.com/en-us/azure/purview/catalog-private-link-end-to-end#deploy-self-hosted-integration-runtime-ir-and-scan-your-data-sources) to scan data sources unsupported by the Managed VNET Integration Runtime


# 3. Start Ingesting Data

## Process Overview
1. Overview of Pre-Built Ingestion Patterns ![image](https://github.com/microsoft/Data-Strategy-Platform-and-Analytics/assets/99213879/9f08709a-1363-4316-bb38-24065042e03d)
2. Overview of Pre-Build Data Pipelines ![image](https://github.com/microsoft/Data-Strategy-Platform-and-Analytics/assets/99213879/f1be5582-e9c2-41db-b9aa-937c928c302b)
3. Moving Data to Curated ![image](https://github.com/microsoft/Data-Strategy-Platform-and-Analytics/assets/99213879/4c480e16-1e27-4874-8ea6-b33dbe18bc4a)

## Create Control Table Records for Metadata Driven Ingestion
1. Please create control table records in the dbo.MetadataControl table in the Azure SQL DB. Please follow the instructions [here](azure_sql_artifacts/README.md)
    - Every time you need to ingest a new source entity (e.g. sql table, csv file, Excel tab), please create one control table record when moving data from source to landing, one for landing to raw, and one for raw to staging.
