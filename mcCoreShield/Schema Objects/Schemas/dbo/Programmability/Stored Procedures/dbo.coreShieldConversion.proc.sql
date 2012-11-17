﻿CREATE PROCEDURE [dbo].[coreShieldConversion] (
	@systemName AS NVARCHAR(50)
	, @dbName AS NVARCHAR(50) )
AS
BEGIN

	SET NOCOUNT ON;

	DECLARE @systemID		AS INT;
	DECLARE @rc				AS INT;
	DECLARE @tableName		AS NVARCHAR(50);
	DECLARE @newTableName	AS NVARCHAR(50);
	DECLARE @procName AS NVARCHAR(100);
	DECLARE @sql			AS NVARCHAR(4000);
	
/*	dbo.transitionSystems */
	EXECUTE @systemID = mcCoreShield.dbo.convertTransitionSystems
							@systemName = @systemName, @dbname = @dbName;

/* Create synonyms for tables that are being converted */
	EXECUTE @rc = mcCoreShield.dbo.createTargetSynonyms
					@systemID = @systemID, @systemName = @systemName, @dbName = @dbName;
					
/*	Loop through coreConvertedTables, running conversion proc for each table to be converted */			
 	DECLARE tablenames CURSOR FOR
		SELECT tablename, newTableName FROM mcCoreShield.dbo.coreConvertedTables
		WHERE isReady = 1
		ORDER BY conversionSequence;
	
 	OPEN tablenames;
	
 	FETCH NEXT FROM tablenames INTO @tableName, @newTableName;

 	WHILE @@FETCH_STATUS = 0
 	BEGIN
 	
 		PRINT N'/* BEGIN: ' + @tableName + N' to ' + @newTableName + N' */'
 		PRINT N'/* 1) Load LegacyIDs from ' + @tableName + N' */'		
		
		EXECUTE @rc = mcCoreShield.dbo.loadLegacyIDs
			@systemID = @systemID, @tableName = @tableName;			
		IF (@rc <> 0 )
		BEGIN
			SET @procName = N'Error creating LegacyIDs for ' + @tableName;
			RAISERROR ( @procName, 16, 1 );
			RETURN;
		END			
 	
 		PRINT N'/* 2) Coverting ' + @tableName + N' to ' + @newTableName + N' */'	
 		SET @procName = N'mcCoreShield.dbo.convert' + @newTableName ;
		
		EXECUTE @rc = @procname 
			@systemID = @systemID, @systemName = @systemName, @dbName = @dbName, @tableName = @tableName;
			
		IF (@rc <> 0 )
		BEGIN
			SET @procName = N'Error in ' + @procName;
			RAISERROR ( @procName, 16, 1 );
			RETURN;
		END

	 	FETCH NEXT FROM tablenames INTO @tableName, @newTableName;

	END

	CLOSE tablenames;
	DEALLOCATE tablenames;
	
/* Create triggers for tables that are being converted */
	EXECUTE @rc = mcCoreShield.dbo.createTargetTriggers
					@systemID = @systemID, @systemName = @systemName, @dbName = @dbName 
					
/* Drop conversion synonyms */

	DECLARE synNames CURSOR FOR
		SELECT name FROM mcCoreShield.sys.synonyms;

	OPEN synNames;
	
	FETCH NEXT FROM synNames INTO @tableName;
	
	WHILE @@FETCH_STATUS = 0
	BEGIN
		SET @sql = N'DROP SYNONYM dbo.' + @tableName;
		EXEC ( @sql );
			
		FETCH NEXT FROM synNames INTO @tableName;
	END

	CLOSE synNames;
	DEALLOCATE synNames;
	
	DROP TABLE mcCoreShield.dbo.tempLegacyIDs
	
END
