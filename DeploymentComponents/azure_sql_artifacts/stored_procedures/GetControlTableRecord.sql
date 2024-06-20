/* Copyright (c) Microsoft Corporation.
 Licensed under the MIT license. */
/****** Object:  StoredProcedure [dbo].[GetControlTableRecord]    Script Date: 10/25/2023 2:03:50 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

-- create/alter GetControlTableRecord stored procedure
-- check if control table is configured correctly
CREATE OR ALTER PROCEDURE [dbo].[GetControlTableRecord]
(
	-- landed data pipeline name parameter
	@TopLevelPipelineName NVARCHAR(1000),
	-- landed data trigger name parameter
	@TriggerName NVARCHAR(1000),
	-- landed data file name parameter
	@fileName NVARCHAR(1000),
	-- landed data folder path parameter
	@folderPath NVARCHAR(1000),
	-- landed data folder path with container parameter
	@folderPathWithContainer NVARCHAR(1000),
	-- pipeline id parameter
	@pipeline_id NVARCHAR(255)
)
AS
BEGIN
-- variable for number of matched records between the control table and landed data
DECLARE @matchedrecords int
-- variable for number of files to be ignored 
DECLARE @ignored_file int
-- using parameters from data landed in landing zone
-- get number of records in control table relevant to that landed data
-- should be only 1 record
SET @matchedrecords = (
SELECT		COUNT(*)
FROM 		[dbo].[ControlTable]
WHERE 		TopLevelPipelineName=@TopLevelPipelineName
--AND 		TriggerName = @TriggerName
AND			@fileName LIKE JSON_VALUE(SourceObjectSettings, '$.fileName')
AND			@folderPath LIKE JSON_VALUE(SourceObjectSettings, '$.folderPath')
AND			CopyEnabled = 1
)
-- is the file set to be ignored using reference table?
SET @ignored_file = (
SELECT 		COUNT(*)
FROM 		[dbo].[IgnoredLandedFiles]
WHERE		(@fileName LIKE [filename]
AND			condition = 'LIKE'
AND			[folderpath] IS NULL)
OR			(@fileName NOT LIKE [filename]
AND			condition = 'NOT LIKE'
AND			[folderpath] IS NULL)
OR			(@folderpath LIKE [folderpath]
AND			condition = 'LIKE'
AND			[filename] IS NULL)
OR			(@folderpath NOT LIKE [folderpath]
AND			condition = 'NOT LIKE'
AND			[filename] IS NULL)
)
-- if there's no matching control table record and file is NOT set to be ignored
-- throw error as someone just landed data in landing zone and we don't know where to place it in the raw zone
-- this way we can send an alert to an administrator to investigate
IF @matchedrecords = 0 and @ignored_file = 0
BEGIN
	DECLARE @error_message_no_matches varchar(255) = 'File, ' + @fileName + ', was landed in path, ' + @folderPath + ', but does not have an associated control table record.';
	THROW 50001, @error_message_no_matches, 1;
END
-- if there's more than 1 matching record, someone has configured the control table incorrectly
-- throw an error so we can send an alert to an administrator to fix
IF @matchedrecords > 1
BEGIN
	DECLARE @error_message_multiple_matches varchar(255) = 'File, ' + @fileName + ', was landed in path, ' + @folderPath + ', and has more than 1 associated control table records.';
	THROW 50001, @error_message_multiple_matches, 1;
END
DECLARE @run_Id int;
DECLARE @controlTableId int;
SET @controlTableId = (
SELECT		id
FROM 		[dbo].[ControlTable]
WHERE 		TopLevelPipelineName=@TopLevelPipelineName
--AND 		TriggerName = @TriggerName
AND			@fileName LIKE JSON_VALUE(SourceObjectSettings, '$.fileName')
AND			@folderPath LIKE JSON_VALUE(SourceObjectSettings, '$.folderPath')
AND			CopyEnabled = 1
)
EXEC [dbo].[LogDataLandedInLandingZone] @source_filename = @fileName, @source_folderpath = @folderPathWithContainer, @control_table_record_id = @controlTableId, @pipeline_id = @pipeline_id, @run_id = @run_Id OUTPUT; 
-- return control table record for downstream processing in ADF pipeline
SELECT		*, @run_Id [run_Id]
FROM 		[dbo].[ControlTable]
WHERE 		TopLevelPipelineName=@TopLevelPipelineName
--AND 		TriggerName = @TriggerName
AND			@fileName LIKE JSON_VALUE(SourceObjectSettings, '$.fileName')
AND			@folderPath LIKE JSON_VALUE(SourceObjectSettings, '$.folderPath')
AND			CopyEnabled = 1
AND 		@ignored_file = 0
UNION ALL
-- the pipeline is set to ingest only the top record so the below record is only read
-- if file is set to be ignored using reference table. this record needs to be added so 
-- downstream processing in ADF does not fail
-- and we can log that we just received a file set to be ignored
SELECT
0
,'{ "filename": null, "folderPath": null, "container": "landing" }'
,'IGNORED FILE'
,'IGNORED FILE'
,'IGNORED FILE'
,'IGNORED FILE'
,'IGNORED FILE'
,'IGNORED FILE'
,'IGNORED FILE'
,'IGNORED FILE'
,'IGNORED FILE'
,0
,0
,''
,''
,@run_Id
RETURN
END
GO