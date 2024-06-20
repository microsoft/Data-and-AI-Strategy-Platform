SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE OR ALTER PROCEDURE [dbo].[AddManagedIdentitiesAsUsers]
AS
BEGIN

--for cicd
IF NOT EXISTS(SELECT * FROM sys.database_principals WHERE name = 'insert_service_principal_name')
  BEGIN
    CREATE USER [insert_service_principal_name] FROM EXTERNAL PROVIDER;
  END

ALTER ROLE db_owner ADD MEMBER [insert_service_principal_name];

IF NOT EXISTS(SELECT * FROM sys.database_principals WHERE name = 'insert_consumer_group_name')
  BEGIN
    CREATE USER [insert_consumer_group_name] FROM EXTERNAL PROVIDER;
  END

ALTER ROLE db_ddladmin ADD MEMBER [insert_consumer_group_name];
ALTER ROLE db_datawriter ADD MEMBER [insert_consumer_group_name];
ALTER ROLE db_datareader ADD MEMBER [insert_consumer_group_name];

IF NOT EXISTS(SELECT * FROM sys.database_principals WHERE name = 'insert_synapse_name')
  BEGIN
    CREATE USER [insert_synapse_name] FROM EXTERNAL PROVIDER;
  END

GRANT SELECT ON OBJECT::[dbo].[ControlTable] 
    TO [insert_synapse_name]; 

GRANT SELECT ON OBJECT::[dbo].[IngestedLandingDataAudit]
    TO [insert_synapse_name];

GRANT INSERT ON OBJECT::[dbo].[IngestedLandingDataAudit]
    TO [insert_synapse_name];

GRANT ALTER ON OBJECT::[dbo].[IngestedLandingDataAudit]  
	TO [insert_synapse_name]

GRANT EXECUTE ON OBJECT::[dbo].[ProcessLatestLoggingRecords] 
    TO [insert_synapse_name];

GRANT EXECUTE ON OBJECT::[dbo].[UpdateProcessedFlag] 
    TO [insert_synapse_name];

END
GO
