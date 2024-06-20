/* Copyright (c) Microsoft Corporation.
 Licensed under the MIT license. */
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE OR ALTER PROCEDURE [dbo].[LogDataFromSource]
(
    -- Add the parameters for the stored procedure here
    @id_to_update int = NULL,
	@source NVARCHAR(max) = NULL,
	@destination_filename NVARCHAR(255) = NULL,
	@destination_folderpath NVARCHAR(1000) = NULL,
	@ingestion_status NVARCHAR(255) = NULL,
	@pipeline_trigger NVARCHAR(255) = NULL,
	@control_table_record_id int = NULL,
	@pipeline_id NVARCHAR(255) = NULL,
	@watermark_value NVARCHAR(255) = NULL,
	@rows_copied_count BIGINT = NULL,
	@run_Id int = null
)
AS
BEGIN
    -- SET NOCOUNT ON added to prevent extra result sets from
    -- interfering with SELECT statements.
    SET NOCOUNT ON

    -- Insert statements for procedure here
    DECLARE @logging_table_id int

	IF @id_to_update IS NULL
	BEGIN
		DECLARE @insert_table table (logging_table_id int)

		INSERT INTO [dbo].[IngestedSourceDataAudit] (
		 [ingestion_status]
		,[pipeline_trigger]
		,[event_start_datetime_utc]
		,[control_table_record_id]
		,[pipeline_id] 
		,[source]
		)
		OUTPUT inserted.id INTO @insert_table
		VALUES (
		'Started'
		,@pipeline_trigger
		,SYSUTCDATETIME()
		,@control_table_record_id
		,@pipeline_id
		,@source
		)

		SET @logging_table_id = (SELECT logging_table_id FROM @insert_table)
	END

	IF @ingestion_status = 'Processed'
	BEGIN
		UPDATE	[dbo].[IngestedSourceDataAudit]
		SET		[source] = @source
				,[destination_filename] = @destination_filename
				,[destination_folderpath] = @destination_folderpath
				,[ingestion_status] = @ingestion_status
				,[event_end_datetime_utc] = SYSUTCDATETIME()
				,[watermark_value] = @watermark_value
				,[rows_copied_count] = @rows_copied_count
		WHERE	[id] = @id_to_update

				
	END

	IF @ingestion_status = 'Failed'
	BEGIN
		UPDATE	[dbo].[IngestedSourceDataAudit]
		SET		[ingestion_status] = @ingestion_status
				,[event_end_datetime_utc] = SYSUTCDATETIME()
		WHERE	[id] = @id_to_update
	END

	SELECT @logging_table_id [logging_table_id]
	RETURN

END
GO
