/* Copyright (c) Microsoft Corporation.
 Licensed under the MIT license. */
 /*Acquisition Serivce*/

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[DataContract](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[ContractID] [nvarchar](255) NOT NULL,
	[SubjectArea] [nvarchar](255) NOT NULL,
	[SourceSystem] [nvarchar](255) NOT NULL,
	[PublisherName] [nvarchar](255) NOT NULL,
	[DataSourceNameSystem] [nvarchar](255) NOT NULL,
	[DataSourceNameFriendly] [nvarchar](255) NOT NULL,
	[Description] [nvarchar](1000) NOT NULL,
	[BusinessContact] [nvarchar](255) NOT NULL,
	[BusinessContactEmail] [nvarchar](500) NOT NULL,
	[BusinessContactUPN] [nvarchar](255) NOT NULL,
	[BusinessContactObjID] [nvarchar](255) NOT NULL,
	[EngineeringContact] [nvarchar](255) NOT NULL,
	[EngineeringContactEmail] [nvarchar](500) NOT NULL,
	[EngineeringContactUPN] [nvarchar](255) NOT NULL,
	[EngineeringContactObjID] [nvarchar](255) NOT NULL,
	[DataOwner] [nvarchar](255) NOT NULL,
	[DataOwnerEmail] [nvarchar](500) NOT NULL,
	[DataOwnerUPN] [nvarchar](255) NOT NULL,
	[DataOwnerObjID] [nvarchar](255) NOT NULL,
	[SME] [nvarchar](max) NULL,
	[Restrictions] [nvarchar](255) NULL,
	[Metadata] [nvarchar](255) NOT NULL,
	[DataClassificationLevel] [nvarchar](255) NOT NULL,
	[CreatedBy] [nvarchar](255) NOT NULL,
	[CreatedByEmail] [nvarchar](500) NOT NULL,
	[CreatedByUPN] [nvarchar](255) NOT NULL,
	[CreatedById] [nvarchar](255) NOT NULL,
	[DataSchema] [nvarchar](max) NULL,
	[CreatedOnDate] [datetime2](7) NOT NULL,
	[Active] [bit] NOT NULL,
	[ActiveDate] [datetime2](7) NOT NULL,
	[InactiveDate] [datetime2](7) NOT NULL,
	[ControlTableID] [int] NULL,
	[Pattern] [nvarchar](255) NOT NULL,
	[EditedBy] [nvarchar](255) NULL,
	[EditedByEmail] [nvarchar](500) NULL,
	[EditedById] [nvarchar](255) NULL,
	[EditedByUPN] [nvarchar](255) NULL,
	[DataAssetTechnicalInformation] [nvarchar](max) NULL,
	[hsActive] [bit] NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
ALTER TABLE [dbo].[DataContract] ADD PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
