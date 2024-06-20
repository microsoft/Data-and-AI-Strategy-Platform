/* Copyright (c) Microsoft Corporation.
 Licensed under the MIT license. */
 /*Acquisition Serivce*/
CREATE OR ALTER PROCEDURE [dbo].[usp_CreateIngestionExcel]
@body nvarchar(max)
AS
BEGIN
--DECLARE @TriggerName NVARCHAR(255) 
--SET @TriggerName = 'TR_' + JSON_VALUE(@body, '$.DomainInput') + '_' + JSON_VALUE(@body, '$.DataSourceInput') + '_' + JSON_VALUE(@body, '$.DataSetInput') + '_' + JSON_VALUE(@body, '$.DataContractID')
DECLARE @currentdate DATETIME
SET @currentdate = GETDATE()
DECLARE @createddate DATETIME
SET @createddate = GETDATE()
INSERT INTO [dbo].[ControlTable] (
	 SourceObjectSettings
	,SourceConnectionSettingsName
	,CopySourceSettings
	,SinkObjectSettings
	,SinkConnectionSettingsName
	,CopySinkSettings
	,CopyActivitySettings
	,TopLevelPipelineName
	,TriggerName
	,DataLoadingBehaviorSettings
	,TaskId
	,CopyEnabled
	,DataContract
	,PurviewScanEnabled
)
VALUES (
--SourceObjectSettings
'{ "fileName": "' + JSON_VALUE(@body, '$."Excel File Name"') + '","folderPath": "' + JSON_VALUE(@body, '$.SourceFolderPath') + '","container": "' + JSON_VALUE(@body, '$."Source Container"') + '"}'
--SourceConnectionSettingsName
,''
--CopySourceSettings
,  '[{ "SheetName": "' + JSON_VALUE(@body, '$."Excel Sheet Name"') + '", "HeaderRow": "' + JSON_VALUE(@body, '$."Excel Sheet Header Row"') + '"}]'
--SinkObjectSettings
,'{ "fileName": "' + JSON_VALUE(@body, '$."Excel File Name"') + '", "folderPath": "' + JSON_VALUE(@body, '$.dynamicSinkPath') + '",  "container": "' + JSON_VALUE(@body, '$."Sink Container"') + '" }'
--SinkConnectionSettingsName
,''
--CopySinkSettings
,''
--CopyActivitySettings
,''
--TopLevelPipelineName
,JSON_VALUE(@body, '$."Top Level PipeLine Name"')
--TriggerName
,JSON_VALUE(@body, '$."Trigger Name"')
--DataLoadingBehaviorSettings
,JSON_VALUE(@body,'$."Data Loading Behavior"')
--TaskId
,0
--CopyEnabled
,1
--DataContract
,'{ "DataContractID": "' + JSON_VALUE(@body,'$.DataContractID') +'"}'
--PurviewScanEnabled
,1
);
END
GO


