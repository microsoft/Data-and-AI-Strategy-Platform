# Steps to Deploy the GitHub IP
1. For each environment you're deploying, update the [variable file](variables/) for variables related to resource names and tags 

2. Trigger the **consumer-orchestrator** GitHub Action. If you're unfamiliar with triggering a GitHub Action, follow these [instructions](https://docs.github.com/en/actions/managing-workflow-runs/manually-running-a-workflow).
    - Select **acts** for the "Consumer Name" input

# Post Deployment Tasks - Azure SQL
1. Execute the below stored procedure in the deployed Azure SQL Database from the **consumer-orchestrator** GitHub Action
    - Login with AAD. SQL Auth is disabled.
```sql
EXEC [dbo].[AddManagedIdentitiesAsUsers]
```
2. Execute the below sql script in the Azure SQL Database deployed from the **data-strategy-orchestrator** GitHub Action
    - Login with AAD. SQL Auth is disabled.
```sql
EXEC [dbo].[Execute_For_ACTS_Consumer]
```
3. Run the following the Master DB in the Synapse deployed from the **data-strategy-orchestrator** GitHub Action
```sql

    CREATE LOGIN [insert logic app name] FROM EXTERNAL PROVIDER;
    go;
    
    GRANT CONNECT ANY DATABASE to [insert logic app name];
    GRANT SELECT ALL USER SECURABLES to [insert logic app name];
    GO;
``````