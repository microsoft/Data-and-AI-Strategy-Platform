## RBAC Assigned During Deployment

**RBAC Rights Designated to AAD Group**

* Storage Blob Data Contributor on Data Lake Storage Account
* Storage Blob Data Contributor on Landing Storage Account
* Storage Blob Data Contributor on Logic App Storage Account
* Storage Blob Data Contributor on Machine Learning Storage Account,
* Key Vault Secrets Officer on Key Vault
* Database Administrator on Azure SQL Database, MetadataControl
* Administrator in Root Collection on Purview
* SQL and Synapse Administrator on Synapse
* Cognitive Services User on Form Recognizer/Cognitive Services
 

**RBAC Rights Designated to Synapse Workspace Managed Identity**

* Storage Blob Data Contributor on Data Lake Storage Account
* Storage Blob Data Contributor on Landing Storage Account
* Key Vault Secrets User on Key Vault
* Read/insert rights on certain Tables and Execute rights on certain Stored Procedures in Azure SQL Database, MetadataControl
* Data Curator in Root Collection on Purview
* Contributor on Machine Learning Workspace
* Cognitive Services User on Form Recognizer/Cognitive Services
 

**RBAC Rights Designated to Data Factory Managed Identity**

* Storage Blob Data Contributor on Data Lake Storage Account
* Storage Blob Data Contributor on Landing Storage Account
* Key Vault Secrets User on Key Vault
* Read/insert rights on certain Tables and Execute rights on certain Stored Procedures in Azure SQL Database, MetadataControl
* Data Curator in Root Collection on Purview
* Cognitive Services User on Form Recognizer/Cognitive Services
* Contributor on Databricks Workspace

**RBAC Rights Designated to Form Recognizer/Cognitive Services Managed Identity**

* Storage Blob Data Reader on Data Lake Storage Account
* Storage Blob Data Reader on Landing Storage Account
 
**RBAC Rights Designated to Stream Analytics Managed Identity**

* Storage Blob Data Contributor on Landing Storage Account
* Event Hubs Data Receiver on Event Hub
 
**RBAC Rights Designated to Purview Managed Identity**

* Storage Blob Data Reader on Data Lake Storage Account
* Storage Blob Data Reader on Landing Storage Account
 
**RBAC Rights Designated to Logic App Managed Identity**

* Synapse Contributor on Synapse
* Synapse Credential User on Synapse
* Contributor on Data Factory
* Read/insert rights on certain Tables and Execute rights on certain Stored Procedures in Azure SQL Database, MetadataControl

**RBAC Rights Designated to Azure Machine Learning Workspace and/or Compute Instances/Clusters Managed Identities**

* Storage Blob Data Contributor on Data Lake Storage Account
* AcrPull on Machine Learning Workspace Container Registry
* Key Vault Administrator on Key Vault
* Reader on All Private Endpoints From Machine Learning Workspace Storage Account
* Reader on All Private Endpoints From Machine Learning Workspace Storage Account