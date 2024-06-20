/* Copyright (c) Microsoft Corporation.
 Licensed under the MIT license. */
 /*Acquisition Serivce*/
CREATE OR ALTER PROCEDURE [dbo].[GetHandshakeData]
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @TempHandshake TABLE
    (
        Id INT,
        DataContractID NVARCHAR(200),
        ConcatenatedData NVARCHAR(MAX)
    );
    BEGIN TRY
        INSERT INTO @TempHandshake (Id, DataContractID, ConcatenatedData)
        SELECT 
            H.Id,
            H.DataContractID,
            CONCAT(
                STUFF(
                    (
                        SELECT 
                            ', ' + CONCAT('\"', JSON_VALUE(TechInfo.[value], '$.label'), '\": \"', JSON_VALUE(TechInfo.[value], '$.value'), '\"')
                        FROM Handshake T
                        CROSS APPLY OPENJSON(T.DataAssetTechnicalInformation) TechInfo
                        WHERE T.Id = H.Id
                        FOR XML PATH('')
                    ), 1, 2, ''
                ),
                ', ',
                STUFF(
                    (
                        SELECT 
                            ', ' + CONCAT('\"', JSON_VALUE(TechInfo.[value], '$.label'), '\": \"', JSON_VALUE(TechInfo.[value], '$.value'), '\"')
                        FROM Handshake T
                        CROSS APPLY OPENJSON(T.SourceTechnicalInformation) TechInfo
                        WHERE T.Id = H.Id
                        FOR XML PATH('')
                    ), 1, 2, ''
                ),
                ', ',
                STUFF(
                    (
                        SELECT 
                            ', ' + CONCAT('\"', JSON_VALUE(Schedule.[key], '$'), '\": \"', JSON_VALUE(Schedule.[value], '$'), '\"')
                        FROM Handshake T
                        CROSS APPLY OPENJSON(T.IngestionSchedule) Schedule
                        WHERE T.Id = H.Id
                        FOR XML PATH('')
                    ), 1, 2, ''
                )
            )
        FROM Handshake H;
    END TRY
    BEGIN CATCH
        INSERT INTO @TempHandshake (Id, DataContractID, ConcatenatedData)
        SELECT 
            H.Id,
            H.DataContractID,
            NULL AS ConcatenatedData
        FROM Handshake H;
    END CATCH
    -- Retrieve the concatenated data
    SELECT 
        Id,
        DataContractID,
        CONCAT('{', ISNULL(ConcatenatedData, ''), '}') AS ConcatenatedData
    FROM @TempHandshake;
END
GO
