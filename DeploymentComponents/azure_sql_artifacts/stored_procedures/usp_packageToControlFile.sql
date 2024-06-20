/* Copyright (c) Microsoft Corporation.
 Licensed under the MIT license. */

CREATE OR ALTER PROCEDURE [dbo].[usp_packageToControlFile]
    @Id INT
AS
BEGIN
    IF OBJECT_ID('tempdb..#TMP') IS NOT NULL
        DROP TABLE #TMP;
    SELECT 
        Handshake.Id,
        Handshake.DataContractID,
        JSON_VALUE(DataAssetTechInfo.[value], '$.label') AS Label,
        JSON_VALUE(DataAssetTechInfo.[value], '$.value') AS Value
    INTO #TMP
    FROM Handshake
    CROSS APPLY OPENJSON(DataAssetTechnicalInformation) DataAssetTechInfo
    WHERE ID = @Id;
    INSERT INTO #TMP (DataContractID, Label, Value)
    SELECT
        DataContractID,
        JSON_VALUE(SourceTechInfo.[value], '$.label') AS Label,
        JSON_VALUE(SourceTechInfo.[value], '$.value') AS Value
    FROM Handshake
    CROSS APPLY OPENJSON(SourceTechnicalInformation) SourceTechInfo
    WHERE ID = @Id;
    INSERT INTO #TMP (DataContractID, Label, Value)
    SELECT
        DataContractID,
        'ScheduleFrequency' AS Label,
        JSON_VALUE(Schedule.[value], '$.IngestionScheduleFrequencyRecurrenceValue') AS Value
    FROM Handshake
    CROSS APPLY OPENJSON(Handshake.IngestionSchedule) Schedule
    WHERE ID = @Id;
    INSERT INTO #TMP (DataContractID, Label, Value)
    SELECT
        DataContractID,
        'ScheduleTriggerName' AS Label,
        JSON_VALUE(Schedule.[value], '$.IngestionSceheduleTriggerName') AS Value
    FROM Handshake
    CROSS APPLY OPENJSON(Handshake.IngestionSchedule) Schedule
    WHERE ID = @Id;
    INSERT INTO #TMP (DataContractID, Label, Value)
    SELECT
        DataContractID,
        'ScheduleActive' AS Label,
        JSON_VALUE(Schedule.[value], '$.IngestionSchedule') AS Value
    FROM Handshake
    CROSS APPLY OPENJSON(Handshake.IngestionSchedule) Schedule
    WHERE ID = @Id;
    INSERT INTO #TMP (DataContractID, Label, Value)
    SELECT
        DataContractID,
        'ScheduleRecurrence' AS Label,
        JSON_VALUE(Schedule.[value], '$.IngestionScheduleFrequencyRecurrence') AS Value
    FROM Handshake
    CROSS APPLY OPENJSON(Handshake.IngestionSchedule) Schedule
    WHERE ID = @Id;
    INSERT INTO #TMP (DataContractID, Label, Value)
    SELECT
        DataContractID,
        'ScheduleRunOnSubmit' AS Label,
        JSON_VALUE(Schedule.[value], '$.IngestionScheduleRunOnSubmit') AS Value
    FROM Handshake
    CROSS APPLY OPENJSON(Handshake.IngestionSchedule) Schedule
    WHERE ID = @Id;
    INSERT INTO #TMP (DataContractID, Label, Value)
    SELECT
        DataContractID,
        'ScheduleStartDate' AS Label,
        JSON_VALUE(Schedule.[value], '$.IngestionScheduleStartDate') AS Value
    FROM Handshake
    CROSS APPLY OPENJSON(Handshake.IngestionSchedule) Schedule
    WHERE ID = @Id;
    INSERT INTO #TMP (DataContractID, Label, Value)
    SELECT
        DataContractID,
        'ScheduleStartTime' AS Label,
        JSON_VALUE(Schedule.[value], '$.IngestionScheduleStartTime') AS Value
    FROM Handshake
    CROSS APPLY OPENJSON(Handshake.IngestionSchedule) Schedule
    WHERE ID = @Id;
	INSERT INTO #TMP (DataContractID, Label, Value)
    SELECT
        DataContractID,
        'dynamicSinkPath' AS Label,
        [dynamicSinkPath] AS Value
    FROM Handshake
    WHERE ID = @Id;
	INSERT INTO #TMP (DataContractID, Label, Value)
    SELECT
        DataContractID,
        'SourceFolderPath' AS Label,
        [SourceFolderPath] AS Value
    FROM Handshake
    WHERE ID = @Id;
	INSERT INTO #TMP (DataContractID, Label, Value)
    SELECT
        DataContractID,
        'ConnectionType' AS Label,
        [ConnectionType] AS Value
    FROM Handshake
    WHERE ID = @Id;
    -- Pivot the data dynamically
    DECLARE @PivotColumns NVARCHAR(MAX);
    DECLARE @Sql NVARCHAR(MAX);
    -- Generate the dynamic list of pivot columns
    SET @PivotColumns = STUFF(
        (
            SELECT DISTINCT ',' + QUOTENAME(Label)
            FROM #TMP
            FOR XML PATH(''), TYPE
        ).value('.', 'NVARCHAR(MAX)'),
        1, 1, ''
    );
    -- Prepare the dynamic pivot query
    SET @Sql = '
        SELECT DataContractID, ' + @PivotColumns + '
        FROM (
            SELECT DataContractID, Label, Value
            FROM #TMP
        ) AS Source
        PIVOT (
            MAX(Value)
            FOR Label IN (' + @PivotColumns + ')
        ) AS PivotTable;
    ';
    -- Execute the dynamic pivot query
    EXEC sp_executesql @Sql;
    ---Clean up and set the sent to process value to true so the next query will not reprocess
	UPDATE [dbo].[Handshake]
	    SET [sentToProcess] = 1
	    WHERE ID = @Id;
    DROP TABLE #TMP;
END;
GO
