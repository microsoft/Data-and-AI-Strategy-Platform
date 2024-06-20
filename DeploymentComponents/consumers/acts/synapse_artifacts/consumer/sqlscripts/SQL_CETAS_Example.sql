-- CETAS is not allowed to be used on 'replicated databases' IE, Lake Databases...


IF NOT EXISTS (SELECT * FROM sys.external_file_formats WHERE name = 'SynapseDelimitedTextFormat') 
	CREATE EXTERNAL FILE FORMAT [SynapseDelimitedTextFormat] 
	WITH ( FORMAT_TYPE = DELIMITEDTEXT ,
	       FORMAT_OPTIONS (
			 FIELD_TERMINATOR = ',',
			 USE_TYPE_DEFAULT = FALSE
			))
GO

IF NOT EXISTS (SELECT * FROM sys.external_data_sources WHERE name = 'raw_STORAGEACCOUNTNAME_dfs_core_windows_net') 
	CREATE EXTERNAL DATA SOURCE [raw_STORAGEACCOUNTNAME_dfs_core_windows_net] 
	WITH (
		LOCATION = 'abfss://raw@STORAGEACCOUNTNAME.dfs.core.windows.net' 
	)
GO

CREATE EXTERNAL TABLE alldata (
	[ID] bigint,
	[TypeIdentifier] nvarchar(256),
	[Name] nvarchar(256),
	[NTaxpayers] int,
	[NReturn] int,
	[NIssues] int,
	[NReturnsProcessed] int,
	[NReturnsAccepted] int,
	[NMonthlyDelayedPayments] int,
	[Penaltycollected] int,
	[PenaltyTarget] int,
	[InterestCollected] int,
	[InterestTarget] int,
	[NTaxpayersReportedtoLawEnforcement] int,
	[NPotentialAnomalies] int,
	[TaxIssues] int,
	[UnderaymentrDelayedPayments] int,
	[Penalties_YTD] int,
	[InterestCollected_YTD] int,
	[NReturnsScrutiny] int,
	[NAuditedReportsClosedWithPenaltyLessThan1000] int,
	[NTaxpayersUnderScrutiny] int,
	[InternalRiskandCompliance] int,
	[NTaxpayersReportedtoLawEnforcement1] int,
	[Nofcaseswithpotentialfraud] int,
	[Nofcasesstillunderscrutiny] int,
	[Potentialfrauddetected] int,
	[NofemployeesreportedtoLE] int,
	[Duescollected] int,
	[Penaltiescollected] int
	)
	WITH (
	LOCATION = 'Tax/Undefined/AllData/v1/full/2022/10/05/AllData10222021.csv',
	DATA_SOURCE = [raw_STORAGEACCOUNTNAME_dfs_core_windows_net],
	FILE_FORMAT = [SynapseDelimitedTextFormat]
	)
GO


SELECT TOP 100 * FROM dbo.alldata
GO