/****** Object:  Database [StoredProcDB]    Script Date: 4/5/2023 12:52:21 PM ******/
/****** This is necessary in the compute SYNAPSE ******/

CREATE DATABASE [StoredProcDB] 
GO

ALTER DATABASE [StoredProcDB] SET ANSI_NULL_DEFAULT OFF 
GO

ALTER DATABASE [StoredProcDB] SET ANSI_NULLS OFF 
GO

ALTER DATABASE [StoredProcDB] SET ANSI_PADDING OFF 
GO

ALTER DATABASE [StoredProcDB] SET ANSI_WARNINGS OFF 
GO

ALTER DATABASE [StoredProcDB] SET ARITHABORT OFF 
GO

ALTER DATABASE [StoredProcDB] SET CONCAT_NULL_YIELDS_NULL OFF 
GO

ALTER DATABASE [StoredProcDB] SET NUMERIC_ROUNDABORT OFF 
GO

ALTER DATABASE [StoredProcDB] SET QUOTED_IDENTIFIER OFF 
GO



/****** Object:  StoredProcedure [dbo].[schemaDynamic]    Script Date: 4/5/2023 1:00:13 PM ******/
/****** This is necessary in the compute SYNAPSE wtihin the StoredProcDB ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


CREATE OR ALTER PROCEDURE [dbo].[schemaDynamic]
@fileType NVARCHAR(25), @filePath NVARCHAR (1000)
AS
BEGIN
DECLARE @SQLStr nvarchar(max)
IF @fileType = 'PARQUET'
    BEGIN
SET @SQLStr = 
            N'SELECT TOP 1 *																				'+
            N'FROM OPENROWSET(BULK ''https://actstaxdatalakedev60.dfs.core.windows.net'+ @filePath +''',	'+
            N'FORMAT = '''+ @fileType +'''                                                                  '+
            N') AS [result]';
    END
ELSE IF @fileType = 'CSV'
    BEGIN
    SET @SQLStr = 
            N'SELECT TOP 1 *                                                                                   '+
            N'FROM OPENROWSET(BULK ''https://actstaxdatalakedev60.dfs.core.windows.net'+ @filePath +''',       '+
            N'FORMAT = '''+ @fileType +''',                                                                    '+
            N'HEADER_ROW = true,                                                                               '+
            N'PARSER_VERSION = ''2.0''                                                                         '+
            N') AS [result]';
    END
PRINT @SQLStr
EXEC sp_describe_first_result_set @tsql = @SQLStr
END;
GO

/****** This is necessary in the compute SYNAPSE wtihin the StoredProcDB ******/
/****** Object:  StoredProcedure [dbo].[sp_getSynapseTables_Columns]    Script Date: 4/5/2023 1:04:41 PM ******/
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
