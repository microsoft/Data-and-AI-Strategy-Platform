/****** Object:  Table [dbo].[DataMapping]    Script Date: 4/4/2023 8:37:27 PM ******/
/******Needs to be in Beneficial Ownership Compute RG******/
/****** Object:  Table [dbo].[DataMapping]    Script Date: 4/4/2023 8:37:27 PM ******/
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
	[sourcePath] [nvarchar](MAX) NOT NULL,
	[mappingJson] [nvarchar](max) NOT NULL,
 CONSTRAINT [PK_Customer] PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
