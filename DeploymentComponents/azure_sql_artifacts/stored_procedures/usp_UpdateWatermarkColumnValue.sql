/* Copyright (c) Microsoft Corporation.
 Licensed under the MIT license. */

USE MetadataControl
GO

CREATE OR ALTER PROCEDURE [dbo].[usp_UpdateWatermarkColumnValue]
    @watermarkValue nvarchar(max),
    @Id [int]
AS
    UPDATE [dbo].[ControlTable]
    SET [CopySourceSettings]=JSON_MODIFY([CopySourceSettings],'$.watermarkValue', @watermarkValue) WHERE Id = @Id
GO