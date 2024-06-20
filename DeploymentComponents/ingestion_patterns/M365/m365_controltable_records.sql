-- // Copyright (c) Microsoft Corporation.
--// Licensed under the MIT license.
--CALENDAR
INSERT INTO [dbo].[ControlTable]
VALUES (
    '{ "tableName": "BasicDataSet_v0.CalendarView_v0", "scopeFilter": "", "filterOnDate": true }',
    '',
    '{ "dateFilterColumn": "", "startDate": "2020-01-01T00:00:00.000Z", "endDate": "2023-12-31T00:00:00.000Z","watermark_column_data_type":"NA","outputColumns":[{"name":"id"},{"name":"allowNewTimeProposals"},{"name":"createdDateTime"},{"name":"lastModifiedDateTime"},{"name":"changeKey"},{"name":"categories"},{"name":"originalStartTimeZone"},{"name":"originalEndTimeZone"},{"name":"responseStatus"},{"name":"iCalUId"},{"name":"isOnlineMeeting"},{"name":"reminderMinutesBeforeStart"},{"name":"isReminderOn"},{"name":"hasAttachments"},{"name":"subject"},{"name":"body"},{"name":"importance"},{"name":"sensitivity"},{"name":"start"},{"name":"end"},{"name":"location"},{"name":"isAllDay"},{"name":"isCancelled"},{"name":"isOrganizer"},{"name":"onlineMeeting"},{"name":"onlineMeetingProvider"},{"name":"recurrence"},{"name":"responseRequested"},{"name":"showAs"},{"name":"transactionId"},{"name":"type"},{"name":"attendees"},{"name":"organizer"},{"name":"webLink"},{"name":"attachments"},{"name":"bodyPreview"},{"name":"locations"},{"name":"onlineMeetingUrl"},{"name":"seriesMasterId"},{"name":"originalStart"}] }',
    '{ "fileName": null, "folderPath": "DsDemo/M365/BasicDataSet_v0/CalendarView_v0/", "container": "landing" }',
    '',
    '',
    '',
    'PL_1_Source_to_Landing_Step1',
    'TR_M365',
    '{ "ingestionPattern": "M365" }',
    '0',
    'True',
    '{}',
    'True'
)

GO

INSERT INTO [dbo].[ControlTable]
VALUES (
    '{ "fileName": "", "folderPath": "%/BasicDataSet_v0/CalendarView_v0/full%", "container": "landing" }',
    '',
    '{ "fileType": "json", "delimiter": "", "compression": "None", "multiline":"false" }',
    '{ "fileName": null, "folderPath": "DsDemo/M365/BasicDataSet_v0/CalendarView_v0/", "container": "raw" }',
    '',
    '',
    '',
    'PL_2_Process_Landed_Files_Step2',
    'TR_FileCreated_Landing_EventLog',
    '{ "dataLoadingBehavior": "Copy_to_Raw", "loadType": "full" }',
    '0',
    'True',
    '{}',
    'True'
)

GO

INSERT INTO [dbo].[ControlTable]
VALUES (
    '{ "fileName": "", "folderPath": "%/BasicDataSet_v0/CalendarView_v0/delta%", "container": "landing" }',
    '',
    '{ "fileType": "json", "delimiter": "", "compression": "None", "multiline":"false" }',
    '{ "fileName": null, "folderPath": "DsDemo/M365/BasicDataSet_v0/CalendarView_v0/", "container": "raw" }',
    '',
    '',
    '',
    'PL_2_Process_Landed_Files_Step2',
    'TR_FileCreated_Landing_EventLog',
    '{ "dataLoadingBehavior": "Copy_to_Raw", "loadType": "delta" }',
    '0',
    'True',
    '{}',
    'True'
)

GO

INSERT INTO [dbo].[ControlTable]
VALUES (
    '{ "fileName": "", "folderPath": "%/BasicDataSet_v0/CalendarView_v0/%", "container": "raw" }',
    '',
    '{ "primary_key_cols": "[''id'']","partition_cols": "","date_partition_column":"","file_type":"json"  }',
    '{ "fileName": null, "folderPath": "DsDemo/M365/BasicDataSet_v0/CalendarView_v0/", "container": "staging" }',
    '',
    '',
    '',
    'PL_3_MoveToStaging_Step2',
    'TR_FileCreated_Landing_EventLog_Staging',
    '{ "dataLoadingBehavior": "Copy_to_Staging" }',
    '0',
    'True',
    '{}',
    'True'
)

GO

--MESSAGE
INSERT INTO [dbo].[ControlTable]
VALUES (
    '{ "tableName": "BasicDataSet_v0.Message_v1", "scopeFilter": "", "filterOnDate": true }',
    '',
    '{ "dateFilterColumn":"lastModifiedDateTime", "startDate": "watermarkvalue", "endDate": "2100-01-01T00:00:00.000Z","watermark_column_data_type":"Datetime","outputColumns": [{"name":"receivedDateTime"},{"name":"sentDateTime"},{"name":"hasAttachments"},{"name":"internetMessageId"},{"name":"subject"},{"name":"importance"},{"name":"parentFolderId"},{"name":"sender"},{"name":"from"},{"name":"toRecipients"},{"name":"ccRecipients"},{"name":"bccRecipients"},{"name":"replyTo"},{"name":"conversationId"},{"name":"uniqueBody"},{"name":"isDeliveryReceiptRequested"},{"name":"isReadReceiptRequested"},{"name":"isRead"},{"name":"isDraft"},{"name":"webLink"},{"name":"createdDateTime"},{"name":"lastModifiedDateTime"},{"name":"changeKey"},{"name":"categories"},{"name":"id"},{"name":"attachments"},{"name":"inferenceClassification"},{"name":"flag"},{"name":"body"},{"name":"bodyPreview"},{"name":"internetMessageHeaders"},{"name":"conversationIndex"}] }',
    '{ "fileName": null, "folderPath": "DsDemo/M365/BasicDataSet_v0/Message_v1/", "container": "landing" }',
    '',
    '',
    '',
    'PL_1_Source_to_Landing_Step1',
    'TR_M365',
    '{ "ingestionPattern": "M365" }',
    '0',
    'True',
    '{}',
    'True'
)

GO

INSERT INTO [dbo].[ControlTable]
VALUES (
    '{ "fileName": "", "folderPath": "%/BasicDataSet_v0/Message_v1/full%", "container": "landing" }',
    '',
    '{ "fileType": "json", "delimiter": "", "compression": "None", "multiline":"false" }',
    '{ "fileName": null, "folderPath": "DsDemo/M365/BasicDataSet_v0/Message_v1/", "container": "raw" }',
    '',
    '',
    '',
    'PL_2_Process_Landed_Files_Step2',
    'TR_FileCreated_Landing_EventLog',
    '{ "dataLoadingBehavior": "Copy_to_Raw", "loadType": "full" }',
    '0',
    'True',
    '{}',
    'True'
);


GO

INSERT INTO [dbo].[ControlTable]
VALUES (
    '{ "fileName": "", "folderPath": "%/BasicDataSet_v0/Message_v1/delta%", "container": "landing" }',
    '',
    '{ "fileType": "json", "delimiter": "", "compression": "None", "multiline":"false" }',
    '{ "fileName": null, "folderPath": "DsDemo/M365/BasicDataSet_v0/Message_v1/", "container": "raw" }',
    '',
    '',
    '',
    'PL_2_Process_Landed_Files_Step2',
    'TR_FileCreated_Landing_EventLog',
    '{ "dataLoadingBehavior": "Copy_to_Raw", "loadType": "delta" }',
    '0',
    'True',
    '{}',
    'True'
)

GO

INSERT INTO [dbo].[ControlTable]
VALUES (
    '{ "fileName": "", "folderPath": "%/BasicDataSet_v0/Message_v1/%", "container": "raw" }',
    '',
    '{ "primary_key_cols": "[''Id'']","partition_cols": "","date_partition_column":"","file_type":"json"  }',
    '{ "fileName": null, "folderPath": "DsDemo/M365/BasicDataSet_v0/Message_v1/", "container": "staging" }',
    '',
    '',
    '',
    'PL_3_MoveToStaging_Step2',
    'TR_FileCreated_Landing_EventLog_Staging',
    '{ "dataLoadingBehavior": "Copy_to_Staging" }',
    '0',
    'True',
    '{}',
    'True'
)

GO


--USER
INSERT INTO [dbo].[ControlTable]
VALUES (
    '{ "tableName": "BasicDataSet_v0.User_v1", "scopeFilter": "", "filterOnDate": false }',
    '',
    '{ "dateFilterColumn": "", "startDate": "", "endDate": "","watermark_column_data_type":"NA","outputColumns":[{"name":"aboutMe"},{"name":"accountEnabled"},{"name":"ageGroup"},{"name":"assignedLicenses"},{"name":"assignedPlans"},{"name":"birthday"},{"name":"businessPhones"},{"name":"city"},{"name":"companyName"},{"name":"consentProvidedForMinor"},{"name":"country"},{"name":"createdDateTime"},{"name":"department"},{"name":"displayName"},{"name":"givenName"},{"name":"hireDate"},{"name":"id"},{"name":"imAddresses"},{"name":"interests"},{"name":"jobTitle"},{"name":"legalAgeGroupClassification"},{"name":"mail"},{"name":"mailNickname"},{"name":"mobilePhone"},{"name":"mySite"},{"name":"officeLocation"},{"name":"onPremisesImmutableId"},{"name":"onPremisesLastSyncDateTime"},{"name":"onPremisesSecurityIdentifier"},{"name":"onPremisesSyncEnabled"},{"name":"passwordPolicies"},{"name":"pastProjects"},{"name":"postalCode"},{"name":"preferredLanguage"},{"name":"preferredName"},{"name":"provisionedPlans"},{"name":"proxyAddresses"},{"name":"responsibilities"},{"name":"schools"},{"name":"skills"},{"name":"state"},{"name":"streetAddress"},{"name":"surname"},{"name":"usageLocation"},{"name":"userPrincipalName"},{"name":"userType"}] }',
    '{ "fileName": null, "folderPath": "DsDemo/M365/BasicDataSet_v0/User_v1/", "container": "landing" }',
    '',
    '',
    '',
    'PL_1_Source_to_Landing_Step1',
    'TR_M365',
    '{ "ingestionPattern": "M365" }',
    '0',
    'True',
    '{}',
    'True'
)

GO

INSERT INTO [dbo].[ControlTable]
VALUES (
    '{ "fileName": "", "folderPath": "%/BasicDataSet_v0/User_v1/full%", "container": "landing" }',
    '',
    '{ "fileType": "json", "delimiter": "", "compression": "None", "multiline":"false" }',
    '{ "fileName": null, "folderPath": "DsDemo/M365/BasicDataSet_v0/User_v1/", "container": "raw" }',
    '',
    '',
    '',
    'PL_2_Process_Landed_Files_Step2',
    'TR_FileCreated_Landing_EventLog',
    '{ "dataLoadingBehavior": "Copy_to_Raw", "loadType": "full" }',
    '0',
    'True',
    '{}',
    'True'
)

GO

INSERT INTO [dbo].[ControlTable]
VALUES (
    '{ "fileName": "", "folderPath": "%/BasicDataSet_v0/User_v1/delta%", "container": "landing" }',
    '',
    '{ "fileType": "json", "delimiter": "", "compression": "None", "multiline":"false" }',
    '{ "fileName": null, "folderPath": "DsDemo/M365/BasicDataSet_v0/User_v1/", "container": "raw" }',
    '',
    '',
    '',
    'PL_2_Process_Landed_Files_Step2',
    'TR_FileCreated_Landing_EventLog',
    '{ "dataLoadingBehavior": "Copy_to_Raw", "loadType": "delta" }',
    '0',
    'True',
    '{}',
    'True'
)

GO

INSERT INTO [dbo].[ControlTable]
VALUES (
    '{ "fileName": "", "folderPath": "%/BasicDataSet_v0/User_v1/%", "container": "raw" }',
    '',
    '{ "primary_key_cols": "[''id'']","partition_cols": "","date_partition_column":"","file_type":"json"  }',
    '{ "fileName": null, "folderPath": "DsDemo/M365/BasicDataSet_v0/User_v1/", "container": "staging" }',
    '',
    '',
    '',
    'PL_3_MoveToStaging_Step2',
    'TR_FileCreated_Landing_EventLog_Staging',
    '{ "dataLoadingBehavior": "Copy_to_Staging" }',
    '0',
    'True',
    '{}',
    'True'
)

GO


--TEAMS CHAT
INSERT INTO [dbo].[ControlTable]
VALUES (
    '{ "tableName": "BasicDataSet_v0.TeamChat_v2", "scopeFilter": "", "filterOnDate": true }',
    '',
    '{ "dateFilterColumn":"LastModifiedDateTime", "startDate": "watermarkvalue", "endDate": "2100-01-01T00:00:00.000Z","watermark_column_data_type":"Datetime","outputColumns":[{"name":"Id"},{"name":"CreatedDateTime"},{"name":"LastModifiedDateTime"},{"name":"ReceivedDateTime"},{"name":"SentDateTime"},{"name":"HasAttachments"},{"name":"Subject"},{"name":"BodyPreview"},{"name":"Importance"},{"name":"Body"},{"name":"Sender"},{"name":"From"},{"name":"ToRecipients"},{"name":"ReplyTo"},{"name":"Flag"},{"name":"Attachments"},{"name":"ThreadId"},{"name":"ThreadType"}] }',
    '{ "fileName": null, "folderPath": "DsDemo/M365/BasicDataSet_v0/TeamChat_v2/", "container": "landing" }',
    '',
    '',
    '',
    'PL_1_Source_to_Landing_Step1',
    'TR_M365',
    '{ "ingestionPattern": "M365" }',
    '0',
    'True',
    '{}',
    'True'
)

GO

INSERT INTO [dbo].[ControlTable]
VALUES (
    '{ "fileName": "", "folderPath": "%/BasicDataSet_v0/TeamChat_v2/full%", "container": "landing" }',
    '',
    '{ "fileType": "json", "delimiter": "", "compression": "None", "multiline":"false" }',
    '{ "fileName": null, "folderPath": "DsDemo/M365/BasicDataSet_v0/TeamChat_v2/", "container": "raw" }',
    '',
    '',
    '',
    'PL_2_Process_Landed_Files_Step2',
    'TR_FileCreated_Landing_EventLog',
    '{ "dataLoadingBehavior": "Copy_to_Raw", "loadType": "full" }',
    '0',
    'True',
    '{}',
    'True'
)

GO

INSERT INTO [dbo].[ControlTable]
VALUES (
    '{ "fileName": "", "folderPath": "%/BasicDataSet_v0/TeamChat_v2/delta%", "container": "landing" }',
    '',
    '{ "fileType": "json", "delimiter": "", "compression": "None", "multiline":"false" }',
    '{ "fileName": null, "folderPath": "DsDemo/M365/BasicDataSet_v0/TeamChat_v2/", "container": "raw" }',
    '',
    '',
    '',
    'PL_2_Process_Landed_Files_Step2',
    'TR_FileCreated_Landing_EventLog',
    '{ "dataLoadingBehavior": "Copy_to_Raw", "loadType": "delta" }',
    '0',
    'True',
    '{}',
    'True'
)

GO

INSERT INTO [dbo].[ControlTable]
VALUES (
    '{ "fileName": "", "folderPath": "%/BasicDataSet_v0/TeamChat_v2/%", "container": "raw" }',
    '',
    '{ "primary_key_cols": "[''id'']","partition_cols": "","date_partition_column":"","file_type":"json"  }',
    '{ "fileName": null, "folderPath": "DsDemo/M365/BasicDataSet_v0/TeamChat_v2/", "container": "staging" }',
    '',
    '',
    '',
    'PL_3_MoveToStaging_Step2',
    'TR_FileCreated_Landing_EventLog_Staging',
    '{ "dataLoadingBehavior": "Copy_to_Staging" }',
    '0',
    'True',
    '{}',
    'True'
)

GO

