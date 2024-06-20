/* Copyright (c) Microsoft Corporation.
 Licensed under the MIT license. */
  /*Acquisition Serivce*/
CREATE OR ALTER PROCEDURE [dbo].[usp_CreateIngestionOracle]
    @body nvarchar(max)
AS
BEGIN
 BEGIN TRY
	DECLARE @dynamicSinkPath NVARCHAR(MAX) = JSON_VALUE(@body, '$.dynamicSinkPath');
    DECLARE @OracleFileName NVARCHAR(MAX)
    DECLARE @OracleFolderPath NVARCHAR(MAX)
    DECLARE @TriggerName NVARCHAR(MAX)
	DECLARE @query NVARCHAR(MAX)
	DECLARE @separator CHAR(1) = '/';
	DECLARE @values TABLE ([index] INT, value NVARCHAR(MAX));
	--DECLARE @loadType NVARCHAR(MAX) = 'full' -- Should this be a parameter? 
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
    SET @OracleFileName = 'OperationsRiskManagement_Oracle_' + @subjectArea + '_' + JSON_VALUE(@body, '$."Table Schema"') + '_' + JSON_VALUE(@body, '$."Table Name"') + '_YYYYMMDDHHMMSS.parquet'
PRINT '@OracleFileName: ' + @OracleFileName;    
    SET @OracleFolderPath = 'OperationsRiskManagement/Oracle/' + @subjectArea + '/' + JSON_VALUE(@body, '$."Table Schema"') + '/' + JSON_VALUE(@body, '$."Table Name"') + '/'
    SET @TriggerName = 'TR_OperationsRiskManagement_Oracle_' + @subjectArea + JSON_VALUE(@body, '$."Table Schema"') + '_' + JSON_VALUE(@body, '$."Table Name"')
	SET @query = 'SELECT * FROM ' + JSON_VALUE(@body, '$."Table Schema"') + '.' + JSON_VALUE(@body, '$."Table Name"') + ' WHERE '+ JSON_VALUE(@body, '$."Watermark Column"') + ' > TO_TIMESTAMP(''WATERMARKVALUE'', ''YYYY-MM-DD HH24:MI:SS.FF'')';

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
        '{ "schema": "' + JSON_VALUE(@body, '$."Table Schema"') + '","table": "' + JSON_VALUE(@body, '$."Table Name"') + '","query": "' + @query + '" }'
        --SourceConnectionSettingsName
        ,'{ "keyVaultSecretName": "' + JSON_VALUE(@body, '$."Key Vault Secret Name"') + '" }'
        --CopySourceSettings
        ,'{ "watermark_column": "' + JSON_VALUE(@body, '$."Watermark Column"') + '","watermark_column_data_type": "' + JSON_VALUE(@body, '$."Watermark Format"') + '","partitioningOption": "' + JSON_VALUE(@body, '$."Is Data Partitioned?"') + '" }'
        --SinkObjectSettings
        ,'{ "fileName": "' + @OracleFileName + '","folderPath": "' + @OracleFolderPath + '","container": "' + JSON_VALUE(@body, '$."Source Container"') + '" }'
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
        ,'{ "ingestionPattern": "' + JSON_VALUE(@body, '$."Data Loading Behavior"') + '" }'
        --TaskId
        ,0
        --CopyEnabled
        ,1
        --DataContract
		,'{ "DataContractID": "' + JSON_VALUE(@body,'$.DataContractID') +'" }'
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
        '{  "fileName": "%.parquet","folderPath": "' + @OracleFolderPath + 'full/%' + '","container": "' + JSON_VALUE(@body, '$."Source Container"') + '" }'  -- where is '/full' and '/incremental' coming from? 
        --SourceConnectionSettingsName
        ,''
        --CopySourceSettings
        ,'{ "fileType": "parquet","compression":"" }'
        --SinkObjectSettings
        ,'{ "fileName": null, "folderPath": "' + @OracleFolderPath + '", "container": "' + JSON_VALUE(@body, '$."Sink Container"') + '" }'
        --SinkConnectionSettingsName
        ,''
        --CopySinkSettings
        ,''
        --CopyActivitySettings
        ,''
        --TopLevelPipelineName
        ,'PL_2_Process_Landed_Files_Step2' --JSON_VALUE(@body, '$."Top Level Pipeline Two"') where is this defined?
        --TriggerName
        ,'TR_FileCreated_Raw_EventLog' -- @TriggerName not needed?
        --DataLoadingBehaviorSettings
        ,'{ "dataLoadingBehavior":"Copy_to_Raw","loadType":"full" }'  
        --TaskId
        ,0
        --CopyEnabled
        ,1
		--DataContract
		,'{ "DataContractID": "' + JSON_VALUE(@body,'$.DataContractID') +'" }'
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
        '{  "fileName": "%.parquet","folderPath": "' + @OracleFolderPath + 'incremental/%' + '","container": "' + JSON_VALUE(@body, '$."Source Container"') + '" }'
        --SourceConnectionSettingsName
        ,''
        --CopySourceSettings
        ,'{ "fileType": "parquet","compression":"" }'
        --SinkObjectSettings
        ,'{ "fileName": null,"folderPath": "' + @OracleFolderPath + '","container": "' + JSON_VALUE(@body, '$."Sink Container"') + '" }'
        --SinkConnectionSettingsName
        ,''
        --CopySinkSettings
        ,''
        --CopyActivitySettings
        ,''
        --TopLevelPipelineName
        ,'PL_2_Process_Landed_Files_Step2' --JSON_VALUE(@body, '$."Top Level Pipeline Two"') where is this defined?
        --TriggerName
        ,'TR_FileCreated_Raw_EventLog' -- @TriggerName not needed?
        --DataLoadingBehaviorSettings
		,'{ "dataLoadingBehavior": "Copy_to_Raw", "loadType": "incremental" }'
        --TaskId
        ,0
        --CopyEnabled
        ,1
        --DataContract
        ,'{ "DataContractID": "' + JSON_VALUE(@body,'$.DataContractID') +'" }'
		--PurviewScanEnabled
		,1
   );
/*   This require changes in the Pattern Table and the PowerApp
    -- RECORD FOUR
    -- PL_3_MoveToStaging_Step2
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
		'{ "fileName": "%.parquet","folderPath": "' + @OracleFolderPath + '%", "container": "' + JSON_VALUE(@body, '$."Sink Container"') + '" }'
        --SourceConnectionSettingsName
        ,''
        --CopySourceSettings
        ,'{ "primary_key_cols": "' + JSON_VALUE(@body, '$."Primary Key Columns"') + '","partition_cols": "","date_partition_column":"","file_type":"" }'
        --SinkObjectSettings
        ,'{ "fileName": null,"folderPath": "' + @OracleFolderPath + '","container": "staging" }'
        --SinkConnectionSettingsName
        ,''
        --CopySinkSettings
        ,''
        --CopyActivitySettings
        ,''
        --TopLevelPipelineName
        ,'PL_3_MoveToStaging_Step2' 
        --TriggerName
        ,'TR_FileCreated_Landing_EventLog' -- @TriggerName not needed?
        --DataLoadingBehaviorSettings
		,'{ "dataLoadingBehavior": "Copy_to_Staging" }'
        --TaskId
        ,0
        --CopyEnabled
        ,1
        --DataContract
        ,'{ "DataContractID": "' + JSON_VALUE(@body,'$.DataContractID') +'" }'
		--PurviewScanEnabled
		,1
   );
*/
        -- Return a custom success message
        SELECT 'This SP executed' as SuccessMessage;
    END TRY
    BEGIN CATCH
        -- Return a custom error message
        SELECT ERROR_MESSAGE() as ErrorMessage;
    END CATCH;
END
GO


