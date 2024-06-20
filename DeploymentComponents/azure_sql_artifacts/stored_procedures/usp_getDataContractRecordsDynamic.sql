/* Copyright (c) Microsoft Corporation.
 Licensed under the MIT license. */
 /*Acquisition Serivce*/
CREATE OR ALTER PROCEDURE [dbo].[usp_getDataContractRecordsDynamic]
@PatternType VARCHAR(50),
@ContractID VARCHAR(100)
AS
BEGIN
    -- SET NOCOUNT ON added to prevent extra result sets from
    -- interfering with SELECT statements.
    SET NOCOUNT ON
	IF OBJECT_ID('tempdb..#TMPHandshake') IS NOT NULL
  DROP TABLE #TMPHandshake;

SELECT
t1.DataContractID, t1.DataSourceName,t1.Publisher,t1.CreatedBy,t1.CreatedByDate,t1.Active,t1.ConnectionType,j1.label AS hslabel, j1.value AS hsvalue
INTO #TMPHandshake 
	FROM [dbo].[Handshake] t1
CROSS APPLY OPENJSON(t1.DataAssetTechnicalInformation) WITH (label NVARCHAR(100), value NVARCHAR(100)) AS j1
	WHERE DataContractID = @ContractID
    UNION ALL
    SELECT t2.DataContractID, t2.DataSourceName,t2.Publisher,t2.CreatedBy,t2.CreatedByDate,t2.Active,t2.ConnectionType, j2.label AS hslabel, j2.value AS hsvalue
    FROM [dbo].[Handshake] t2
    CROSS APPLY OPENJSON(t2.SourceTechnicalInformation) WITH (label NVARCHAR(100), value NVARCHAR(100)) AS j2
	WHERE DataContractID = @ContractID;

IF OBJECT_ID('tempdb..#TMP2') IS NOT NULL
    DROP TABLE #TMP2;
SELECT 
 [ContractID]
 --,[SubjectArea]
 --,[SourceSystem]
 --,[PublisherName]
 --,[DataSourceNameSystem]
 --,[DataSourceNameFriendly]
 --,[Description]
 --,[BusinessContact]
 --,[EngineeringContact]
 --,[DataOwner]
 --,[SME] 
--,[Restrictions]
-- ,[Metadata]
-- ,[DataClassificationLevel]
-- ,[CreatedBy]
-- ,[DataSchema]
-- ,[CreatedOnDate]
-- ,[Active]
 ,[Pattern]
-- ,[DataAssetTechnicalInformation]
 ,[label]
 ,[value]
 INTO #TMP2
FROM (
    SELECT *
    FROM DataContract
    CROSS APPLY OPENJSON(DataAssetTechnicalInformation)
    WITH (
        [label] NVARCHAR(100),
        [value] NVARCHAR(MAX)
    ) AS JSONValues
) AS JSONData
WHERE [ContractID]= @ContractID  --only return one record
;
--SELECT * FROM #TMP2
SELECT DISTINCT
T2.ContractID,
    PT.PatternType,
    PT.LabelName,
    PT.Name,
    PT.ColumnType,
    PT.required,
    PT.choices,
    PT.Area,
    PT.Screen,
    PT.Icon,
    PT.DataSourceType,
    PT.DataSourceSystem,
    PT.Description,
    PT.Active,
    PT.visible,
	T3.hslabel,
	T3.hsvalue,
	COALESCE(T2.value, PT.columnValue) AS [value]  --this would remove the null..
FROM PatternTable PT
LEFT JOIN #TMP2 T2
ON PT.LabelName = T2.label
LEFT JOIN #TMPHandshake T3
ON PT.LabelName = T3.hslabel
WHERE PT.PatternType = @PatternType 
END
GO
