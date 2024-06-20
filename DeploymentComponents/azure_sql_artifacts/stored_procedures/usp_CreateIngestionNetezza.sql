/* Copyright (c) Microsoft Corporation.
 Licensed under the MIT license. */
 /*Acquisition Serivce*/
/*
Netezza Tables require three ingestion records to be created for each pipeline run: 
* source to landing
* landing to raw: full
* landing to raw: incremental
Adding parameters to account for Large Tables
* A Netezza table is considered large when it has more than 50mm rows and less than
  or equal to 15 columns, or has more than 25mm rows and more than 15 columns
If Large Table:
* PatitioningOption = "DataSlice" in CopySourceSettings
* CopySinkSettings to {"UpdatePartionedFileName": true, "FileNameValueToReplace": "odbc_[NetezzaSchemaName][NetezzaTableName]"}'
*/
CREATE OR ALTER PROCEDURE [dbo].[usp_CreateIngestionNetezza]
 @body nvarchar(max)
 AS
BEGIN
	BEGIN TRY
	DECLARE @dynamicSinkPath NVARCHAR(MAX) = JSON_VALUE(@body, '$.dynamicSinkPath');
    DECLARE @NetezzaFileName NVARCHAR(MAX)
    DECLARE @NetezzaFolderPath NVARCHAR(MAX)
    DECLARE @TriggerName NVARCHAR(MAX)
	DECLARE @query NVARCHAR(MAX)
	DECLARE @separator CHAR(1) = '/';
	DECLARE @values TABLE ([index] INT, value NVARCHAR(MAX));

INSERT INTO @values
SELECT ROW_NUMBER() OVER (ORDER BY (SELECT NULL)), value
FROM STRING_SPLIT(@dynamicSinkPath, @separator);

-- Assign values to parameters
DECLARE @subjectArea NVARCHAR(MAX);
--DECLARE @dataSource  NVARCHAR(MAX);
DECLARE @dataSetName   NVARCHAR(MAX);
DECLARE @timeStamp DATETIME = SYSDATETIME();

SELECT @subjectArea = value FROM @values WHERE [index] = 1;
--SELECT @dataSource = value FROM @values WHERE [index] = 2;
SELECT @dataSetName  = value FROM @values WHERE [index] = 3;

SET @NetezzaFileName = 'OperationsRiskManagement_Netezza_' + @subjectArea + '_' + JSON_VALUE(@body, '$."Table Schema"') + '_' + JSON_VALUE(@body, '$."Table Name"') + '_' + FORMAT(@timeStamp, 'yyyyMMddHHmmss') + '.parquet'
PRINT '@NetezzaFileName: ' + @NetezzaFileName;    
SET @NetezzaFolderPath = 'OperationsRiskManagement/Netezza/' + @subjectArea + '/' + JSON_VALUE(@body, '$."Table Schema"') + '/' + JSON_VALUE(@body, '$."Table Name"') + '/'
SET @TriggerName = 'TR_OperationsRiskManagement_Netezza_' + @subjectArea + JSON_VALUE(@body, '$."Table Schema"') + '_' + JSON_VALUE(@body, '$."Table Name"')
SET @query = 'SELECT * FROM ' + JSON_VALUE(@body, '$."Table Schema"') + '.' + JSON_VALUE(@body, '$."Table Name"') + ' WHERE '+ JSON_VALUE(@body, '$."Watermark Column"') + ' > TO_TIMESTAMP(''' + JSON_VALUE(@body, '$."Watermark Value"') + ''', ''YYYY-MM-DD HH24:MI:SS.FF'')';

    -- RECORD 1 
    -- PL_1_Source_to_Landing_Orchestrator
    INSERT INTO [dbo].[ControlTable] (
        SourceObjectSettings,
        SourceConnectionSettingsName,
        CopySourceSettings,
        SinkObjectSettings,
        SinkConnectionSettingsName,
        CopySinkSettings,
        CopyActivitySettings,
        TopLevelPipelineName,
        TriggerName,
        DataLoadingBehaviorSettings,
        TaskId,
        CopyEnabled,
        DataContract,
		PurviewScanEnabled
    )
    VALUES ( 
        --SourceObjectSettings
        '{ "schema": "' + JSON_VALUE(@body, '$."Table Schema"') + '","table": "' + JSON_VALUE(@body, '$."Table Name"') + '","query": "' + @query + '"}'
        --SourceConnectionSettingsName
        ,'{"secretName": "' + JSON_VALUE(@body, '$."LS Secret Name"') + '"}'
        --CopySourceSettings
        ,'{ "watermark_column": "' + JSON_VALUE(@body, '$."Watermark Column"') + '","watermark_column_data_type": "' + JSON_VALUE(@body, '$."Watermark Format"') + '","watermark_value": "' + JSON_VALUE(@body, '$."Watermark Value"') + '","partitioningOption": "' + JSON_VALUE(@body, '$."Is Data Partitioned?"') + '"}'
        --SinkObjectSettings
        ,'{ "fileName": "' + @NetezzaFileName + '","folderPath": "' + @NetezzaFolderPath + '","container": "' + JSON_VALUE(@body, '$."Source Container"') + '" }'
        --SinkConnectionSettingsName
        ,''
        --CopySinkSettings
        ,''
        --CopyActivitySettings
        ,''
        --TopLevelPipelineName
        ,JSON_VALUE(@body, '$."Top Level Pipeline One"')
        --TriggerName
        ,@TriggerName
        --DataLoadingBehaviorSettings
        ,'{ "dataLoadingBehavior": "' + JSON_VALUE(@body, '$."Data Loading Behavior"') + '"}'
        --TaskId
        ,0
        --CopyEnabled
        ,1
        --DataContract
		,'{ "DataContractID": "' + JSON_VALUE(@body,'$.DataContractID') +'"}'
		--PurviewScanEnabled
		,1
    );

    -- RECORD TWO
    -- PL_2_Process_Landed_Files_Step2
    -- Full
    INSERT INTO [dbo].[ControlTable] (
        SourceObjectSettings,
        SourceConnectionSettingsName,
        CopySourceSettings,
        SinkObjectSettings,
        SinkConnectionSettingsName,
        CopySinkSettings,
        CopyActivitySettings,
        TopLevelPipelineName,
        TriggerName,
        DataLoadingBehaviorSettings,
        TaskId,
        CopyEnabled,
        DataContract,
		PurviewScanEnabled
    )
    VALUES (
        --SourceObjectSettings
        '{ "fileName": "' + @NetezzaFileName + '.parquet' + '",
            "folderPath": "' + @NetezzaFolderPath + '/' + '/full/%' + '", 
            "container": "' + JSON_VALUE(@body, '$."Source Container"') + '" }' 
        --SourceConnectionSettingsName
        ,''
        --CopySourceSettings
        ,'{ "fileType": "parquet","compression":""}'
        --SinkObjectSettings
        ,'{ "fileName": null, "folderPath": "' + @NetezzaFolderPath + '", "container": "' + JSON_VALUE(@body, '$."Sink Container"') + '" }'
        --SinkConnectionSettingsName
        ,''
        --CopySinkSettings
        ,''
        --CopyActivitySettings
        ,''
        --TopLevelPipelineName
        ,JSON_VALUE(@body, '$."Top Level Pipeline Two"')
        --TriggerName
        ,@TriggerName
        --DataLoadingBehaviorSettings
        ,'{"dataLoadingBehavior":"Copy_to_Raw","loadType":"full"}'  
        --TaskId
        ,0
        --CopyEnabled
        ,1
		--DataContract
		,'{"DataContractID": "' + JSON_VALUE(@body,'$.DataContractID') +'"}'
		--PurviewScanEnabled
		,1
    );

    -- RECORD THREE
    -- PL_2_Process_Landed_Files_Step2
    -- Incremental
    INSERT INTO [dbo].[ControlTable] (
        SourceObjectSettings,
        SourceConnectionSettingsName,
        CopySourceSettings,
        SinkObjectSettings,
        SinkConnectionSettingsName,
        CopySinkSettings,
        CopyActivitySettings,
        TopLevelPipelineName,
        TriggerName,
        DataLoadingBehaviorSettings,
        TaskId,
        CopyEnabled,
        DataContract,
		PurviewScanEnabled
 ) 
 VALUES (
        --SourceObjectSettings
        '{"fileName": "' + @NetezzaFileName + '.parquet' + '","folderPath": "' + @NetezzaFolderPath + '/incremental/%' + '","container": "' + JSON_VALUE(@body, '$."Source Container"') + '" }'
        --SourceConnectionSettingsName
        ,''
        --CopySourceSettings
        ,'{"fileType": "' + JSON_VALUE(@body, '$.fileType') + '","partitioningOption": "' + JSON_VALUE(@body, '$.PartitioningOption') + '"}'
        --SinkObjectSettings
        ,'{ "fileName": null,"folderPath": "' + @NetezzaFolderPath + '","container": "' + JSON_VALUE(@body, '$."Sink Container"') + '" }'
        --SinkConnectionSettingsName
        ,''
        --CopySinkSettings
        ,''
        --CopyActivitySettings
        ,''
        --TopLevelPipelineName
        ,JSON_VALUE(@body, '$."Top Level Pipeline Two"')
        --TriggerName
        ,@TriggerName
        --DataLoadingBehaviorSettings
		,'{"dataLoadingBehavior":"Oracle","loadType":"incremental"}'
        --TaskId
        ,0
        --CopyEnabled
        ,1
        --DataContract
        ,'{ "DataContractID": "' + JSON_VALUE(@body,'$.DataContractID') +'"}'
		--PurviewScanEnabled
		,1
   );
        -- Return a custom success message
    SELECT 'This SP executed' as SuccessMessage;
    END TRY
    BEGIN CATCH
        -- Return a custom error message
    SELECT ERROR_MESSAGE() as ErrorMessage;
    END CATCH;
END
GO


