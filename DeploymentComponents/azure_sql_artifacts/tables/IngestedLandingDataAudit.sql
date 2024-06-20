/* Copyright (c) Microsoft Corporation.
 Licensed under the MIT license. */
 /*Acquisition Serivce*/

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[IngestedLandingDataAudit](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[source_filename] [nvarchar](255) NULL,
	[source_folderpath] [nvarchar](1000) NULL,
	[source_file_md5_hash] [nvarchar](1000) NULL,
	[destination_filename] [nvarchar](255) NULL,
	[destination_folderpath] [nvarchar](1000) NULL,
	[ingestion_status] [nvarchar](100) NULL,
	[pipeline_trigger] [nvarchar](255) NULL,
	[event_start_datetime_utc] [datetime2](7) NULL,
	[event_end_datetime_utc] [datetime2](7) NULL,
	[control_table_record_id] int,
	[pipeline_id] [nvarchar](255) NULL,
	[purview_update_status] [nvarchar](50) NULL,
	[purview_update_datetime_utc] [datetime2](7) NULL,
	[ValidFrom] [datetime2](7) GENERATED ALWAYS AS ROW START HIDDEN NOT NULL,
	[ValidTo] [datetime2](7) GENERATED ALWAYS AS ROW END HIDDEN NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY],
	PERIOD FOR SYSTEM_TIME ([ValidFrom], [ValidTo])
) ON [PRIMARY]
WITH
(
SYSTEM_VERSIONING = ON (HISTORY_TABLE = [dbo].[IngestedLandingDataAuditHistory])
)
GO

ALTER TABLE [dbo].[IngestedLandingDataAudit] ADD  CONSTRAINT [DF_IngestedLandingDataAudit_ValidFrom]  DEFAULT (sysutcdatetime()) FOR [ValidFrom]
GO

ALTER TABLE [dbo].[IngestedLandingDataAudit] ADD  CONSTRAINT [DF_IngestedLandingDataAudit_ValidTo]  DEFAULT (CONVERT([datetime2],'9999-12-31 23:59:59.9999999')) FOR [ValidTo]
GO