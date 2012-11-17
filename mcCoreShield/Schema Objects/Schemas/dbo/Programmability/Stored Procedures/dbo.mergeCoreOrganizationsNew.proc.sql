﻿CREATE PROCEDURE [dbo].[mergeCoreOrganizationsNew] ( @systemID               AS INT
                                                   , @systemName             AS NVARCHAR(50) 
                                                   , @MasterOrganizationsID  AS UNIQUEIDENTIFIER ) 
AS
/*
************************************************************************************************************************************
            
  Procedure:    dbo.mergeCoreOrganizations
     Author:    Chris Carson
    Purpose:    Merges coreShield tables related to dbo.Organizations

    revisor    Version  date            description
    ---------  -------  -----------     ----------------------------
    ccarson    1.0      2012-09-07      created

    Logic Summary:
    1)  Parse out incoming organizationIDs into temp storage
    2)  UPDATE dbo.OrgDepartments, setting organizationsID on merging records to @MasterOrganizationsID
    3)  UPDATE dbo.OrgLocations, setting organizationsID on merging records to @MasterOrganizationsID
    4)  UPDATE dbo.ContactOrganizations, setting organizationsID on merging records to @MasterOrganizationsID
    5)  UPDATE dbo.ContactOrgRoles, setting organizationsID on merging records to @MasterOrganizationsID
    
************************************************************************************************************************************
*/
BEGIN

    SET NOCOUNT ON ; 
    
--  PRINT   'Processing coreShield tables for ' + @systemName + '... '; 
--  PRINT   '' ;    
    
--  2)  UPDATE dbo.OrgDepartments, setting organizationsID on merging records to @MasterOrganizationsID
    UPDATE  dbo.OrgDepartments 
       SET  organizationsID = @MasterOrganizationsID
      FROM  dbo.OrgDepartments AS a
     WHERE  EXISTS ( SELECT 1 
                       FROM #Organizations AS o 
                      WHERE o.id = a.organizationsID ) ; 
    PRINT CAST( @@ROWCOUNT AS VARCHAR(20) ) + ' records updated on dbo.OrgDepartments ' ; 

                      
--  3)  UPDATE dbo.OrgLocations, setting organizationsID on merging records to @MasterOrganizationsID
    UPDATE  dbo.OrgLocations
       SET  organizationsID = @MasterOrganizationsID
      FROM  dbo.OrgLocations AS a
     WHERE  EXISTS ( SELECT 1 
                       FROM #Organizations AS o 
                      WHERE o.id = a.organizationsID ) ; 
    PRINT CAST( @@ROWCOUNT AS VARCHAR(20) ) + ' records updated on dbo.OrgLocations ' ; 

                      
--  4)  UPDATE dbo.ContactOrganizations, setting organizationsID on merging records to @MasterOrganizationsID
    UPDATE  dbo.ContactOrganizations 
       SET  organizationsID = @MasterOrganizationsID
      FROM  dbo.ContactOrganizations AS a
     WHERE  EXISTS ( SELECT 1 
                       FROM #Organizations AS o 
                      WHERE o.id = a.organizationsID ) ;                   
    PRINT CAST( @@ROWCOUNT AS VARCHAR(20) ) + ' records updated on dbo.ContactOrganizations ' ; 

    
--  5)  UPDATE dbo.ContactOrgRoles, setting organizationsID on merging records to @MasterOrganizationsID
    UPDATE  dbo.ContactOrgRoles
       SET  organizationsID = @MasterOrganizationsID
      FROM  dbo.ContactOrgRoles AS a
     WHERE  EXISTS ( SELECT 1 
                       FROM #Organizations AS o 
                      WHERE o.id = a.organizationsID ) ; 
    PRINT CAST( @@ROWCOUNT AS VARCHAR(20) ) + ' records updated on dbo.ContactOrgRoles ' ; 
    
--  PRINT   '...coreShield tables for ' + @systemName + ' processed. ' ; 

END
