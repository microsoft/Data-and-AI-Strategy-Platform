SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE OR ALTER PROCEDURE [dbo].[Execute_For_Generic_Consumer]
AS
BEGIN

IF NOT EXISTS(SELECT * FROM sys.database_principals WHERE name = 'insert_synapse_name')
  BEGIN
    CREATE USER [insert_synapse_name] FROM EXTERNAL PROVIDER;
  END

GRANT SELECT ON OBJECT::[dbo].[IngestedLandingDataAudit]
    TO [insert_synapse_name];

END
GO
