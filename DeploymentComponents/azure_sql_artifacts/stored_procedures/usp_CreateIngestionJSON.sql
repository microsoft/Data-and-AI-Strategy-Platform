/* Copyright (c) Microsoft Corporation.
 Licensed under the MIT license. */
 /*Acquisition Serivce*/
CREATE OR ALTER PROCEDURE [dbo].[usp_CreateIngestionJSON]
@body nvarchar(max)
AS
BEGIN
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
'{ "fileName": "' + JSON_VALUE(@body, '$."JSON File Name"') + '","folderPath": "' + JSON_VALUE(@body, '$.SourceFolderPath') + '","container": "' + JSON_VALUE(@body, '$."Source Container"') + '" }'
--SourceConnectionSettingsName
,''
--CopySourceSettings
,'{ "fileType": "json", "multiline": false, "compression": "' + JSON_VALUE(@body, '$.Compression') + '"}'
--SinkObjectSettings
,'{ "fileName": "' + JSON_VALUE(@body, '$."JSON File Name"') + '", "folderPath": "' + JSON_VALUE(@body, '$.dynamicSinkPath') + '",  "container": "' + JSON_VALUE(@body, '$."Sink Container"') + '" }'
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


