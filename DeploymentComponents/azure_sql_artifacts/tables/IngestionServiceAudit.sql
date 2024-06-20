/* Copyright (c) Microsoft Corporation.
 Licensed under the MIT license. */


CREATE TABLE dbo.IngestionServiceAudit (
    Id INT IDENTITY(1,1)
    ,LogDateTime DATETIME DEFAULT GETDATE()
    ,HttpRequest NVARCHAR(MAX)
    ,AuditMessage NVARCHAR(255)
    ,MetaDataInserted BIT
);
GO

