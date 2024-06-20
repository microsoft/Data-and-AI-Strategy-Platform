SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE OR ALTER PROCEDURE [dbo].[usp_InsertDataMapping2]

    @JsonData NVARCHAR(MAX)
AS
BEGIN
    DECLARE @mapping NVARCHAR(255) = (
        SELECT TOP 1 mapping
        FROM OPENJSON(@JsonData)
        WITH (
            mapping NVARCHAR(255) '$.mapping'
        )
    )

    DECLARE @mappingJson NVARCHAR(MAX) = (
        SELECT 
            @mapping AS [type],
            (
                SELECT source, sink
                FROM OPENJSON(@JsonData)
                WITH (
                    source NVARCHAR(255) '$.source',
                    sink NVARCHAR(255) '$.sink'
                )
                FOR JSON PATH
            ) AS [mappings]
        FOR JSON PATH, WITHOUT_ARRAY_WRAPPER
    )

    INSERT INTO [dbo].[DataMapping] (TimeStamp, sink, sinkDataType, sinkOrdinal, sinkdbName, sinkdbSchema, sinkdbTableName, source, sourceCTId, sourceDatatype, sourceFileName, sourceOrdinal, sourcePath, mappingJson)
    SELECT TimeStamp, sink, sinkDataType, sinkOrdinal, sinkdbName, sinkdbSchema, sinkdbTableName, source, sourceCTId, sourceDatatype, sourceFileName, sourceOrdinal, sourcePath,@mappingJson
    FROM OPENJSON(@JsonData)
    WITH (
        TimeStamp DATETIME2 '$.TimeStamp',
        mapping NVARCHAR(255) '$.mapping',
        sink NVARCHAR(255) '$.sink',
        sinkDataType NVARCHAR(255) '$.sinkDataType',
        sinkOrdinal INT '$.sinkOrdinal',
        sinkdbName NVARCHAR(255) '$.sinkdbName',
        sinkdbSchema NVARCHAR(255) '$.sinkdbSchema',
        sinkdbTableName NVARCHAR(255) '$.sinkdbTableName',
        source NVARCHAR(255) '$.source',
        sourceCTId INT '$.sourceCTId',
        sourceDatatype NVARCHAR(255) '$.sourceDatatype',
        sourceFileName NVARCHAR(255) '$.sourceFileName',
        sourceOrdinal INT '$.sourceOrdinal',
        sourcePath NVARCHAR(MAX) '$.sourcePath'
    )
END
GO