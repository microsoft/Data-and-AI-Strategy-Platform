-- Create a tmp table to get the summed values by date and by sector for VAT
DROP VIEW IF EXISTS rpt.tmpVATbySectorDate;
GO
CREATE OR ALTER VIEW 
rpt.VATbySectorDate
AS
SELECT
[CustomerAccountId],
DATEPART(YYYY,[InvoiceDate]) AS [Year],
DATEPART(MONTH,[InvoiceDate]) AS [Month],
[InvoiceSoldToState],
[InvoiceSoldToSector],
SUM([TotalInvoiceTaxesAmount]) AS VAT
FROM
        OPENROWSET(
        BULK 'https://STORAGEACCOUNTNAME.dfs.core.windows.net/curated/EnterpriseTaxModel/Invoice/**',
        FORMAT = 'PARQUET'
		    ) AS [vat]

            --WHERE [CustomerAccountId] = 133
			GROUP BY [CustomerAccountId],
	        DATEPART(MONTH,[InvoiceDate]),
            DATEPART(YEAR,[InvoiceDate]),
            [InvoiceSoldToState],
            [InvoiceSoldToSector]