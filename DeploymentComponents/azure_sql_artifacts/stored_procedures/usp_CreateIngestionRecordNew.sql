/* Copyright (c) Microsoft Corporation.
 Licensed under the MIT license. */

CREATE OR ALTER PROCEDURE [dbo].[usp_CreateIngestionRecordNew]
(
@DataContractName NVARCHAR(255)
  ,@DataOwnerDisplayName NVARCHAR(255)
  ,@DataOwnerCountry NVARCHAR(255)
  ,@DataOwnerEmail NVARCHAR(255)
  ,@DataSensitivity NVARCHAR(255)
  ,@DelimiterType NVARCHAR(5)
  ,@ExcelSheetName NVARCHAR(255)
  ,@Filename NVARCHAR(255)
  ,@IngestionRunOnSubmit BIT
  ,@IngestionSchedule BIT
  ,@IngestionScheduleRecurrence NVARCHAR(255)
  ,@IngestionScheduleRecurrenceFrequency NVARCHAR(255)
  ,@IngestionScheduleStartDate NVARCHAR(255)
  ,@IngestionScheduleStartTime NVARCHAR(255)
  ,@SinkFileSystem NVARCHAR(255)
  ,@SinkFolderPath NVARCHAR(255)
  ,@SourceContainer NVARCHAR(255)
  ,@SourceFolderPath NVARCHAR(255)
  ,@SourceType NVARCHAR(255)
  ,@contractID NVARCHAR(255)
  ,@TriggerName NVARCHAR(50) = '' --Empty string incase no trigger required
)
AS
BEGIN
DECLARE @query AS NVARCHAR(MAX) = 'DECLARE @MainControlMetadata NVARCHAR(MAX)  = N''[
    {
        "SourceObjectSettings": {
            "fileName": "'+ @FileName +'",
			"folderPath": "' +  @SourceFolderPath +'",
             "container": "' + @SourceContainer +'"
        },
        "SinkObjectSettings": {
            "fileName": "' +@FileName + '",
            "folderPath": "' + @SinkFolderPath +'",
            "fileSystem": "' + @SinkFileSystem + '"
        },
        "CopySourceSettings": {
            "recursive": true,
            "wildcardFileName": "*"
        },
        "CopyActivitySettings": {
            "translator": null,
            "enableSkipIncompatibleRow": false,
            "skipErrorFile": {
                "fileMissing": true,
                "dataInconsistency": false
            }
        },
        "TopLevelPipelineName": "PL_2_Process_Landed_Files_Step2",
        "TriggerName": "TR_blobCreatedEvent",
        "DataLoadingBehaviorSettings": {
            "dataLoadingBehavior": "FullLoad"
        },
        "TaskId": 0,
        "CopyEnabled": 1,
		"DataContract": {
			"DataContractID":"' + @contractID +'",
			"DatContractName": "' + @DataContractName + '",
			"DataOwnerDisplayName" : "' + @DataOwnerDisplayName + '",
			"DataOwnerCountry": "' + @DataOwnerCountry + '",
			"DataOwnerEmail": "' + @DataOwnerEmail + '",
			"DataSensitivity": "' + @DataSensitivity + '",
			"FileName": "' + @Filename + '",
			"DatasetType": "' + @SourceType + '"
		}
    }
]'';
INSERT INTO [dbo].[ControlTable] (
    [SourceObjectSettings],
    [SourceConnectionSettingsName],
    [CopySourceSettings],
    [SinkObjectSettings],
    [SinkConnectionSettingsName],
    [CopySinkSettings],
    [CopyActivitySettings],
    [TopLevelPipelineName],
    [TriggerName],
    [DataLoadingBehaviorSettings],
    [TaskId],
    [CopyEnabled],
	[DataContract])
SELECT * FROM OPENJSON(@MainControlMetadata)
    WITH ([SourceObjectSettings] [nvarchar](max) AS JSON,
    [SourceConnectionSettingsName] [varchar](max),
    [CopySourceSettings] [nvarchar](max) AS JSON,
    [SinkObjectSettings] [nvarchar](max) AS JSON,
    [SinkConnectionSettingsName] [varchar](max),
    [CopySinkSettings] [nvarchar](max) AS JSON,
    [CopyActivitySettings] [nvarchar](max) AS JSON,
    [TopLevelPipelineName] [nvarchar](max),
    [TriggerName] [nvarchar](max) AS JSON,
    [DataLoadingBehaviorSettings] [nvarchar](max) AS JSON,
    [TaskId] [int],
    [CopyEnabled] [bit],
	[DataContract] [nvarchar](max) AS JSON
	)'


EXEC sp_executesql @query,
    N'  @DataContractName NVARCHAR(255)
  ,@DataOwnerCountry NVARCHAR(255)
  ,@DataOwnerDisplayName NVARCHAR(255)
  ,@DataOwnerEmail NVARCHAR(255)
  ,@DataSensitivity NVARCHAR(255)
  ,@DelimiterType NVARCHAR(5)
  ,@ExcelSheetName NVARCHAR(255)
  ,@Filename NVARCHAR(255)
  ,@IngestionRunOnSubmit BIT
  ,@IngestionSchedule BIT
  ,@IngestionScheduleRecurrence NVARCHAR(255)
  ,@IngestionScheduleRecurrenceFrequency NVARCHAR(255)
  ,@IngestionScheduleStartDate NVARCHAR(255)
  ,@IngestionScheduleStartTime NVARCHAR(255)
  ,@SinkFileSystem NVARCHAR(255)
  ,@SinkFolderPath NVARCHAR(255)
  ,@SourceContainer NVARCHAR(255)
  ,@SourceFolderPath NVARCHAR(255)
  ,@SourceType NVARCHAR(255)
  ,@contractID NVARCHAR(255)',
  @DataContractName
  ,@DataOwnerCountry
  ,@DataOwnerDisplayName
  ,@DataOwnerEmail
  ,@DataSensitivity
  ,@DelimiterType
  ,@ExcelSheetName
  ,@Filename
  ,@IngestionRunOnSubmit
  ,@IngestionSchedule
  ,@IngestionScheduleRecurrence
  ,@IngestionScheduleRecurrenceFrequency
  ,@IngestionScheduleStartDate
  ,@IngestionScheduleStartTime
  ,@SinkFileSystem
  ,@SinkFolderPath
  ,@SourceContainer
  ,@SourceFolderPath
  ,@SourceType
  ,@contractID
END
GO
