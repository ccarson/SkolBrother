﻿CREATE PROCEDURE [dbo].[getUserReportResults] 
	@reportID UNIQUEIDENTIFIER
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	-- does report include matching strings?
	IF EXISTS (
		SELECT * FROM dbo.caseReportProducts AS crp
		WHERE crp.id = @reportID AND crp.manufacturerStartsWith IS NOT NULL )
		
	-- build matching string that includes manufactureStartsWith

	
	SELECT DISTINCT ec.*
	FROM dbo.eventCaseResponses AS ecr
	INNER JOIN dbo.caseReportOptions AS cro
		ON (( ecr.eventResponseOptionsID = cro.eventResponseOptionsID AND ecr.responseData IS NULL ) OR
			 ( ecr.eventResponseOptionsID = cro.eventResponseOptionsID AND ecr.responseData LIKE cro.responseDataStartsWith ))
	INNER JOIN dbo.eventCases AS ec
		ON ec.id = ecr.eventCasesID
	
	/* 
		
		issue -- the above query will return matches based on reporting options -- however, it does NOT take into account 
			product responses.  Query for results needs to expand to include product data
	
	*/
	
END