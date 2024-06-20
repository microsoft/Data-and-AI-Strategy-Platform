/* Copyright (c) Microsoft Corporation.
 Licensed under the MIT license. */
 /*Acquisition Serivce*/
CREATE OR ALTER PROCEDURE [dbo].[usp_InsertHandshake]
    @jsondata NVARCHAR(MAX)
AS
BEGIN
    DECLARE @ContractID VARCHAR(36)

    SELECT @ContractID = [DataContractID]
    FROM OPENJSON(@jsonData)
    WITH (
        [DataContractID] VARCHAR(36)
    );

    IF EXISTS (SELECT 1 FROM [dbo].[Handshake] WHERE [DataContractID] = @ContractID)
	
    BEGIN
        UPDATE [dbo].[Handshake]
        SET 
            [DataSourceName] = JSON_VALUE(@jsonData, '$.DataSourceName'),
            [Publisher] = JSON_VALUE(@jsonData, '$.PublisherName'),
            [EditedBy] = JSON_VALUE(@jsonData, '$.CreatedBy'),
            [EditedByDate] = GETDATE(),
            [DataAssetTechnicalInformation] = JSON_QUERY(@jsonData, '$.DataAssetTechnicalInformation'),
            [SourceTechnicalInformation] = JSON_QUERY(@jsonData, '$.SourceTechnicalInformation'),
            [ConnectionType] = JSON_VALUE(@jsonData, '$.ConnectionType'),
            [IngestionSchedule] = JSON_QUERY(@jsonData, '$.IngestionSchedule'),
			[dynamicSinkPath] = JSON_VALUE(@jsonData, '$.dynamicSinkPath'),
			[SourceFolderPath] = JSON_VALUE(@jsonData, '$.SourceFolderPath')
        WHERE 
            [DataContractID] = @ContractID;
			print JSON_VALUE(@jsonData, '$.DataSourceName')
    END
    ELSE
    BEGIN
        INSERT INTO [dbo].[Handshake] (
            [DataSourceName],
            [Publisher],
            [CreatedBy],
            [CreatedByDate],
            [EditedBy],
            [EditedByDate],
            [Active],
            [ActiveDate],
            [InactiveDate],
            [DataAssetTechnicalInformation],
            [SourceTechnicalInformation],
            [ConnectionType],
            [IngestionSchedule],
			[dynamicSinkPath],
			[SourceFolderPath],
			[DataContractID]
        )
        SELECT
            JSON_VALUE(@jsonData, '$.DataSourceName') AS DataSourceName,
            JSON_VALUE(@jsonData, '$.PublisherName') AS Publisher,
            JSON_VALUE(@jsonData, '$.CreatedBy') AS CreatedBy,
            GETDATE() AS CreatedByDate,
            NULL AS EditedBy,
            NULL AS EditedByDate,
            1 AS Active,
            GETDATE() AS ActiveDate,
            NULL AS InactiveDate,
			JSON_QUERY(@jsonData, '$.DataAssetTechnicalInformation') AS DataAssetTechnicalInformation,
			JSON_QUERY(@jsonData, '$.SourceTechnicalInformation') AS SourceTechnicalInformation,
			JSON_VALUE(@jsonData, '$.ConnectionType') AS ConnectionType,
			JSON_QUERY(@jsonData, '$.IngestionSchedule') AS IngestionSchedule,
			JSON_VALUE(@jsonData, '$.dynamicSinkPath') AS dynamicSinkPath,
			JSON_VALUE(@jsonData, '$.SourceFolderPath') AS SourceFolderPath,
			@ContractID
        FROM OPENJSON(@jsonData)
        WITH (
			[DataSourceName] VARCHAR(100),
			[PublisherName] VARCHAR(100),
			[CreatedBy] VARCHAR(100),
			[DataAssetTechnicalInformation] NVARCHAR(MAX) AS JSON,
			[SourceTechnicalInformation] NVARCHAR(MAX) AS JSON,
			[ConnectionType] VARCHAR(100),
			[IngestionSchedule] NVARCHAR(MAX) AS JSON,
			[dynamicSinkPath] VARCHAR(1000),
			[SourceFolderPath] VARCHAR(1000)
        );
    END

    -- Update the value in a DataContract table based on ContractID for Handshake
    UPDATE dbo.DataContract
    SET hsActive = 1  --updated - 01-19-24 was Active
    WHERE ContractID = @ContractID;
END
GO