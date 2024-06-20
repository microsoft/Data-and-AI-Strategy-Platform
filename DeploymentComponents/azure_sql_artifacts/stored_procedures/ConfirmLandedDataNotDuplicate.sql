/* Copyright (c) Microsoft Corporation.
 Licensed under the MIT license. */

-- evaluate comparisons against null to UNKNOWN 
SET ANSI_NULLS ON
GO
-- object identifiers don't have to be in double quotes if they aren't reserved keywords
-- single quotations must be used to enclose literal strings
SET QUOTED_IDENTIFIER ON
GO
-- create/alter ConfirmLandedDataNotDuplicate stored procedure
-- confirm if landed data is a duplicate or not
CREATE OR ALTER PROCEDURE [dbo].[ConfirmLandedDataNotDuplicate]
(
	-- filename parameter for landed data
	@filename NVARCHAR(255),
	-- MD5 hash parameter for landed data
	@md5hash NVARCHAR(1000),
	-- destination path prefix parameter for landed data
	@destination_path_prefix NVARCHAR(1000)
)
AS
BEGIN

-- variable for number of matched rows between landed file and already ingested file 
DECLARE @matched_rows int
-- variable for file status after file comparison 
-- default value is Not Duplicate
DECLARE @file_status varchar(1000) = 'Not Duplicate'

-- Does landed file's MD5 hash match an already ingested file's MD5 hash?
-- lookup is based on the logging table
-- do not match on empty string for MD5 hash
-- returns number of matched rows between files 
SET @matched_rows = (SELECT COUNT(*)
FROM dbo.IngestedLandingDataAudit
WHERE ([source_file_md5_hash] = @md5hash
AND '' != @md5hash)
AND [destination_folderpath] LIKE @destination_path_prefix
)

-- if there are matched rows, mark the landed file as duplicate
IF (cast(@matched_rows as int) > 0)
BEGIN;
	SET @file_status = 'Duplicate';
END;

-- return value for ADF pipeline to use in downstream logic
Select @file_status AS 'file_status'

END
GO
