
-- --Create SCHEMA rpt
-- CREATE SCHEMA [actstax];
-- -- List the views available, since the Lake DB will not yet show views..
-- SELECT name FROM sys.schemas;
/*
SELECT 
  TABLE_SCHEMA,
  TABLE_NAME
FROM INFORMATION_SCHEMA.VIEWS;
*/

--This query will create a view in the DB that will have the same data as the PBI created 'Sankey' table in the 'Anti-Corruption Report' 
CREATE OR ALTER VIEW [actstax].[AuditStateSupervisor]
AS
SELECT 
[Auditor]
,[State]
,[Supervisor]
FROM
    OPENROWSET(
        BULK 'https://STORAGEACCOUNTNAME.dfs.core.windows.net/curated/EnterpriseTaxModel/AuditorStateSupervisor/**',
        FORMAT = 'PARQUET'
    ) AS [AuditStateSupervisor]