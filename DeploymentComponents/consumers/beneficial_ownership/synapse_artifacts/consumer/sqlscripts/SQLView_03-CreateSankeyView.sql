
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
CREATE OR ALTER VIEW [actstax].[sankey]
AS
SELECT 
    [State] AS [Source]
    ,[Supervisor] AS [Target]
    ,SUM([Fraud Risk Factor]) AS [Anomalies]
    FROM [actstax].[corruption]
    GROUP BY [State], [Supervisor]
UNION
SELECT
    [Supervisor] AS [Source]
    ,[Auditor] AS [Target]
    ,SUM([Fraud Risk Factor]) AS [Anomalies]
    FROM [actstax].[corruption]
    GROUP BY [Supervisor] , [Auditor]
UNION
SELECT
    [Auditor] AS [Source]
    ,[Sector] AS [Target]
    ,SUM([Fraud Risk Factor]) AS [Anomalies]
    FROM [actstax].[corruption]
    GROUP BY [Auditor] , [Sector]