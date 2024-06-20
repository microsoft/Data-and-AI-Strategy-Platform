/* Copyright (c) Microsoft Corporation.
 Licensed under the MIT license. */
 /*Acquisition Serivce*/

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[IngestedSourceDataAudit](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[source] [nvarchar](max) NULL,
	[destination_filename] [nvarchar](255) NULL,
	[destination_folderpath] [nvarchar](1000) NULL,
	[ingestion_status] [nvarchar](100) NULL,
	[pipeline_trigger] [nvarchar](255) NULL,
	[event_start_datetime_utc] [datetime2](7) NULL,
	[event_end_datetime_utc] [datetime2](7) NULL,
	[control_table_record_id] int NULL,
	[pipeline_id] [nvarchar](255) NULL,
	[watermark_value] [nvarchar](255) NULL,
	[rows_copied_count] [bigint] NULL,
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
SYSTEM_VERSIONING = ON (HISTORY_TABLE = [dbo].[IngestedSourceDataAuditHistory])
)
GO

ALTER TABLE [dbo].[IngestedSourceDataAudit] ADD  CONSTRAINT [DF_IngestedSourceDataAudit_ValidFrom]  DEFAULT (sysutcdatetime()) FOR [ValidFrom]
GO

ALTER TABLE [dbo].[IngestedSourceDataAudit] ADD  CONSTRAINT [DF_IngestedSourceDataAudit_ValidTo]  DEFAULT (CONVERT([datetime2],'9999-12-31 23:59:59.9999999')) FOR [ValidTo]
GO
