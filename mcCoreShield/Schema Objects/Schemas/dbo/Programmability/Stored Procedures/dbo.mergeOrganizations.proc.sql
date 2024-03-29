﻿CREATE PROCEDURE dbo.mergeOrganizations ( @MasterOrganizationID    AS UNIQUEIDENTIFIER 
                                        , @mergingOrganizationIDs  AS NVARCHAR(4000) ) 
AS
/*
************************************************************************************************************************************
            
  Procedure:    dbo.mergeOrganizations
     Author:    Chris Carson
    Purpose:    Merges coreShield Organizations

    revisor    Version  date            description
    ---------  -------  -----------     ----------------------------
    ccarson    1.0      2012-09-07      created


    Logic Summary:
    1)  Extract Portal.Organizations based on @mergingOrganizationIDs into temp storage
    2)  Extract portal data based on @mergingOrganizationIDs into temp storage
    3)  Merge Core.Organizations and Portal.Organizations for each portal
    4)  Extract Portal.mc_organization.ID for @MasterOrganizationID
    5)  When master organization does not exist on target portal         
            Select a single record to use as a template        
            Save off Portal.mc_organization.id from template record          
            Build target portal record for master organization, using -1 as the mc_organizationID
    6)  Build list of Core.Organizations.id values for merge
    7)  Merge coreShield tables
    8)  Drop Portal.Organizations records for merged records
    9)  Mark Core.Organizations records as merged
   10)  If there was a new target portal record built in 5) 
            change the mc_organizationID from -1 to the @TemplatePortalID
            restore the original org_id for non-coreShield tables merge
   11)  Build list of Portal.mc_organization.id values for merge
   12)  Merge data on non-core shield tables                      
   13)  UPDATE Master Core.Organizations and Master Portal.Organizations records

************************************************************************************************************************************
*/
BEGIN

    SET NOCOUNT ON ; 
    
    DECLARE @systemID             AS INT 
          , @systemName           AS NVARCHAR(50) 
          , @TemplatePortalID     AS INT
          , @mergingPortalIDs     AS NVARCHAR(4000) 
          , @mergingCoreShieldIDs AS NVARCHAR(4000)
          , @MasterPortalID       AS INT ; 
          

    DECLARE @TemplateOrgSystemsRecord AS TABLE (
                id                  uniqueidentifier NOT NULL
              , systemID            int              NULL
              , organizationTypeID  int              NULL
              , verticalID          int              NULL
              , createdOn           datetime2(7)     NULL
              , createdBy           uniqueidentifier NULL
              , updatedOn           datetime2(7)     NULL
              , updatedBy           uniqueidentifier NULL
              , mc_organizationID   int              NULL ) ; 

    DECLARE @InsertedOrgSystemsRecord AS TABLE ( 
                id                  uniqueidentifier NOT NULL
              , systemID            int              NULL
              , organizationTypeID  int              NULL
              , verticalID          int              NULL
              , createdOn           datetime2(7)     NULL
              , createdBy           uniqueidentifier NULL
              , updatedOn           datetime2(7)     NULL
              , updatedBy           uniqueidentifier NULL
              , mc_organizationID   int              NULL ) ; 
    

--  1)  Extract Portal.Organizations based on @mergingOrganizationIDs into temp storage
      WITH  inputData AS ( 
            SELECT id = CAST( Item AS UNIQUEIDENTIFIER ) 
              FROM dbo.tvf_SplitString( @mergingOrganizationIDs, ',' ) )
    SELECT  id                  = o.id
          , systemID            = COALESCE( systemID, 1 )
          , organizationTypeID  = COALESCE( organizationTypeID, 1 )
          , verticalID          = COALESCE( verticalID, 1 )
          , createdOn           = o.createdOn
          , createdBy           = o.createdBy
          , updatedOn           = o.updatedOn
          , updatedBy           = o.updatedBy
          , portalID            = COALESCE( portalID, -1 )
      INTO  #MergingOrganizations
      FROM  Core.Organizations AS o
INNER JOIN  inputData AS i ON i.id = o.id
 LEFT JOIN  Portal.Organizations AS os ON os.id = o.id ; 
      

--  2)  Extract portal data based on @mergingOrganizationIDs into temp storage
    SELECT  id, systemName
      INTO  #portalData
      FROM  dbo.transitionSystems
     WHERE  id IN ( SELECT DISTINCT systemID FROM #MergingOrganizations ) ; 
     

--  3)  Merge Core.Organizations and Portal.Organizations for each portal
     WHILE  EXISTS ( SELECT 1 FROM #portalData ) 
     BEGIN

        SELECT  TOP 1 
                @systemID   = id
              , @systemName = systemName
          FROM  #portalData ; 

        DELETE  @TemplateOrgSystemsRecord ; 
        DELETE  @InsertedOrgSystemsRecord ; 
        
        SELECT  @TemplatePortalID = NULL
              , @mergingPortalIDs = NULL
              , @MasterPortalID   = NULL ; 

              
--  4)  Extract Portal.mc_organization.ID for @MasterOrganizationID
        SELECT  @MasterPortalID = portalID
          FROM  Portal.Organizations
         WHERE  id = @MasterOrganizationID AND systemID = @systemID ;

         
--  5)  When master organization does not exist on target portal         
        IF  ( @@ROWCOUNT = 0 )
        BEGIN 
            SELECT  @MasterPortalID = -1 ; 

--          Select a single record to use as a template        
            INSERT  @TemplateOrgSystemsRecord
            SELECT  TOP 1 * FROM  #MergingOrganizations
             WHERE  systemID = @systemID
          ORDER BY  systemID, portalID ;
          
--          Save off Portal.mc_organization.id from template record          
            SELECT  @TemplatePortalID = mc_organizationID
              FROM  @TemplateOrgSystemsRecord ; 
            
--          Build target portal record for master organization, using -1 as the mc_organizationID
            INSERT  Portal.Organizations ( 
                        id, systemID
                            , organizationTypeID, verticalID
                            , createdOn, createdBy
                            , updatedOn, updatedBy
                            , portalID )
            OUTPUT  inserted.* INTO @InsertedOrgSystemsRecord
            SELECT  @MasterOrganizationID, systemID
                        , organizationTypeID, verticalID
                        , SYSDATETIME(), createdBy
                        , SYSDATETIME(), updatedBy
                        , -1
              FROM  @TemplateOrgSystemsRecord ; 
        END
                
--  6)  Build list of Core.Organizations.id values for merge
        SELECT  @mergingCoreShieldIDs = STUFF (( SELECT ',' + CAST( id AS VARCHAR(50) )
                                                   FROM #MergingOrganizations
                                                  WHERE systemID = @systemID
                                                    FOR XML PATH ('')),1,1,'') ;

--  7)  Merge coreShield tables
        EXECUTE dbo.mergeCoreOrganizations @systemName
                                                      , @MasterOrganizationID
                                                      , @mergingCoreShieldIDs ; 
                                                                
--  8)  Drop Portal.Organizations records for merged records
        DELETE  Portal.Organizations
          FROM  Portal.Organizations AS a
         WHERE  EXISTS ( SELECT 1 FROM #MergingOrganizations AS b
                          WHERE b.id = a.id ) 
                AND a.systemID = @systemID ; 
                                    
--  9)  Mark Core.Organizations records as merged
        UPDATE  Core.Organizations
           SET  name      = name + ' ## MERGED ## ' 
              , isActive  = 0 
              , UpdatedOn = SYSDATETIME()
          FROM  Core.Organizations AS a
         WHERE  EXISTS ( SELECT 1 FROM #MergingOrganizations AS b
                          WHERE b.id = a.id AND b.systemID = @systemID ) 
           AND  NOT EXISTS ( SELECT 1 FROM Portal.Organizations AS os WHERE os.id = a.id ) ; 
           
--  10) If there was a new target portal record built in 5) 
        IF  ( @MasterPortalID = -1 ) 
        BEGIN 
--          change the mc_organizationID from -1 to the @TemplatePortalID
            UPDATE  Portal.Organizations
               SET  portalID = @TemplatePortalID
              FROM  Portal.Organizations
             WHERE  id = @MasterOrganizationID AND systemID = @systemID ; 
            
--          restore the original org_id for non-coreShield tables merge
            SELECT  @MasterPortalID = @TemplatePortalID ; 
        END
        
--  11) Build list of Portal.mc_organization.id values for merge
        SELECT  @mergingPortalIDs = STUFF (( SELECT ',' + CAST( portalID AS VARCHAR(20) )
                                               FROM #MergingOrganizations
                                              WHERE systemID = @systemID
                                                FOR XML PATH ('')),1,1,'') ;
                 
--  12) Merge data on non-core shield tables                      
        EXECUTE dbo.mergePortalOrganizations @systemName
                                                        , @MasterPortalID
                                                        , @mergingPortalIDs ;     
                                                        
--  13) UPDATE Master Core.Organizations and Master Portal.Organizations records
        UPDATE  Core.Organizations
           SET  UpdatedOn = SYSDATETIME() 
         WHERE  id = @MasterOrganizationID ;                                                                       
            
        UPDATE  Portal.Organizations
           SET  UpdatedOn = SYSDATETIME() 
         WHERE  id = @MasterOrganizationID AND systemID = @systemID ; 
        
        DELETE #portalData WHERE id = @systemID ;
        
     END
     
END 
