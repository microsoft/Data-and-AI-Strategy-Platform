/* Copyright (c) Microsoft Corporation.
 Licensed under the MIT license. */


SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[IgnoredLandedFiles](
	[filename] [nvarchar](255) NULL,
	[folderpath] [nvarchar](255) NULL,
	[condition] [nvarchar](255) NULL,
	[reason] [nvarchar](1000) NULL
) ON [PRIMARY]
GO