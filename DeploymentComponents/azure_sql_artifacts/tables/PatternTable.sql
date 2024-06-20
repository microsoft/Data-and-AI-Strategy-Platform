/* Copyright (c) Microsoft Corporation.
 Licensed under the MIT license. */
 /*Acquisition Serivce*/

/****** Object:  Table [dbo].[PatternTable]    Script Date: 7/18/2023 12:04:00 PM ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PatternTable]') AND type in (N'U'))
DROP TABLE [dbo].[PatternTable]
GO

/****** Object:  Table [dbo].[PatternTable]    Script Date: 7/18/2023 12:04:00 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[PatternTable](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[PatternType] [varchar](255) NULL,
	[LabelName] [varchar](255) NULL,
	[Name] [varchar](255) NULL,
	[ColumnType] [varchar](255) NULL,
	[required] [bit] NULL,
	[choices] [nvarchar](max) NULL,
	[Area] [varchar](255) NULL,
	[Screen] [varchar](255) NULL,
	[Icon] [varchar](255) NULL,
	[DataSourceType] [varchar](255) NULL,
	[DataSourceSystem] [varchar](255) NULL,
	[Description] [varchar](255) NULL,
	[Active] [bit] NULL,
	[visible] [bit] NULL Default(1),
	[columnValue] [varchar](200) NULL,
PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO

-- Insert sample data into PatternTable
INSERT INTO [dbo].[PatternTable]
(
    [PatternType],
    [LabelName],
    [Name],
    [ColumnType],
    [required],
    [choices],
    [Area],
    [Screen],
    [Icon],
    [DataSourceType],
    [DataSourceSystem],
    [Description],
    [Active],
    [visible],
    [columnValue]

    
)
VALUES
    ('Delimited Text', 'Delimited File Name', 'DelimitedFileName', 'text', 1, '', 'DataAssetTechnicalInformation', 'Handshake Pattern', 'Icon.Home', 'delimitedText', 'Delimited', 'Collects the necessary metadata required to register a Delimited Text Ingestion Pattern.', 1, 1, ''),
    ('Delimited Text', 'Delimiter Name', 'DelimiterName', 'choice', 1, 'comma#semi-colon#tab#pipe', 'DataAssetTechnicalInformation', 'Handshake Pattern', 'Icon.Home', 'delimitedText', 'Delimited', 'Collects the necessary metadata required to register a Delimited Text Ingestion Pattern.', 1, 1, ''),
    ('Delimited Text', 'Source Container', 'SourceContainer', 'variable', 1, '', 'SourceTechnicalInformation', 'Handshake Pattern', 'Icon.Home', 'delimitedText', 'Delimited', 'Collects the necessary metadata required to register a Delimited Text Ingestion Pattern.', 1, 1, 'landing'),
    ('Delimited Text', 'Sink Container', 'sinkContainer', 'variable', 1, '', 'SourceTechnicalInformation', 'Handshake Pattern', 'Icon.Home', 'delimitedText', 'Delimited', 'Collects the necessary metadata required to register a Delimited Text Ingestion Pattern.', 1, 1, 'raw'),
    ('Delimited Text', 'Stored Procedure Name', 'storedProcedureName', 'variable', 1, '', 'SourceTechnicalInformation', 'Handshake Pattern', 'Icon.Home', 'delimitedText', 'Delimited', 'Collects the necessary metadata required to register a Delimited Text Ingestion Pattern.', 1, 1, 'usp_CreateIngestionDelimited'),
    ('Delimited Text', 'Trigger Name', 'triggerName', 'variable', 1, '', 'SourceTechnicalInformation', 'Handshake Pattern', 'Icon.Home', 'delimitedText', 'Delimited', 'Collects the necessary metadata required to register a Delimited Text Ingestion Pattern.', 1, 1, '[TR_blobCreatedEvent]'),
    ('Delimited Text', 'Top Level PipeLine Name', 'topLevelPipelineName', 'variable', 1, '', 'SourceTechnicalInformation', 'Handshake Pattern', 'Icon.Home', 'delimitedText', 'Delimited', 'Collects the necessary metadata required to register a Delimited Text Ingestion Pattern.', 1, 1, 'PL_2_Process_Landed_Files_Step2'),
    ('Delimited Text', 'Data Loading Behavior', 'dataLoadingBehavior', 'variable', 1, '', 'SourceTechnicalInformation', 'Handshake Pattern', 'Icon.Home', 'delimitedText', 'Delimited', 'Collects the necessary metadata required to register a Delimited Text Ingestion Pattern.', 1, 1, '{"dataLoadingBehavior": "Copy_to_Raw", "loadType": "full"}'),
    ('Excel', 'Excel File Name', 'excelFileName', 'text', 1, '', 'DataAssetTechnicalInformation', 'Handshake Pattern', 'Icon.Home', 'Excel', 'Excel', 'Collects the necessary metadata required to register an Excel file Ingestion Pattern.', 1, 1, ''),
    ('Excel', 'Excel Sheet Name', 'excelSheetName', 'text', 1, '', 'DataAssetTechnicalInformation', 'Handshake Pattern', 'Icon.Home', 'Excel', 'Excel', 'Collects the necessary metadata required to register an Excel file Ingestion Pattern.', 1, 1, ''),
    ('Excel', 'Excel Sheet Header Row', 'excelSheetHeaderRow', 'text', 1, '', 'DataAssetTechnicalInformation', 'Handshake Pattern', 'Icon.Home', 'Excel', 'Excel', 'Collects the necessary metadata required to register an Excel file Ingestion Pattern.', 1, 1, ''),
    ('Excel', 'Source Container', 'SourceContainer', 'variable', 1, '', 'SourceTechnicalInformation', 'Handshake Pattern', 'Icon.Home', 'Excel', 'Excel', 'Collects the necessary metadata required to register an Excel file Ingestion Pattern.', 1, 1, 'landing'),
    ('Excel', 'Sink Container', 'sinkContainer', 'variable', 1, '', 'SourceTechnicalInformation', 'Handshake Pattern', 'Icon.Home', 'Excel', 'Excel', 'Collects the necessary metadata required to register an Excel file Ingestion Pattern.', 1, 1, 'raw'),
    ('Excel', 'Stored Procedure Name', 'storedProcedureName', 'variable', 1, '', 'SourceTechnicalInformation', 'Handshake Pattern', 'Icon.Home', 'Excel', 'Excel', 'Collects the necessary metadata required to register an Excel file Ingestion Pattern.', 1, 1, 'usp_CreateIngestionExcel'),
    ('Excel', 'Trigger Name', 'triggerName', 'variable', 1, '', 'SourceTechnicalInformation', 'Handshake Pattern', 'Icon.Home', 'Excel', 'Excel', 'Collects the necessary metadata required to register an Excel file Ingestion Pattern.', 1, 1, '[TR_blobCreatedEvent]'),
    ('Excel', 'Top Level PipeLine Name', 'topLevelPipelineName', 'variable', 1, '', 'SourceTechnicalInformation', 'Handshake Pattern', 'Icon.Home', 'Excel', 'Excel', 'Collects the necessary metadata required to register an Excel file Ingestion Pattern.', 1, 1, 'PL_2_Process_Landed_Files_Step2'),
    ('Excel', 'Data Loading Behavior', 'dataLoadingBehavior', 'variable', 1, '', 'SourceTechnicalInformation', 'Handshake Pattern', 'Icon.Home', 'Excel', 'Excel', 'Collects the necessary metadata required to register an Excel file Ingestion Pattern.', 1, 1, '{ "dataLoadingBehavior": "Extract_Excel_Sheets" }'),
    ('Parquet', 'Parquet File Name', 'parquetFileName', 'text', 1, '', 'DataAssetTechnicalInformation', 'Handshake Pattern', 'Icon.Home', 'Parquet', 'Parquet', 'Collects the necessary metadata required to register an Parquet file Ingestion Pattern.', 1, 1, ''),
    ('Parquet', 'Source Container', 'SourceContainer', 'variable', 1, '', 'SourceTechnicalInformation', 'Handshake Pattern', 'Icon.Home', 'Parquet', 'Parquet', 'Collects the necessary metadata required to register an Parquet file Ingestion Pattern.', 1, 1, 'landing'),
    ('Parquet', 'Sink Container', 'sinkContainer', 'variable', 1, '', 'SourceTechnicalInformation', 'Handshake Pattern', 'Icon.Home', 'Parquet', 'Parquet', 'Collects the necessary metadata required to register an Parquet file Ingestion Pattern.', 1, 1, 'raw'),
    ('Parquet', 'Stored Procedure Name', 'storedProcedureName', 'variable', 1, '', 'SourceTechnicalInformation', 'Handshake Pattern', 'Icon.Home', 'Parquet', 'Parquet', 'Collects the necessary metadata required to register an Parquet file Ingestion Pattern.', 1, 1, 'usp_CreateIngestionParquet'),
    ('Parquet', 'Trigger Name', 'triggerName', 'variable', 1, '', 'SourceTechnicalInformation', 'Handshake Pattern', 'Icon.Home', 'Parquet', 'Parquet', 'Collects the necessary metadata required to register an Parquet file Ingestion Pattern.', 1, 1, '[TR_blobCreatedEvent]'),
    ('Parquet', 'Top Level PipeLine Name', 'topLevelPipelineName', 'variable', 1, '', 'SourceTechnicalInformation', 'Handshake Pattern', 'Icon.Home', 'Parquet', 'Parquet', 'Collects the necessary metadata required to register an Parquet file Ingestion Pattern.', 1, 1, 'PL_2_Process_Landed_Files_Step2'),
    ('Parquet', 'Data Loading Behavior', 'dataLoadingBehavior', 'variable', 1, '', 'SourceTechnicalInformation', 'Handshake Pattern', 'Icon.Home', 'Parquet', 'Parquet', 'Collects the necessary metadata required to register an Parquet file Ingestion Pattern.', 1, 1, '{ "dataLoadingBehavior": "Copy_to_Raw", "loadType": "delta" }'),
    ('JSON', 'JSON File Name', 'jsonFileName', 'text', 1, '', 'DataAssetTechnicalInformation', 'Handshake Pattern', 'Icon.Home', 'JSON', 'JSON', 'Collects the necessary metadata required to register a JSON file Ingestion Pattern.', 1, 1, ''),
    ('JSON', 'Source Container', 'SourceContainer', 'variable', 1, '', 'SourceTechnicalInformation', 'Handshake Pattern', 'Icon.Home', 'JSON', 'JSON', 'Collects the necessary metadata required to register a JSON file Ingestion Pattern.', 1, 1, 'landing'),
    ('JSON', 'Sink Container', 'sinkContainer', 'variable', 1, '', 'SourceTechnicalInformation', 'Handshake Pattern', 'Icon.Home', 'JSON', 'JSON', 'Collects the necessary metadata required to register a JSON file Ingestion Pattern.', 1, 1, 'raw'),
    ('JSON', 'Stored Procedure Name', 'storedProcedureName', 'variable', 1, '', 'SourceTechnicalInformation', 'Handshake Pattern', 'Icon.Home', 'JSON', 'JSON', 'Collects the necessary metadata required to register a JSON file Ingestion Pattern.', 1, 1, 'usp_CreateIngestionJSON'),
    ('JSON', 'Trigger Name', 'triggerName', 'variable', 1, '', 'SourceTechnicalInformation', 'Handshake Pattern', 'Icon.Home', 'JSON', 'JSON', 'Collects the necessary metadata required to register a JSON file Ingestion Pattern.', 1, 1, '[TR_blobCreatedEvent]'),
    ('JSON', 'Top Level PipeLine Name', 'topLevelPipelineName', 'variable', 1, '', 'SourceTechnicalInformation', 'Handshake Pattern', 'Icon.Home', 'JSON', 'JSON', 'Collects the necessary metadata required to register a JSON file Ingestion Pattern.', 1, 1, 'PL_2_Process_Landed_Files_Step2'),
    ('JSON', 'Multi-Line', 'multiLineJSON', 'variable', 1, '', 'SourceTechnicalInformation', 'Handshake Pattern', 'Icon.Home', 'JSON', 'JSON', 'Collects the necessary metadata required to register a JSON file Ingestion Pattern.', 1, 1, 'FALSE'),
    ('JSON', 'Compression', 'compression', 'choice', 1, 'none#bzip2#gzip#deflate', 'DataAssetTechnicalInformation', 'Handshake Pattern', 'Icon.Home', 'JSON', 'JSON', 'Collects the necessary metadata required to register a JSON file Ingestion Pattern.', 1, 1, ''),
    ('JSON', 'Data Loading Behavior', 'dataLoadingBehavior', 'variable', 1, '', 'SourceTechnicalInformation', 'Handshake Pattern', 'Icon.Home', 'JSON', 'JSON', 'Collects the necessary metadata required to register a JSON file Ingestion Pattern.', 1, 1, '{ "dataLoadingBehavior": "Copy_to_Raw", "loadType": "delta" }'),
    ('PDF', 'PDF File Name', 'pdfFileName', 'text', 1, '', 'DataAssetTechnicalInformation', 'Handshake Pattern', 'Icon.Home', 'PDF', 'PDF', 'Collects the necessary metadata required to register a PDF/Image file Ingestion Pattern.', 1, 1, ''),
    ('PDF', 'Select Model', 'selectModel', 'choice', 1, 'prebuilt-invoice#prebuilt-receipt#prebuilt-tax.us.w2#prebuilt-idDocument#prebuilt-businessCard', 'DataAssetTechnicalInformation', 'Handshake Pattern', 'Icon.Home', 'PDF', 'PDF', 'Collects the necessary metadata required to register a PDF file Ingestion Pattern.', 1, 1, ''),
    ('PDF', 'Source Container', 'SourceContainer', 'variable', 1, '', 'SourceTechnicalInformation', 'Handshake Pattern', 'Icon.Home', 'PDF', 'PDF', 'Collects the necessary metadata required to register a PDF file Ingestion Pattern.', 1, 1, 'landing'),
    ('PDF', 'Sink Container', 'sinkContainer', 'variable', 1, '', 'SourceTechnicalInformation', 'Handshake Pattern', 'Icon.Home', 'PDF', 'PDF', 'Collects the necessary metadata required to register a PDF file Ingestion Pattern.', 1, 1, 'raw'),
    ('PDF', 'Stored Procedure Name', 'storedProcedureName', 'variable', 1, '', 'SourceTechnicalInformation', 'Handshake Pattern', 'Icon.Home', 'PDF', 'PDF', 'Collects the necessary metadata required to register a PDF file Ingestion Pattern.', 1, 1, 'usp_CreateIngestionPDF'),
    ('PDF', 'Trigger Name', 'triggerName', 'variable', 1, '', 'SourceTechnicalInformation', 'Handshake Pattern', 'Icon.Home', 'PDF', 'PDF', 'Collects the necessary metadata required to register a PDF file Ingestion Pattern.', 1, 1, '[TR_blobCreatedEvent]'),
    ('PDF', 'Top Level PipeLine Name', 'topLevelPipelineName', 'variable', 1, '', 'SourceTechnicalInformation', 'Handshake Pattern', 'Icon.Home', 'PDF', 'PDF', 'Collects the necessary metadata required to register a PDF file Ingestion Pattern.', 1, 1, 'PL_2_Process_Landed_Files_Step2'),
    ('PDF', 'Data Loading Behavior', 'dataLoadingBehavior', 'variable', 1, '', 'SourceTechnicalInformation', 'Handshake Pattern', 'Icon.Home', 'PDF', 'PDF', 'Collects the necessary metadata required to register a PDF file Ingestion Pattern.', 1, 1, '{ "dataLoadingBehavior": "Form_Recognizer_Extraction" }'),
	('Oracle', 'Is Data Partitioned?', 'partitioningOption', 'choice', 1, 'None#Physical Partition of Table', 'SourceTechnicalInformation', 'Handshake Pattern', 'Icon.Home', 'Oracle', 'Oracle', 'Collects the necessary metadata required to register an Oracle Ingestion Pattern.', 1, 1, ''),
	('Oracle', 'Table Name', 'tableName', 'text', 1, '', 'DataAssetTechnicalInformation', 'Handshake Pattern', 'Icon.Home', 'Oracle', 'Oracle', 'Collects the necessary metadata required to register an Oracle Ingestion Pattern.', 1, 1, ''),
	('Oracle', 'Table Schema', 'tableSchema', 'text', 1, '', 'DataAssetTechnicalInformation', 'Handshake Pattern', 'Icon.Home', 'Oracle', 'Oracle', 'Collects the necessary metadata required to register an Oracle Ingestion Pattern.', 1, 1, ''),
	('Oracle', 'Watermark Column', 'watermarkColumn', 'text', 1, '', 'SourceTechnicalInformation', 'Handshake Pattern', 'Icon.Home', 'Oracle', 'Oracle', 'Collects the necessary metadata required to register an Oracle Ingestion Pattern.', 1, 1, ''),
	('Oracle', 'Watermark Format', 'watermarkFormat', 'choice', 1, 'DATETIME#INT#STRING', 'SourceTechnicalInformation', 'Handshake Pattern', 'Icon.Home', 'Oracle', 'Oracle', 'Collects the necessary metadata required to register an Oracle Ingestion Pattern.', 1, 1, ''),
	('Oracle', 'Key Vault Secret Name', 'keyVaultSecretName', 'variable', 1, '', 'SourceTechnicalInformation', 'Handshake Pattern', 'Icon.Home', 'Oracle', 'Oracle', 'Collects the necessary metadata required to register an Oracle Ingestion Pattern.', 1, 1, ''),
	('Oracle', 'Top Level Pipeline One', 'topLevelPipelineOne', 'variable', 1, '', 'SourceTechnicalInformation', 'Handshake Pattern', 'Icon.Home', 'Oracle', 'Oracle', 'Collects the necessary metadata required to register a Oracle file Ingestion Pattern.', 1, 1, 'PL_1_Source_to_Landing_Step1'),
	('Oracle', 'Data Loading Behavior', 'dataLoadingBehavior', 'variable', 1, '', 'SourceTechnicalInformation', 'Handshake Pattern', 'Icon.Home', 'Oracle', 'Oracle', 'Collects the necessary metadata required to register a Oracle file Ingestion Pattern.', 1, 1, 'Oracle'),
	('Oracle', 'Source Container', 'sourceContainer', 'variable', 1, '', 'SourceTechnicalInformation', 'Handshake Pattern', 'Icon.Home', 'Oracle', 'Oracle', 'Collects the necessary metadata required to register a Oracle file Ingestion Pattern.', 1, 1, 'landing'),
	('Oracle', 'Sink Container', 'sinkContainer', 'variable', 1, '', 'SourceTechnicalInformation', 'Handshake Pattern', 'Icon.Home', 'Oracle', 'Oracle', 'Collects the necessary metadata required to register a Oracle file Ingestion Pattern.', 1, 1, 'raw'),
	('AzureSQL', 'Is Data Partitioned?', 'partitioningOption', 'choice', 1, 'None#Physical Partition of Table', 'SourceTechnicalInformation', 'Handshake Pattern', 'Icon.Home', 'AzureSQL', 'AzureSQL', 'Collects the necessary metadata required to register an AzureSQL Ingestion Pattern.', 1, 1, ''),
	('AzureSQL', 'Table Name', 'tableName', 'text', 1, '', 'DataAssetTechnicalInformation', 'Handshake Pattern', 'Icon.Home', 'AzureSQL', 'AzureSQL', 'Collects the necessary metadata required to register an AzureSQL Ingestion Pattern.', 1, 1, ''),
	('AzureSQL', 'Table Schema', 'tableSchema', 'text', 1, '', 'DataAssetTechnicalInformation', 'Handshake Pattern', 'Icon.Home', 'AzureSQL', 'AzureSQL', 'Collects the necessary metadata required to register an AzureSQL Ingestion Pattern.', 1, 1, ''),
	('AzureSQL', 'Watermark Column', 'watermarkColumn', 'text', 1, '', 'SourceTechnicalInformation', 'Handshake Pattern', 'Icon.Home', 'AzureSQL', 'AzureSQL', 'Collects the necessary metadata required to register an AzureSQL Ingestion Pattern.', 1, 1, ''),
	('AzureSQL', 'Watermark Format', 'watermarkFormat', 'choice', 1, 'DATETIME#INT#STRING', 'SourceTechnicalInformation', 'Handshake Pattern', 'Icon.Home', 'AzureSQL', 'AzureSQL', 'Collects the necessary metadata required to register an AzureSQL Ingestion Pattern.', 1, 1, ''),
	('AzureSQL', 'Key Vault Secret Name', 'keyVaultSecretName', 'variable', 1, '', 'SourceTechnicalInformation', 'Handshake Pattern', 'Icon.Home', 'AzureSQL', 'AzureSQL', 'Collects the necessary metadata required to register an AzureSQL Ingestion Pattern.', 1, 1, ''),
	('AzureSQL', 'Top Level Pipeline One', 'topLevelPipelineOne', 'variable', 1, '', 'SourceTechnicalInformation', 'Handshake Pattern', 'Icon.Home', 'AzureSQL', 'AzureSQL', 'Collects the necessary metadata required to register a AzureSQL file Ingestion Pattern.', 1, 1, 'PL_1_Source_to_Landing_Step1'),
	('AzureSQL', 'Data Loading Behavior', 'dataLoadingBehavior', 'variable', 1, '', 'SourceTechnicalInformation', 'Handshake Pattern', 'Icon.Home', 'AzureSQL', 'AzureSQL', 'Collects the necessary metadata required to register a AzureSQL file Ingestion Pattern.', 1, 1, 'AzureSQL'),
	('AzureSQL', 'Source Container', 'sourceContainer', 'variable', 1, '', 'SourceTechnicalInformation', 'Handshake Pattern', 'Icon.Home', 'AzureSQL', 'AzureSQL', 'Collects the necessary metadata required to register a AzureSQL file Ingestion Pattern.', 1, 1, 'landing'),
	('AzureSQL', 'Sink Container', 'sinkContainer', 'variable', 1, '', 'SourceTechnicalInformation', 'Handshake Pattern', 'Icon.Home', 'AzureSQL', 'AzureSQL', 'Collects the necessary metadata required to register a AzureSQL file Ingestion Pattern.', 1, 1, 'raw');
GO