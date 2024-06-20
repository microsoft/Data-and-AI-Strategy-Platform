/* Copyright (c) Microsoft Corporation.
 Licensed under the MIT license. */

-- evaluate comparisons against null to UNKNOWN 
SET ANSI_NULLS ON
GO
-- object identifiers don't have to be in double quotes if they aren't reserved keywords
-- single quotations must be used to enclose literal strings
SET QUOTED_IDENTIFIER ON
GO
-- create/alter FIFO_Status stored procedure
-- check first in first out (FIFO) status of landed data 
CREATE OR ALTER PROCEDURE [dbo].[FIFO_Status]
(
	-- control table record id parameter
	@control_table_record_id int,
	-- logging table record id parameter 
	@logging_table_record_id int
)
AS
BEGIN

-- track process continuation variable
-- default value is no
DECLARE @continue_processing nvarchar(255) = 'No'
-- first record timestamp variable
DECLARE @first_record datetime2
-- current record timestamp variable
DECLARE @current_record datetime2

-- set first_record as first record in landed data by timestamp and ingestion start status
set @first_record = (
	SELECT		min(event_start_datetime_utc) [first]
	FROM 		[dbo].[IngestedLandingDataAudit]
	WHERE		ingestion_status = 'Started'
	AND			DATEDIFF(hour, event_start_datetime_utc, GETUTCDATE()) <= 2
	AND 		control_table_record_id = @control_table_record_id
	GROUP BY	control_table_record_id
)

-- set current_record as current data by logging table record id 
set @current_record = (
	SELECT		event_start_datetime_utc [current]
	FROM 		[dbo].[IngestedLandingDataAudit]
	WHERE		id = @logging_table_record_id
)

-- if first_record and current_record are the same, change @continue_processing status to yes
-- FIFO status confirmed
IF 	@first_record = @current_record
BEGIN
SET @continue_processing = 'Yes'
END

-- else do not continue processing and return variable 
SELECT	@continue_processing [continue_processing]
RETURN

END
GO