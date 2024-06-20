/* Copyright (c) Microsoft Corporation.
 Licensed under the MIT license. */

CREATE OR ALTER PROCEDURE [dbo].[usp_InsertPatternParameters]
    @jsonData nvarchar(MAX)
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @active bit = 1;
    
    INSERT INTO [dbo].[PatternTable] (
        PatternType,
		LabelName,
		Name,
		ColumnType,
		required,
		choices,
		Area,
		Screen,
		Icon,
		DataSourceType,
		DataSourceSystem,
		Description,
        Active,
		visible,
		columnValue
    )
    SELECT 
        PatternType,
		LabelName,
		Name,
		ColumnType,
		required,
		choices,
		Area,
		Screen,
		Icon,
		DataSourceType,
		DataSourceSystem,
		Description,
        @active,
		visible,
		columnValue
        
    FROM OPENJSON(@jsonData)
    WITH (
        PatternType nvarchar(255) '$.PatternType',
		LabelName nvarchar(255) '$.LabelName',
		[Name] nvarchar(255) '$.Name',
		ColumnType nvarchar(255) '$.ColumnType',
		[required] nvarchar(255) '$.Required',
		choices nvarchar(255) '$.Choices',
		Area nvarchar(255) '$.Area',
		Screen nvarchar(255) '$.Screen',
		Icon nvarchar(255) '$.Icon',
		DataSourceType nvarchar(255) '$.DataSourceType',
		DataSourceSystem nvarchar(255) '$.DataSourceSystem',
		[Description] nvarchar(255) '$.Description',
		Visible nvarchar(255) '$.Visible',
		ColumnValue nvarchar(255) '$.ColumnValue'
    );
    
END
GO