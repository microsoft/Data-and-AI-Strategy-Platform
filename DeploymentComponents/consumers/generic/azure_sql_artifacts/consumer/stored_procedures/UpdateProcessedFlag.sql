SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE OR ALTER PROCEDURE [dbo].[UpdateProcessedFlag]
(
    @rowid varchar(10)
)
AS
BEGIN

UPDATE  [dbo].[ControlTable]
SET     [processed] = 1
        , [processed_datetime_utc] = sysdatetime()
WHERE   [id] = @rowid;

END
GO
