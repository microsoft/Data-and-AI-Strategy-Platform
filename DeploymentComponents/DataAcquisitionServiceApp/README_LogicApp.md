# Data and AI Portal Logic Apps and uses






| Workflow Name | Used for | Connects to/from  |
|---------------|----------|-------------------|
|Data Contract Edit|   Currently unused, DataContractSubmit now has the ability to edit as well as submit.|               |
|DataContractIngestion|   Writing the JSON payload to the control table   |               |
|DataContractSubmit|From the portal, submits values to the Data Contract table as well as allows edits to existing Data Contracts| |
|getDatabases|Used in the Mapping Service (Business Use Case module) to query what Lake DB's are available. Currently not used in the Acquisition Service| |
|getDataContract|Micro service API to query and populate the Power App Data Contract collection. Is called when the app opens, when a refresh button is pushed, or after a Data Contract is submitted and the page naviages to the Data Contract view page.| |
|getHandshakeRecords|Micro service API to query and populate the Power App Handshake collection. Is called when the app opens, when a refresh button is pushed, or after a Handshake  is submitted and the page naviages to the Handshake view page.| |
|getlistFromControlTable|Currently unused, Part of the Mapping services in the Business Use Case| |
|getMappingRecords|Currently unused, Part of the Mapping services in the Business Use Case| |
|getNewDataContract|Micro service to get the Data Contract and to create a JSON payload shaped for displaying Data Contract information in the app.|usp_getDataContractRecordsDynamic |
|getPatternData|Micro service to retrieve the values from the PatternTable. Runs when the App opens and populates the Pattern drop down in the Data Contract.| |
|getSchema|Currently unused, Part of the Mapping services in the Business Use Case. Runs to extract the schema of the file submitted, to then surface the column names for the mapping service.| |
|getSynapseTable|Currently unused, Part of the Mapping services in the Business Use Case. Uses a database name and runs a query to return the names of the tables within that Lake Database in Synapse. | |
|handshakeSubmit|From the portal, submits values to the Handshake table as well as allows edits to existing Handshakes.| |
|la_PackagePayloadConfigurator|Runs on recurrance and shapes the data from both the Data Contract and Handshake tables and readies the JSON payload for the DataContractIngestion workflow.|Called once a Handshake table row is inserted. Runs on a recurrance trigger. Currently set at 2 minutes between runs. Then calls the DataContractIngestion app and sends this payload to write to the Control Table.|
|MappingServiceIngestion|Writes the values to the Mapping table from the Mapping activities in the Business Use Case module|Runs the usp_InsertDataMapping Stored Procedure|
|PatternSubmit|Currently unused, but writes new values to the pattern table. The app page for this is not complete so is not active at this time.|Runs the usp_InsertPatternParameters Stored Procedure|
