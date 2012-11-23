CREATE PROCEDURE Conversion.coreShieldConversion ( @systemName      AS NVARCHAR(50) 
                                                 , @convertedDBname AS NVARCHAR(50)
                                                 , @legacyDBname    AS NVARCHAR(50) ) 
AS
/*
************************************************************************************************************************************

  Procedure: Conversion.coreShieldConversion
     Author: Chris Carson
    Purpose: Converts a legacy portal to new coreShield schema

    revisor     date            description
    ---------   -----------     ----------------------------
    ccarson     ###DATE###      created


    Logic Summary:
        1)  Create record on dbo.Systems for converting systemID
        2)  Disable constraints on new database
        3)  loop through tables of legacy database
        4)  copy data from legacy database for tables that are not converting
        5)  execute conversion proc for tables that are converting
        
    Notes:
        Add error handling

************************************************************************************************************************************
*/
BEGIN

    SET NOCOUNT ON;

    DECLARE @systemID       AS INT;
    DECLARE @rc             AS INT;
    DECLARE @tableName      AS NVARCHAR(50);
    DECLARE @newTableName   AS NVARCHAR(50);
    DECLARE @procName       AS NVARCHAR(100);
    DECLARE @sql            AS NVARCHAR(4000);
    
--  1)  Create record on dbo.Systems for converting systemID    
--  EXECUTE @rc = Conversion.createSystemsRecord    @systemName
--                                                  @convertedDBname ; 
                                                  
--  2)  Disable constraints on new database
--  3)  loop through tables of legacy database
--  4)  copy data from legacy database for tables that are not converting
--  5)  execute conversion proc for tables that are converting                                                  

END
