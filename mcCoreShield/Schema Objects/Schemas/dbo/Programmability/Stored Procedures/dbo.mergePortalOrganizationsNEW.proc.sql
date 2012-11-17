﻿CREATE PROCEDURE [dbo].[mergePortalOrganizationsNEW] ( @systemName       AS NVARCHAR(50) 
                                                     , @MasterPortalID   AS INT ) 
AS
/*
************************************************************************************************************************************
            
  Procedure:    dbo.mergePortalOrganizations
     Author:    Chris Carson
    Purpose:    Merges the non-coreShield tables of coreShield Organizations

    revisor    Version  date            description
    ---------  -------  -----------     ----------------------------
    ccarson    1.0      2012-09-07      created

    Logic Summary:
    1)  Parse out incoming portal.org_id values into temp storage  
    2)  UPDATE dbo.mc_organization_customvalues with @MasterPortalID
    3)  UPDATE dbo.fs_labdir_orgs with @MasterPortalID if table exists
    4)  UPDATE dbo.fs_foodag_orgs with @MasterPortalID if table exists
    5)  UPDATE dbo.fs_contact_progids with @MasterPortalID if table exists
    6)  UPDATE dbo.fs_contact_labids with @MasterPortalID if table exists
    7)  UPDATE dbo.fs_contact_labids with @MasterPortalID if table exists

        
************************************************************************************************************************************
*/
BEGIN

    DECLARE @sql               AS NVARCHAR(MAX)
          , @rc                AS INT = 0 
          , @errorMessageStart AS VARCHAR(100)
          , @errorMessage      AS VARCHAR(MAX) ; 
          
--  PRINT   'Processing non-coreShield tables on ' + @systemName + '... '; 
--  PRINT   '' ;
  
    SELECT * from #portalIDs ;
     
    SELECT  @sql = N'
USE [' + @systemName + '] ;


--  2)  UPDATE dbo.mc_organization_customvalues with @MasterPortalID
UPDATE  dbo.mc_organization_customvalues
   SET  org_id = ' + CAST( @MasterPortalID AS NVARCHAR(20) ) + '
  FROM  dbo.mc_organization_customvalues AS a
 WHERE  EXISTS ( SELECT 1 FROM #portalIDs AS b 
                  WHERE b.org_id = a.org_id ) ; 
 PRINT  CAST( @@ROWCOUNT AS VARCHAR(20) ) + '' records updated on dbo.mc_organization_customvalues '' ; 


                  
--  3)  UPDATE dbo.fs_labdir_orgs with @MasterPortalID if table exists
IF  EXISTS ( SELECT 1 FROM INFORMATION_SCHEMA.TABLES
              WHERE TABLE_NAME = ''fs_labdir_orgs'' ) 
    EXEC ( '' 
    UPDATE  dbo.fs_labdir_orgs
       SET  org_id = ' + CAST( @MasterPortalID AS VARCHAR(20) ) + '
      FROM  dbo.fs_labdir_orgs AS a
     WHERE  EXISTS ( SELECT 1 FROM #portalIDs AS b 
                      WHERE b.org_id = a.org_id ) ;
     PRINT  CAST( @@ROWCOUNT AS VARCHAR(20) ) + '''' records updated on dbo.fs_labdir_orgs '''' ; '') ; 
ELSE
     PRINT ''dbo.fs_labdir_orgs does not exist on ' + @systemName + ' '' ; 

                      
--  4)  UPDATE dbo.fs_foodag_orgs with @MasterPortalID if table exists
IF  EXISTS ( SELECT 1 FROM INFORMATION_SCHEMA.TABLES
              WHERE TABLE_NAME = ''fs_foodag_orgs'' ) 
    EXEC ( '' 
    UPDATE  dbo.fs_foodag_orgs 
       SET  org_id = ' + CAST( @MasterPortalID AS VARCHAR(20) ) + '
      FROM  dbo.fs_foodag_orgs AS a
     WHERE  EXISTS ( SELECT 1 FROM #portalIDs AS b 
                      WHERE b.org_id = a.org_id ) ;
     PRINT  CAST( @@ROWCOUNT AS VARCHAR(20) ) + '''' records updated on dbo.fs_foodag_orgs '''' ; '') ; 
ELSE
     PRINT ''dbo.fs_foodag_orgs does not exist on ' + @systemName + ' '' ; 
                      
                      
--  5)  UPDATE dbo.fs_contact_progids with @MasterPortalID if table exists
IF  EXISTS ( SELECT 1 FROM INFORMATION_SCHEMA.TABLES
              WHERE TABLE_NAME = ''fs_contact_progids'' ) 
    EXEC ( '' 
    UPDATE  fs_contact_progids 
       SET  agency_id = ' + CAST( @MasterPortalID AS VARCHAR(20) ) + '
      FROM  dbo.fs_contact_progids AS a
     WHERE  EXISTS ( SELECT 1 FROM #portalIDs AS b 
                      WHERE b.org_id = a.agency_id ) ;
     PRINT  CAST( @@ROWCOUNT AS VARCHAR(20) ) + '''' records updated on dbo.fs_contact_progids '''' ; '') ; 
ELSE
     PRINT ''dbo.fs_contact_progids does not exist on ' + @systemName + ' '' ; 
        
        
--  6)  UPDATE dbo.fs_contact_labids with @MasterPortalID if table exists
IF  EXISTS ( SELECT 1 FROM INFORMATION_SCHEMA.TABLES
              WHERE TABLE_NAME = ''fs_contact_labids'' ) 
    EXEC ( '' 
    UPDATE  dbo.fs_contact_labids 
       SET  agency_id = ' + CAST( @MasterPortalID AS VARCHAR(20) ) + '
      FROM  dbo.fs_contact_labids AS a
     WHERE  EXISTS ( SELECT 1 FROM #portalIDs AS b 
                      WHERE b.org_id = a.agency_id ) ;
     PRINT  CAST( @@ROWCOUNT AS VARCHAR(20) ) + '''' records updated on dbo.fs_contact_labids '''' ; '') ; 
ELSE
     PRINT ''dbo.fs_contact_labids does not exist on ' + @systemName + ' '' ; 
    

--  7)  UPDATE dbo.fs_contact_labids with @MasterPortalID if table exists
IF  EXISTS ( SELECT 1 FROM INFORMATION_SCHEMA.TABLES
              WHERE TABLE_NAME = ''fs_contact_agencyids'' ) 
    EXEC ( '' 
    UPDATE  dbo.fs_contact_agencyids 
       SET  agencyID = ' + CAST( @MasterPortalID AS VARCHAR(20) ) + '
      FROM  dbo.fs_contact_agencyids  AS a
     WHERE  EXISTS ( SELECT 1 FROM #portalIDs AS b 
                      WHERE b.org_id = a.agencyID ) ; 
     PRINT  CAST( @@ROWCOUNT AS VARCHAR(20) ) + '''' records updated on dbo.fs_contact_labids '''' ; '') ; 
ELSE
     PRINT ''dbo.fs_contact_labids does not exist on ' + @systemName + ' '' ; ' ;
    
   
    BEGIN TRY
        EXECUTE sp_executeSQL @sql ; 
    END TRY
    BEGIN CATCH
        SELECT  @errorMessage = 
                    'Dynamic SQL Error in '  + ERROR_PROCEDURE() + CHAR(13) 
                  + N'    SQL Error Code    = '     + CAST( ERROR_NUMBER() AS VARCHAR(20) ) + CHAR(13) 
                  + N'    SQL Error Message = '     + ERROR_MESSAGE() + CHAR(13) ;

        PRINT   CAST( @sql AS VARCHAR(MAX) ) ; 
        RAISERROR( @errorMessage, 16, 1 ) ;    
        RETURN 1 
    END CATCH
    
    --PRINT   '...non-coreShield tables on ' + @systemName + ' processed. ' ; 
    
END
