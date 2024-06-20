
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


CREATE OR ALTER VIEW [actstax].[factinvoicedaily]
AS
SELECT 
[invoice].[InvoiceDate]
,[invoice].[CustomerAccountId]
,[invoice].[InvoiceSoldToState]
,[invoice].[TotalInvoiceTaxesAmount]
,[invoice].[InvoiceSoldToSector]
,[AnomalyResults].[AnomalyResult]
,[TaxAnomalyTypes].[TaxAnomalyTypeName]
FROM
        OPENROWSET(
        BULK 'https://STORAGEACCOUNTNAME.dfs.core.windows.net/curated/EnterpriseTaxModel/Invoice/Year=2020/**',
        FORMAT = 'PARQUET'
    ) AS [invoice]
JOIN 
    OPENROWSET(
        BULK 'https://STORAGEACCOUNTNAME.dfs.core.windows.net/curated/EnterpriseTaxModel/AnomalyResults/**',
        FORMAT = 'PARQUET'
    ) AS [AnomalyResults]
ON [AnomalyResults].[CustomerID] = [invoice].[CustomerAccountId]
AND [AnomalyResults].[State] = [invoice].[InvoiceSoldToState]
AND [AnomalyResults].[Sector] = [invoice].[InvoiceSoldToSector]
AND [AnomalyResults].[Date] = [invoice].[InvoiceDate]
AND [AnomalyResults].[VAT] = [invoice].[TotalInvoiceTaxesAmount]
JOIN 
    OPENROWSET(
        BULK 'https://STORAGEACCOUNTNAME.dfs.core.windows.net/curated/EnterpriseTaxModel/TaxAnomalyTypes/**',
        FORMAT = 'PARQUET'
    ) AS [TaxAnomalyTypes]
ON [AnomalyResults].[TaxAnomalyTypeID] = [TaxAnomalyTypes].[TaxAnomalyTypeId]
WHERE [AnomalyResults].[AnomalyResult] = 1
-- AND [AnomalyResults].[CustomerID] = '19014'
-- --AND [invoice].[TaxpayerId] = 'AAE-5065509-B'
--AND [invoice].[Year]= 2020
-- AND [invoice].[InvoiceSoldToSector] = 'Retail'
GROUP BY
[invoice].[InvoiceDate]
,[invoice].[CustomerAccountId]
,[invoice].[InvoiceSoldToState]
,[invoice].[TotalInvoiceTaxesAmount]
,[invoice].[InvoiceSoldToSector]

,[AnomalyResults].[AnomalyResult]
,[TaxAnomalyTypes].[TaxAnomalyTypeName]










