SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE OR ALTER PROCEDURE [dbo].[Execute_For_Beneficial_Owner_Consumer]
AS
BEGIN

IF NOT EXISTS(SELECT * FROM sys.database_principals WHERE name = 'insert_synapse_name')
  BEGIN
    CREATE USER [insert_synapse_name] FROM EXTERNAL PROVIDER;
  END

GRANT SELECT ON OBJECT::[dbo].[IngestedLandingDataAudit]
    TO [insert_synapse_name];

DECLARE @controlTableRecords INTEGER 

SET @controlTableRecords = (SELECT COUNT(*) FROM [dbo].[ControlTable] 
                            WHERE [SourceObjectSettings] = '{ "fileName": "Canada_AllTime", "folderPath": "%/%", "container": "landing" }')

IF @controlTableRecords = 0
BEGIN
INSERT [dbo].[ControlTable] ([SourceObjectSettings], [SourceConnectionSettingsName], [CopySourceSettings], [SinkObjectSettings], [SinkConnectionSettingsName], [CopySinkSettings], [CopyActivitySettings], [TopLevelPipelineName], [TriggerName], [DataLoadingBehaviorSettings], [TaskId], [CopyEnabled], [DataContract], [PurviewScanEnabled]) VALUES (N'{ "fileName": "companies.csv", "folderPath": "BeneficialOwnership/OpenData/Corporate/", "container": "landing" }', N'', N'{ "fileType": "delimitedText", "delimiter": ",", "compression": "None"}', N'{ "fileName": null, "folderPath": "BeneficialOwnership/OpenData/Corporate/AllData/", "container": "raw" }', N'', N'', N'', N'PL_2_Process_Landed_Files_Step2', N'TR_blobCreatedEvent', N'{ "dataLoadingBehavior": "Copy_to_Raw", "loadType": "full" }', 0, 1, N'{}', 1)

INSERT [dbo].[ControlTable] ([SourceObjectSettings], [SourceConnectionSettingsName], [CopySourceSettings], [SinkObjectSettings], [SinkConnectionSettingsName], [CopySinkSettings], [CopyActivitySettings], [TopLevelPipelineName], [TriggerName], [DataLoadingBehaviorSettings], [TaskId], [CopyEnabled], [DataContract], [PurviewScanEnabled]) VALUES (N'{ "fileName": "Canada_AllTime", "folderPath": "%/%", "container": "landing" }', N'', N'{ "fileType": "json", "multiline": false, "compression": "None"}', N'{ "fileName": null, "folderPath": "BeneficialOwnership/OpenData/Contracting/Canada/AllTime/", "container": "raw" }', N'', N'', N'', N'PL_2_Process_Landed_Files_Step2', N'TR_blobCreatedEvent', N'{ "dataLoadingBehavior": "Copy_to_Raw", "loadType": "full" }', 0, 1, N'{}', 1)

INSERT [dbo].[ControlTable] ([SourceObjectSettings], [SourceConnectionSettingsName], [CopySourceSettings], [SinkObjectSettings], [SinkConnectionSettingsName], [CopySinkSettings], [CopyActivitySettings], [TopLevelPipelineName], [TriggerName], [DataLoadingBehaviorSettings], [TaskId], [CopyEnabled], [DataContract], [PurviewScanEnabled]) VALUES (N'{ "Url": "https://data.open-contracting.org/api/download_export?spider=canada_quebec&job_id=949&full=true&suffix=jsonl.gz" }', N'', N'{ "fileType": "gz" }', N'{ "fileName": "Canada_AllTime", "folderPath": "BeneficialOwnership/OpenData/Contracting/Canada/AllTime/", "container": "landing" }', N'', N'', N'', NULL, NULL, N'{ "dataLoadingBehavior": "Copy_to_Landing" }', 0, 1, N'{}', 1)

INSERT [dbo].[ControlTable] ([SourceObjectSettings], [SourceConnectionSettingsName], [CopySourceSettings], [SinkObjectSettings], [SinkConnectionSettingsName], [CopySinkSettings], [CopyActivitySettings], [TopLevelPipelineName], [TriggerName], [DataLoadingBehaviorSettings], [TaskId], [CopyEnabled], [DataContract], [PurviewScanEnabled]) VALUES (N'{ "Url": "https://data.open-contracting.org/api/download_export?spider=nigeria_abia_state&job_id=965&full=true&suffix=jsonl.gz" }', N'', N'{ "fileType": "gz" }', N'{ "fileName": "Nigeria_AllTime", "folderPath": "BeneficialOwnership/OpenData/Contracting/Nigeria/AllTime/", "container": "landing" }', N'', N'', N'', NULL, NULL, N'{ "dataLoadingBehavior": "Copy_to_Landing" }', 0, 1, N'{}', 1)

INSERT [dbo].[ControlTable] ([SourceObjectSettings], [SourceConnectionSettingsName], [CopySourceSettings], [SinkObjectSettings], [SinkConnectionSettingsName], [CopySinkSettings], [CopyActivitySettings], [TopLevelPipelineName], [TriggerName], [DataLoadingBehaviorSettings], [TaskId], [CopyEnabled], [DataContract], [PurviewScanEnabled]) VALUES (N'{ "fileName": "Nigeria_AllTime", "folderPath": "%/%", "container": "landing" }', N'', N'{ "fileType": "json", "multiline": false, "compression": "None"}', N'{ "fileName": null, "folderPath": "BeneficialOwnership/OpenData/Contracting/Nigeria/AllTime/", "container": "raw" }', N'', N'', N'', N'PL_2_Process_Landed_Files_Step2', N'TR_blobCreatedEvent', N'{ "dataLoadingBehavior": "Copy_to_Raw", "loadType": "full" }', 0, 1, N'{}', 1, CAST(N'2023-08-29T02:55:29.2773070' AS DateTime2), CAST(N'9999-12-31T23:59:59.9999999' AS DateTime2))

INSERT [dbo].[ControlTable] ([SourceObjectSettings], [SourceConnectionSettingsName], [CopySourceSettings], [SinkObjectSettings], [SinkConnectionSettingsName], [CopySinkSettings], [CopyActivitySettings], [TopLevelPipelineName], [TriggerName], [DataLoadingBehaviorSettings], [TaskId], [CopyEnabled], [DataContract], [PurviewScanEnabled]) VALUES (N'{ "fileName": "Ownership_AllData", "folderPath": "%/%", "container": "landing" }', N'', N'{ "fileType": "json", "multiline": false, "compression": "None"}', N'{ "fileName": null, "folderPath": "BeneficialOwnership/OpenData/Ownership/AllData/", "container": "raw" }', N'', N'', N'', N'PL_2_Process_Landed_Files_Step2', N'TR_blobCreatedEvent', N'{ "dataLoadingBehavior": "Copy_to_Raw", "loadType": "full" }', 0, 1, N'{}', 1, CAST(N'2023-08-29T02:55:00.2143687' AS DateTime2), CAST(N'9999-12-31T23:59:59.9999999' AS DateTime2))

INSERT [dbo].[ControlTable] ([SourceObjectSettings], [SourceConnectionSettingsName], [CopySourceSettings], [SinkObjectSettings], [SinkConnectionSettingsName], [CopySinkSettings], [CopyActivitySettings], [TopLevelPipelineName], [TriggerName], [DataLoadingBehaviorSettings], [TaskId], [CopyEnabled], [DataContract], [PurviewScanEnabled]) VALUES (N'{ "fileName": "Sanctions.json",    "folderPath": "%/%",    "container": "landing" }', N'', N'{ "fileType": "json", "multiline": false, "compression": "None"}', N'{ "fileName": "Sanctions",     "folderPath": "BeneficialOwnership/OpenData/Sanctions/AllData/", 	"container": "raw" }', N'', N'', N'', N'PL_2_Process_Landed_Files_Step2', N'TR_blobCreatedEvent', N'{ "dataLoadingBehavior": "Copy_to_Raw", "loadType": "full" }', 0, 1, N'{}', 1)

INSERT [dbo].[ControlTable] ([SourceObjectSettings], [SourceConnectionSettingsName], [CopySourceSettings], [SinkObjectSettings], [SinkConnectionSettingsName], [CopySinkSettings], [CopyActivitySettings], [TopLevelPipelineName], [TriggerName], [DataLoadingBehaviorSettings], [TaskId], [CopyEnabled], [DataContract], [PurviewScanEnabled]) VALUES (N'{ "Url": "https://oo-register-production.s3-eu-west-1.amazonaws.com/public/exports/statements.latest.jsonl.gz" }', N'', N'{ "fileType": "gz" }', N'{ "fileName": "Ownership_AllData", "folderPath": "BeneficialOwnership/OpenData/Ownership/AllData/", "container": "landing" }', N'', N'', N'', NULL, NULL, N'{ "dataLoadingBehavior": "Copy_to_Landing" }', 0, 1, N'{}', 1)

INSERT [dbo].[ControlTable] ([SourceObjectSettings], [SourceConnectionSettingsName], [CopySourceSettings], [SinkObjectSettings], [SinkConnectionSettingsName], [CopySinkSettings], [CopyActivitySettings], [TopLevelPipelineName], [TriggerName], [DataLoadingBehaviorSettings], [TaskId], [CopyEnabled], [DataContract], [PurviewScanEnabled]) VALUES (N'{ "Url": "https://data.opensanctions.org/datasets/latest/default/entities.ftm.json"}', N'', N'{ "fileType": "json" }', N'{ "fileName": "Sanctions.json", "folderPath": "BeneficialOwnership/OpenData/Sanctions/", "container": "landing" }', N'', N'', N'', NULL, NULL, N'{ "dataLoadingBehavior": "Copy_to_Landing" }', 0, 1, N'{}', 1)

INSERT [dbo].[ControlTable] ([SourceObjectSettings], [SourceConnectionSettingsName], [CopySourceSettings], [SinkObjectSettings], [SinkConnectionSettingsName], [CopySinkSettings], [CopyActivitySettings], [TopLevelPipelineName], [TriggerName], [DataLoadingBehaviorSettings], [TaskId], [CopyEnabled], [DataContract], [PurviewScanEnabled]) VALUES (N'{ "Url": "https://data.open-contracting.org/api/download_export?spider=dominican_republic_api&job_id=929&full=true&suffix=jsonl.gz" }', NULL, N'{ "fileType": "gz" }', N'{ "fileName": "DominicanRepublic_AllTime", "folderPath": "BeneficialOwnership/OpenData/Contracting/DominicanRepublic/AllTime/", "container": "landing" }', NULL, NULL, NULL, NULL, NULL, N'{ "dataLoadingBehavior": "Copy_to_Landing" }', 0, 1, N'{}', 0)

INSERT [dbo].[ControlTable] ([SourceObjectSettings], [SourceConnectionSettingsName], [CopySourceSettings], [SinkObjectSettings], [SinkConnectionSettingsName], [CopySinkSettings], [CopyActivitySettings], [TopLevelPipelineName], [TriggerName], [DataLoadingBehaviorSettings], [TaskId], [CopyEnabled], [DataContract], [PurviewScanEnabled]) VALUES (N'{ "fileName": "DominicanRepublic_AllTime", "folderPath": "%/%", "container": "landing" }', NULL, N'{ "fileType": "json", "multiline": false, "compression": "None"}', N'{ "fileName": null, "folderPath": "BeneficialOwnership/OpenData/Contracting/DominicanRepublic/AllTime/", "container": "raw" }', NULL, NULL, NULL, N'PL_2_Process_Landed_Files_Step2', N'TR_blobCreatedEvent', N'{ "dataLoadingBehavior": "Copy_to_Raw", "loadType": "full" }', 0, 1, N'{}', 0)

END

END
GO
