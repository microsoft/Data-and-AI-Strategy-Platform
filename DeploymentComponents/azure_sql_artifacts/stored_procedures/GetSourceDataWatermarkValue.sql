/* Copyright (c) Microsoft Corporation.
 Licensed under the MIT license. */
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE OR ALTER PROCEDURE [dbo].[GetSourceDataWatermarkValue]
(
    -- Add the parameters for the stored procedure here
    @control_table_record_id int = null
)
AS
BEGIN
    -- SET NOCOUNT ON added to prevent extra result sets from
    -- interfering with SELECT statements.
    SET NOCOUNT ON

    -- Insert statements for procedure here
    DECLARE @watermark_value nvarchar(255)

	-- Determine number of records in logging table for control table record id
	DECLARE @matchedrecords int

	SET @matchedrecords = (
		SELECT	COUNT(*)
		FROM	[dbo].[IngestedSourceDataAudit]
		WHERE	[control_table_record_id] = @control_table_record_id
		AND		[ingestion_status] = 'Processed'
	)

	--Determine data type of watermark field
	DECLARE @watermark_field_data_type nvarchar(255)
	
	SET @watermark_field_data_type = (
		SELECT	JSON_VALUE([CopySourceSettings], '$.watermark_column_data_type')
		FROM	[dbo].[ControlTable]
		WHERE	[Id] = @control_table_record_id
	)

	--If no matches records, set watermark value to lowest value for dataset type
	IF @matchedrecords = 0
	BEGIN
		IF @watermark_field_data_type = 'Datetime'
		BEGIN
			SET @watermark_value = '1900-01-01 00:00:00'
		END
		ELSE
		BEGIN
			SET @watermark_value = '-1'
		END
	END

	--Otherwise, set it to latest watermark value
	IF @matchedrecords > 0
	BEGIN
		DECLARE @max_watermark_value nvarchar(255)
		IF @watermark_field_data_type = 'Datetime'
		BEGIN
			SET @max_watermark_value = (
				SELECT	MAX(CAST([watermark_value] AS DATETIME2(0)))
				FROM	[dbo].[IngestedSourceDataAudit]
				WHERE	[control_table_record_id] = @control_table_record_id
				AND		[ingestion_status] = 'Processed'
			)
		END
		ELSE
		BEGIN
			SET @max_watermark_value = (
				SELECT	MAX([watermark_value])
				FROM	[dbo].[IngestedSourceDataAudit]
				WHERE	[control_table_record_id] = @control_table_record_id
				AND		[ingestion_status] = 'Processed'
			)
		END

		SET @watermark_value = @max_watermark_value
	END

	--return values for downstream processing
	SELECT @watermark_value [WatermarkValue], @matchedrecords [MatchedRecords]

END
GO
