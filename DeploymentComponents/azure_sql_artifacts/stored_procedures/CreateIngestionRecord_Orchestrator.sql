/* Copyright (c) Microsoft Corporation.
 Licensed under the MIT license. */


CREATE OR ALTER PROCEDURE [dbo].[CreateIngestionRecord_Orchestrator]
@body nvarchar(max)
AS
BEGIN
DECLARE @sourceType NVARCHAR(255) = JSON_VALUE(@body, '$.ConnectionType')
    IF @sourceType = 'Excel'
    BEGIN
        BEGIN TRY
            EXEC [dbo].[usp_CreateIngestionExcel] @body = @body
            PRINT 'usp_CreateIngestionRecordExcel was called successfully'
            -- Additional actions if the Excel stored procedure ran successfully
        END TRY
        BEGIN CATCH
            SELECT 'Error_Message: ' + ERROR_MESSAGE() AS ErrorMessage
            -- Handle the error or perform necessary actions for error cases
        END CATCH
	END
	IF @sourceType = 'Delimited Text'
		BEGIN
			BEGIN TRY
				EXEC [dbo].[usp_CreateIngestionDelimited] @body = @body
				PRINT 'usp_CreateIngestionDelimited was called'
				END TRY
			BEGIN CATCH
				-- Handle the error or perform necessary actions for error cases
				SELECT 'Error_Message: ' + ERROR_MESSAGE() AS ErrorMessage
			END CATCH
		END
	IF @sourceType = 'Parquet'
		BEGIN
			BEGIN TRY
				EXEC [dbo].[usp_CreateIngestionParquet] @body = @body
				PRINT 'usp_CreateIngestionParquet was called'
			END TRY
			BEGIN CATCH
				-- Handle the error or perform necessary actions for error cases
				SELECT 'Error_Message: ' + ERROR_MESSAGE() AS ErrorMessage
			END CATCH
			PRINT 'usp_CreateIngestionParquet was attempted, but did not execute'
		END
	IF @sourceType = 'JSON'
		BEGIN
			BEGIN TRY
				EXEC [dbo].[usp_CreateIngestionJSON] @body = @body
				PRINT 'usp_CreateIngestionJSON was called'
			END TRY
			BEGIN CATCH
				-- Handle the error or perform necessary actions for error cases
				SELECT 'Error_Message: ' + ERROR_MESSAGE() AS ErrorMessage
			END CATCH
		END
	IF @sourceType = 'PDF'
	BEGIN
		BEGIN TRY
			EXEC [dbo].[usp_CreateIngestionPDForImage] @body = @body
			PRINT 'usp_CreateIngestionPDForImage was called'
		END TRY
		BEGIN CATCH
			-- Handle the error or perform necessary actions for error cases
			SELECT 'Error_Message: ' + ERROR_MESSAGE() AS ErrorMessage
		END CATCH
	END
	IF @sourceType = 'AzureSQL'
	BEGIN
		BEGIN TRY
			EXEC [dbo].[usp_CreateIngestionAzureSQL] @body = @body
			PRINT 'usp_CreateIngestionAzureSQL was called'
		END TRY
		BEGIN CATCH
			-- Handle the error or perform necessary actions for error cases
			SELECT 'Error_Message: ' + ERROR_MESSAGE() AS ErrorMessage
		END CATCH
	END
	IF @sourceType = 'Oracle'
	BEGIN
		BEGIN TRY
			EXEC [dbo].[usp_CreateIngestionOracle] @body = @body
			PRINT 'usp_CreateIngestionOracle was called'
		END TRY
		BEGIN CATCH
			-- Handle the error or perform necessary actions for error cases
			SELECT 'Error_Message: ' + ERROR_MESSAGE() AS ErrorMessage
		END CATCH
	END
	IF @sourceType = 'Netezza'
	BEGIN
		BEGIN TRY
			EXEC [dbo].[usp_CreateIngestionNetezza] @body = @body
			PRINT 'usp_CreateIngestionNetezza was called'
		END TRY
		BEGIN CATCH
			-- Handle the error or perform necessary actions for error cases
			SELECT 'Error_Message: ' + ERROR_MESSAGE() AS ErrorMessage
		END CATCH
	END
--Continue this pattern for each source type. The below source types still need to have Stored Procedures
--IF @sourceType = 'Open Contracting'
--BEGIN
--EXEC [dbo].[usp_CreateIngestionRecordOpenData] @body = @body
--END
--IF @sourceType = 'Open Ownership'
--BEGIN
--EXEC [dbo].[usp_CreateIngestionRecordOpenData] @body = @body
--END
--IF @sourceType = 'Open Sanctions'
--BEGIN
--EXEC [dbo].[usp_CreateIngestionRecordOpenData] @body = @body
--END
--IF @sourceType = 'Delta'
--BEGIN
--EXEC [dbo].[usp_CreateIngestionRecordDelta] @body = @body
--END
	--IF @sourceType = 'delta'
	--BEGIN
	--	BEGIN TRY
	--		EXEC [dbo].[usp_CreateIngestiondelta] @body = @body
	--		PRINT 'usp_CreateIngestiondelta was called'
	--	END TRY
	--	BEGIN CATCH
	--		-- Handle the error or perform necessary actions for error cases
	--		SELECT 'Error_Message: ' + ERROR_MESSAGE() AS ErrorMessage
	--	END CATCH
	--END
END
GO