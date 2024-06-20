--for cicd
IF NOT EXISTS(SELECT * FROM sys.database_principals WHERE name = 'insert_service_principal_name')
  BEGIN
    CREATE LOGIN [insert_service_principal_name] FROM EXTERNAL PROVIDER;

    CREATE USER [insert_service_principal_name] FROM EXTERNAL PROVIDER;
  END

ALTER ROLE db_owner ADD MEMBER [insert_service_principal_name];

IF NOT EXISTS(SELECT * FROM sys.database_principals WHERE name = 'insert_logicapp_name')
  BEGIN
    CREATE LOGIN [insert_logicapp_name] FROM EXTERNAL PROVIDER;

    CREATE USER [insert_logicapp_name] FROM EXTERNAL PROVIDER;
  END

IF NOT EXISTS(SELECT * FROM sys.database_principals WHERE name = 'insert_synapse_name')
  BEGIN
    CREATE USER [insert_synapse_name] FOR LOGIN [insert_synapse_name];
  END

ALTER ROLE db_owner ADD MEMBER [insert_synapse_name]; 
ALTER ROLE db_owner ADD MEMBER [insert_logicapp_name];

GO