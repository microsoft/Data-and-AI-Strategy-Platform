
-- --Create SCHEMA rpt
-- CREATE SCHEMA [actstax];
-- -- List the views available, since the Lake DB will not yet show views..
-- SELECT name FROM sys.schemas;

SELECT 
  TABLE_SCHEMA,
  TABLE_NAME
FROM INFORMATION_SCHEMA.VIEWS;
 
CREATE OR ALTER VIEW [actstax].[corruption]
AS
SELECT 
[vat1].[invoicesoldtostate] AS [State]
,[vat1].[InvoiceSoldToSector] AS [Sector]
,[vat1].[Month] as [Month]
,[vat1].[Year] as [YEAR]
,[customer].[CustomerId]
,[customer].[OriginalCustomerID] AS [TaxpayerId]
,[vattarget].[vattarget] AS [Vattarget]
,CAST( [vat1].[VAT] as int) AS VAT
,CAST([vat1].[VAT] as INT) - [vattarget].[vattarget] AS [Vatgap]
,[risk].[FraudRiskFactor] AS  [Fraud Risk Factor]
,[risk].[FraudRiskScore] AS [Fraud Risk Score]
,[auditdetails].[AuditorAction] AS [Auditor Action]
,[auditdetails].[PenaltyCharged] AS [Penalty Charged]
,[auditdetails].[TimeToClose] AS [Time to Close]
,[auditdetails].[AdditionalPenaltyAction] AS [Additional Penalty Action]
,[auditdetails].[RemarksFindings] AS [Remarks Findings]
,[sup].[auditor] AS [Auditor]
,[sup].[Supervisor] AS [Supervisor]

FROM
        rpt.tmpVATbySectorDate as [vat1] --- this is where the view is joined. This could also be a permanent table for others to use in the Curated Zone

INNER JOIN 
    OPENROWSET(
        BULK 'https://STORAGEACCOUNTNAME.dfs.core.windows.net/curated/EnterpriseTaxModel/Customer/**',
        FORMAT = 'PARQUET'
    ) AS [customer]
    ON [customer].[CustomerID] = [vat1].[CustomerAccountId]
INNER JOIN
    OPENROWSET(
        BULK 'https://STORAGEACCOUNTNAME.dfs.core.windows.net/curated/EnterpriseTaxModel/VAT_Targets/**',
        FORMAT = 'PARQUET'
    ) AS [vattarget]
    ON [vat1].[CustomerAccountId] = [vattarget].[CustomerID]
  AND [vat1].[invoicesoldtosector] = [vattarget].[TargetSector]
INNER JOIN   
        OPENROWSET(
        BULK 'https://STORAGEACCOUNTNAME.dfs.core.windows.net/curated/EnterpriseTaxModel/FraudRiskOutput/**',
        FORMAT = 'PARQUET'
    ) AS [risk]
    ON [customer].[CustomerID] = [risk].[CustomerID]
    AND [vat1].[Year] = YEAR([risk].[FraudRiskDate])
        AND [vat1].[Month] = MONTH([risk].[FraudRiskDate])
     AND   [vat1].[invoicesoldtosector] = [risk].[Sector]
INNER JOIN 
    OPENROWSET(
        BULK 'https://STORAGEACCOUNTNAME.dfs.core.windows.net/curated/EnterpriseTaxModel/AuditDetails/**',
        FORMAT = 'PARQUET'
    ) AS [auditdetails]
    ON [customer].[CustomerID] = [auditdetails]. [CustomerID]
        AND [vat1].[Year] = YEAR([auditdetails].[DateofAction])
        AND [vat1].[Month] = MONTH([auditdetails].[DateofAction])
         AND [vat1].[invoicesoldtosector] = [auditdetails].[Sector] 
     JOIN 
        OPENROWSET(
        BULK 'https://STORAGEACCOUNTNAME.dfs.core.windows.net/curated/EnterpriseTaxModel/AuditorStateSupervisor/**',
        FORMAT = 'PARQUET'
    ) AS [sup]
    ON [sup].[state] = [vat1].[invoicesoldtostate]   

WHERE [CustomerAccountId] = 103363


GROUP BY 
[vat1].[invoicesoldtostate]
,[vat1].[InvoiceSoldToSector] 
,[vat1].[Month]
,[vat1].[Year]
,[customer].[CustomerId]
,[customer].[OriginalCustomerID]
,[vattarget].[vattarget]
,[vat1].[VAT]
,[risk].[FraudRiskFactor]
,[risk].[FraudRiskScore]
,[auditdetails].[AuditorAction]
,[auditdetails].[PenaltyCharged]
,[auditdetails].[TimeToClose]
,[auditdetails].[AdditionalPenaltyAction]
,[auditdetails].[RemarksFindings]
,[sup].[auditor]
,[sup].[Supervisor]