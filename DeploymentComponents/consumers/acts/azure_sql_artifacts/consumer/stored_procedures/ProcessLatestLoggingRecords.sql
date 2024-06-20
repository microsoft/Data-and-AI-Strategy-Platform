SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE OR ALTER PROCEDURE [dbo].[ProcessLatestLoggingRecords]
AS
BEGIN

INSERT INTO  [dbo].[ControlTable]
(
    [source_id]
	,[raw_filename]
	,[raw_folderpath]
	,[processed_to_raw_datetime_utc]
)
SELECT  [id]
	    ,[destination_filename]
	    ,[destination_folderpath]
	    ,[event_end_datetime_utc]
FROM    [dbo].[IngestedLandingDataAudit]

TRUNCATE TABLE [dbo].[IngestedLandingDataAudit];

END
GO