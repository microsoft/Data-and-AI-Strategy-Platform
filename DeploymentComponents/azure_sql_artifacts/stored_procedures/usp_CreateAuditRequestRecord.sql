/* Copyright (c) Microsoft Corporation.
 Licensed under the MIT license. */

CREATE OR ALTER PROCEDURE [dbo].[usp_CreateAuditRequestRecord]
(
    @HttpRequest NVARCHAR(MAX)
    ,@AuditMessage NVARCHAR(255)
    ,@MetaDataInserted BIT
)
AS
BEGIN
INSERT INTO IngestionServiceAudit (HttpRequest, AuditMessage, MetaDataInserted)
VALUES (@HttpRequest, @AuditMessage, @MetaDataInserted)
END
GO