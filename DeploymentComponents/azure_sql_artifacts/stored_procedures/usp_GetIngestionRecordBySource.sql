/* Copyright (c) Microsoft Corporation.
 Licensed under the MIT license. */

CREATE OR ALTER PROCEDURE usp_GetIngestionRecordBySource
(
    @SourceFolderPath NVARCHAR(255)
    ,@SourceContainerName NVARCHAR(50)
)
AS
BEGIN

SELECT  Id
FROM    ControlTable
WHERE   JSON_VALUE(SourceObjectSettings, '$.folderPath') = @SourceFolderPath
    AND JSON_VALUE(SourceObjectSettings, '$.container') = @SourceContainerName
RETURN;
END
GO
