CREATE TABLE [dbo].[ControlTable] (
	[id] [int] IDENTITY(1,1) NOT NULL,
    [source_id] [int] NULL,
	[raw_filename] [nvarchar](255) NULL,
	[raw_folderpath] [nvarchar](1000) NULL,
	[processed_to_raw_datetime_utc] [datetime2](7) NULL,
    [processed] INT NULL,
    [processed_datetime_utc] [datetime2](7) NULL
    PRIMARY KEY CLUSTERED ([Id] ASC)
);
GO
