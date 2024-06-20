/****** Object:  StoredProcedure [dbo].[sp_getSynapseTables_Columns]    Script Date: 5/19/2023 3:12:09 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE OR ALTER PROCEDURE [dbo].[sp_getSynapseTables_Columns] (
    @DatabaseName NVARCHAR(128))
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @SQL NVARCHAR(MAX) = N'SELECT * FROM ' + QUOTENAME(@DatabaseName) + '.INFORMATION_SCHEMA.COLUMNS';

    EXEC sp_executesql @SQL;
END
GO


