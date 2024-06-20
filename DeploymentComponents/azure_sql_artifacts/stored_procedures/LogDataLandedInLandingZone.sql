/* Copyright (c) Microsoft Corporation.
 Licensed under the MIT license. */


SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE OR ALTER PROCEDURE [dbo].[LogDataLandedInLandingZone]
(
	@id_to_update int = NULL,
	@source_filename NVARCHAR(255),
	@source_folderpath NVARCHAR(1000),
	@source_file_md5_hash NVARCHAR(1000) = NULL,
	@ignoredStatus NVARCHAR(255) = NULL,
	@duplicateStatus NVARCHAR(255) = NULL,
	@destination_filename NVARCHAR(255) = NULL,
	@destination_folderpath NVARCHAR(1000) = NULL,
	@ingestion_status NVARCHAR(255) = NULL,
	@pipeline_trigger NVARCHAR(255) = NULL,
	@control_table_record_id int = NULL,
	@pipeline_id NVARCHAR(255) = NULL,
	@run_Id int = null OUTPUT
)
AS
BEGIN
IF @duplicateStatus = 'Duplicate'
BEGIN
SET @ingestion_status = 'Not Processed, File was Previously Processed'
END
IF @ignoredStatus = 'IGNORED FILE'
BEGIN
SET @ingestion_status = 'Not Processed, File was Ignored'
END

DECLARE @logging_table_id int

IF @id_to_update IS NULL
BEGIN
		DECLARE @insert_table table (logging_table_id int)

		INSERT INTO [dbo].[IngestedLandingDataAudit] (
			[source_filename]
			,[source_folderpath]
			,[ingestion_status]
			,[event_start_datetime_utc]
			,[control_table_record_id]
			,[pipeline_id]
		)
		OUTPUT inserted.id INTO @insert_table
		VALUES (
			@source_filename
			,@source_folderpath
			,'Started'
			,SYSUTCDATETIME()
			,@control_table_record_id
			,@pipeline_id
		)

		SET @logging_table_id = (SELECT logging_table_id FROM @insert_table)

END
IF @ingestion_status = 'Processed' OR @ingestion_status LIKE 'Not Processed%'
BEGIN
		UPDATE [dbo].[IngestedLandingDataAudit]
		SET source_file_md5_hash = @source_file_md5_hash
			,destination_filename = @destination_filename
			,destination_folderpath = @destination_folderpath
			,ingestion_status = @ingestion_status
			,pipeline_trigger = @pipeline_trigger
			,event_end_datetime_utc = SYSUTCDATETIME()
		WHERE id = COALESCE(@id_to_update,@logging_table_id)
END
IF @ingestion_status = 'Failed'
BEGIN
		UPDATE [dbo].[IngestedLandingDataAudit]
		SET ingestion_status = @ingestion_status
			,pipeline_trigger = @pipeline_trigger
			,event_end_datetime_utc = SYSUTCDATETIME()
		WHERE pipeline_id = @pipeline_id
END

SELECT @run_Id = @logging_table_id
RETURN

END
GO
