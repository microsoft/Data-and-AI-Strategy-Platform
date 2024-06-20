# Post Deployment Tasks - M365 Ingestion
#### Create a new Microsoft Entra application with M365 access
1. Enable Data Connect - if not done already - in the [M365 Admin Center](https://admin.microsoft.com/adminportal/home#/Settings/Services/:/Settings/L1/O365DataPlan)
2. [Create a Microsoft Entra application](https://learn.microsoft.com/en-us/graph/data-connect-quickstart?tabs=NewConsentFlow%2CPAMMicrosoft365%2CAzureSynapsePipeline&tutorial-step=2) and secret and store the secret value in KV
3. Assign the application the Storage Blob Data Contributor role on the Landing storage account
4. In the [Graph Data Connect portal](https://portal.azure.com/#view/Microsoft_Azure_GraphDataConnect/GraphApplication.ReactView), [register](https://learn.microsoft.com/en-us/graph/data-connect-quickstart?tabs=NewConsentFlow%2CPAMMicrosoft365%2CAzureSynapsePipeline&tutorial-step=4) your application with the Landing storage account and desired M365 Datasets
5. On the [M365 Graph Data Connect applications page](https://admin.microsoft.com/#/Settings/MGDCAdminCenter), click on your app, review the selected datasets, and approve *must be an admin to access this page and approve*
#### Manually update ADF or Synapse Linked Services
1. In your deployed ADF or Synapse, edit the below Linked Services by replacing'FILLINPOSTDEPLOYMENT' with the App ID or Secret Name (as you specified in KV)
    - LS_LandingStorage_SPAuth
    - LS_M365
