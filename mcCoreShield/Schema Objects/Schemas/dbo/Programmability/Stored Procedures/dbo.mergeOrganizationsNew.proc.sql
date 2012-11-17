CREATE PROCEDURE dbo.mergeOrganizationsNew ( @MasterOrganizationID    AS UNIQUEIDENTIFIER 
                                           , @MasterOrganizationName  AS NVARCHAR(4000) ) 
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
    1)  SELECT Core.Organizations that match on MasterOrganizationName into temp storage
    2)  SELECT Portal.Organizations that match Organizations from 1) into temp storage
    3)  SELECT systemIDs from temp storage into temp storage
    4)  For each system ID --
    5)  UPDATE one Portal.Organizations record to MasterOrganizationID if MasterOrganization does not have Portal.Organizations record for systemID 
    6)  SELECT portalID that will be merged into into variable
    6)  SELECT portalID for will be merged from into temp storage
    7)  Merge coreShield tables
    8)  Drop Portal.Organizations records for merged records
    9)  Mark Core.Organizations records as merged
   12)  Merge data on non-core shield tables                      
   13)  UPDATE Master Core.Organizations and Master Portal.Organizations records
   14)  process next systemID


************************************************************************************************************************************
*/
BEGIN

    SET NOCOUNT ON ; 
    
    DECLARE @systemID AS INT ; 
    DECLARE @systemName AS NVARCHAR(20) ; 
    DECLARE @MasterPortalID AS INT ; 
    DECLARE @rc AS INT; 
    
--  1)  Append wild card to incoming @MasterOrganizationName     
    -- SELECT  @MasterOrganizationName = @MasterOrganizationName

--  2)  SELECT core Organizations that match on MasterOrganizationName into temp storage
    IF  OBJECT_ID('tempdb..#Organizations') IS NOT NULL
        DROP TABLE #Organizations ;
        
    SELECT * INTO #Organizations FROM Core.Organizations WHERE 1=0 ; 
    
    IF  CHARINDEX( '%', @MasterOrganizationName ) > 0 
        INSERT  #Organizations
        SELECT  * 
          FROM  Core.Organizations
         WHERE  name like @MasterOrganizationName AND id <> @MasterOrganizationID ; 
    ELSE 
        INSERT #Organizations
        SELECT  * 
          FROM  Core.Organizations
         WHERE  name = @MasterOrganizationName AND id <> @MasterOrganizationID ; 
     
--  5)  For each system ID --
    WHILE EXISTS ( SELECT 1 FROM Portal.Organizations AS os
                    INNER JOIN #Organizations AS o on o.id = os.id ) 
    BEGIN 
    
        SELECT  TOP 1 
                @systemID   = s.id 
              , @systemName = s.systemName
          FROM  Portal.Organizations AS os
    INNER JOIN  #Organizations AS o
            ON  o.id = os.id 
    INNER JOIN  dbo.transitionSystems AS s 
            ON  s.id = os.systemID ; 
            
--  6)  UPDATE one OrganizationSystems record to MasterOrganizationID if MasterOrganization does not have OrganizationSystems record for systemID 
     
          WITH  newRecord AS ( 
                SELECT  os.id 
                      , N = ROW_NUMBER() OVER ( ORDER BY portalID ) 
                  FROM  Portal.Organizations AS os 
            INNER JOIN  #Organizations AS o ON o.id = os.id 
                 WHERE  systemID = @systemID ) 
                 
        UPDATE  Portal.Organizations
           SET  id = @MasterOrganizationID
          FROM  Portal.Organizations AS os
    INNER JOIN  newRecord AS n on n.id = os.id 
                AND os.systemID = @systemID AND n.N = 1 
         WHERE  NOT EXISTS ( SELECT 1 FROM Portal.Organizations
                              WHERE id = @MasterOrganizationID AND systemID = @systemID ) ; 
                      
        SELECT  @MasterPortalID = portalID
          FROM  Portal.Organizations
         WHERE  id = @MasterOrganizationID AND systemID = @systemID ; 
         
        IF  OBJECT_ID( 'tempdb..#portalIDs' ) IS NOT NULL   
            DROP TABLE #portalIDs ; 
            
        SELECT  DISTINCT org_id = portalID
          INTO  #portalIDs 
          FROM  Portal.Organizations AS os
         WHERE  EXISTS ( SELECT 1 from #Organizations AS o 
                          WHERE o.id = os.id ) 
                AND os.systemID = @systemID ; 
        
--  7)  Merge coreShield tables
        EXECUTE dbo.mergeCoreOrganizationsNew @systemID
                                                         , @systemName
                                                         , @MasterOrganizationID ; 
                                                                
--  8)  Drop Portal.Organizations records for merged records
        DELETE  Portal.Organizations
          FROM  Portal.Organizations AS a
         WHERE  EXISTS ( SELECT 1 FROM #Organizations AS b
                          WHERE b.id = a.id ) 
                AND a.systemID = @systemID ; 
                                    
--  9)  Mark Core.Organizations records as merged
        UPDATE  Core.Organizations
           SET  name      = name + ' ## MERGED ## ' 
              , isActive  = 0 
              , UpdatedOn = SYSDATETIME()
          FROM  Core.Organizations AS a
         WHERE  EXISTS ( SELECT 1 FROM #Organizations AS b ) 
           AND  NOT EXISTS ( SELECT 1 FROM Portal.Organizations AS os WHERE os.id = a.id ) 
           AND  name not like '%## MERGED ## ' ;
           
--  12) Merge data on non-core shield tables                      
        EXECUTE @rc = dbo.mergePortalOrganizationsNew @systemName
                                                                 , @MasterPortalID ;
        IF  @rc <> 0 
            RETURN @rc ;
        
                                                        
--  13) UPDATE Master Core.Organizations and Master Portal.Organizations records
        UPDATE  Core.Organizations
           SET  UpdatedOn = SYSDATETIME() 
         WHERE  id = @MasterOrganizationID ;                                                                       
            
        UPDATE  Portal.Organizations
           SET  UpdatedOn = SYSDATETIME() 
         WHERE  id = @MasterOrganizationID AND systemID = @systemID ; 
        
     END
     
END
