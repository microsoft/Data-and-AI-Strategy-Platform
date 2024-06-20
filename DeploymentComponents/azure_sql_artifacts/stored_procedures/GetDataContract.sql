/* Copyright (c) Microsoft Corporation.
 Licensed under the MIT license. */

/****** Object:  StoredProcedure [dbo].[GetDataContract]    Script Date: 2/7/2024 4:08:33 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE OR ALTER PROCEDURE [dbo].[GetDataContract]
(
	@DataContract varchar(255)
)
AS
BEGIN

DECLARE @matchedrecords int

SET @matchedrecords = (

SELECT			COUNT(*)
FROM			[dbo].[DataContract]
WHERE			[ContractID] = JSON_VALUE(@DataContract, '$."DataContractID"')
)

IF @matchedrecords > 0
BEGIN
-- if data contract is available return it
SELECT			*
FROM			[dbo].[DataContract]
WHERE			[ContractID] = JSON_VALUE(@DataContract, '$."DataContractID"')
RETURN

END

ELSE

BEGIN
--otherwise return no data contract available
SELECT			'No Data Contract Available' [DataContractAvailability]
RETURN

END

END
GO