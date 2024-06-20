/* Copyright (c) Microsoft Corporation.
 Licensed under the MIT license. */
 /*Acquisition Serivce*/

CREATE OR ALTER PROCEDURE [dbo].[usp_EditDataContract]
    @jsonBody nvarchar(MAX)
AS
BEGIN
    SET NOCOUNT ON;
    UPDATE DataContract
    SET
        
		SubjectArea = JSON_VALUE(@jsonBody, '$.SubjectArea'),
        SourceSystem = JSON_VALUE(@jsonBody, '$.SourceSystem'),
        PublisherName = JSON_VALUE(@jsonBody, '$.PublisherName'),
        DataNameSystem = JSON_VALUE(@jsonBody, '$.DataNameSystem'),
        DataNameFriendly = JSON_VALUE(@jsonBody, '$.DataNameFriendly'),
        [Description] = JSON_VALUE(@jsonBody, '$.[Description]'),
        BusinessContact = JSON_VALUE(@jsonBody, '$.BusinessContact'),
        BusinessContactEmail = JSON_VALUE(@jsonBody, '$.BusinessContactEmail'),
        BusinessContactUPN = JSON_VALUE(@jsonBody, '$.BusinessContactUPN'),
        BusinessContactObjID = JSON_VALUE(@jsonBody, '$.BusinessContactObjID'),
        EngineeringContact = JSON_VALUE(@jsonBody, '$.EngineeringContact'),
        EngineeringContactEmail = JSON_VALUE(@jsonBody, '$.EngineeringContactEmail'),
        EngineeringContactUPN = JSON_VALUE(@jsonBody, '$.EngineeringContactUPN'),
        EngineeringContactObjID = JSON_VALUE(@jsonBody, '$.EngineeringContactObjID'),
        DataOwner = JSON_VALUE(@jsonBody, '$.DataOwner'),
        DataOwnerEmail = JSON_VALUE(@jsonBody, '$.DataOwnerEmail'),
        DataOwnerUPN = JSON_VALUE(@jsonBody, '$.DataOwnerUPN'),
        DataOwnerObjID = JSON_VALUE(@jsonBody, '$.DataOwnerObjID'),
        --SME = JSON_VALUE(@jsonBody, '$.SME'),
        Pattern = JSON_VALUE(@jsonBody, '$.Pattern'),
        [Format] = JSON_VALUE(@jsonBody, '$.[Format]'),
        Restrictions = JSON_VALUE(@jsonBody, '$.Restrictions'),
        Metadata = JSON_VALUE(@jsonBody, '$.Metadata'),
        DataClassificationLevel = JSON_VALUE(@jsonBody, '$.DataClassificationLevel'),
        EditedBy = JSON_VALUE(@jsonBody, '$.EditedBy'),
        EditedByEmail = JSON_VALUE(@jsonBody, '$.EditedByEmail'),
        EditedByUPN = JSON_VALUE(@jsonBody, '$.EditedByUPN'),
        [EditedById] = JSON_VALUE(@jsonBody, '$.[EditedById]')
        --DataSchema = JSON_VALUE(@jsonBody, '$.DataSchema'),Working on best way to get existing or new schema
    WHERE ContractID = JSON_VALUE(@jsonBody, '$.ContractID');
END
GO

