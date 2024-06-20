SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[DataMapping](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[TimeStamp] [datetime2](7) NOT NULL,
	[sink] [nvarchar](255) NOT NULL,
	[sinkDataType] [nvarchar](255) NOT NULL,
	[sinkOrdinal] [int] NOT NULL,
	[sinkdbName] [nvarchar](255) NOT NULL,
	[sinkdbSchema] [nvarchar](255) NOT NULL,
	[sinkdbTableName] [nvarchar](255) NOT NULL,
	[source] [nvarchar](255) NOT NULL,
	[sourceCTId] [int] NOT NULL,
	[sourceDatatype] [nvarchar](255) NOT NULL,
	[sourceFileName] [nvarchar](255) NOT NULL,
	[sourceOrdinal] [int] NOT NULL,
	[sourcePath] [nvarchar](max) NOT NULL,
	[mappingJson] [nvarchar](max) NOT NULL,
	[active] [bit] NULL,
	[activeDate] [datetime2](7) NULL,
	[inactiveDate] [datetime2](7) NULL,
	[businessUseCase] [nvarchar](500) NULL,
	[CreatedBy] [nvarchar](100) NULL,
	[CreatedByEmail] [nvarchar](500) NULL,
	[CreatedByUPN] [nvarchar](100) NULL,
	[CreatedById] [nvarchar](100) NULL,
 CONSTRAINT [PK_Customer] PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO

ALTER TABLE [dbo].[DataMapping] ADD  DEFAULT (NULL) FOR [active]
GO

ALTER TABLE [dbo].[DataMapping] ADD  DEFAULT (getdate()) FOR [activeDate]
GO

ALTER TABLE [dbo].[DataMapping] ADD  DEFAULT (getdate()) FOR [inactiveDate]
GO