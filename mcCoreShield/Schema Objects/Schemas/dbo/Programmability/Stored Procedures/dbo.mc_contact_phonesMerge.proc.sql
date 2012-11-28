CREATE PROCEDURE dbo.mc_contact_phonesMerge ( @systemDBName AS NVARCHAR (50)
                                               , @recordsIN    AS INT
                                               , @errorMessage AS NVARCHAR (MAX) OUTPUT )
AS
/*
************************************************************************************************************************************

  Procedure:    dbo.mc_contact_emailsMerge
     Author:    Chris Carson
    Purpose:    Apply INSERTs and UPDATEs from portal to Core.ContactEmails and Portal.ContactEmails

    revisor     date            description
    ---------   -----------     ----------------------------
    ccarson     ###DATE###      created


    Logic Summary:

    1)  Assign new portalID to incoming records that are not already assigned
    2)  Add coreID fields for contactID, contactEmailsID, createdID, updatedID
    4)  Set incoming contactID to new values 
    3)  Set incoming contactEmailsID to existing Core.ContactEmails records when data matches
    4)  Set incoming createdID, updatedID to new values 
    5)  MERGE incoming data onto Core.ContactEmails
    6)  MERGE incoming data onto Portal.ContactEmails

    Notes:
    
    createdID and updatedID are set to AdminID because portal views do not contain audit information

    TODO    Determine error handling and control counts

************************************************************************************************************************************
*/
BEGIN

    SET NOCOUNT ON ;

    DECLARE @rows                        AS INT = 0
          , @coreContactEmailsUpdates    AS INT = 0
          , @portalContactEmailsInserts  AS INT = 0
          , @portalContactEmailsUpdates  AS INT = 0
          , @coreContactEmailsInserts    AS INT = 0
          , @legacyID                    AS INT = 0
          , @systemID                    AS INT = 0
          , @adminUser                   AS UNIQUEIDENTIFIER = N'00000000-0000-0000-0000-000000000000' ; 
          
    DECLARE @coreMergeResults   TABLE ( action NVARCHAR(10), id UNIQUEIDENTIFIER ) ; 
    DECLARE @portalMergeResults TABLE ( action NVARCHAR(10), id UNIQUEIDENTIFIER ) ; 


--  1)  Assign new portalID to incoming records that are not already assigned
    SELECT  @systemID = id
      FROM  dbo.Systems
     WHERE  systemDBName = @systemDBName ;

    SELECT  @legacyID = COALESCE( MAX( portalID ), 0 )
      FROM  Portal.ContactEmails
     WHERE  systemID = @systemID ;

    UPDATE  #mc_contact_emails
       SET  @legacyID = id = @legacyID + 1
     WHERE  id IS NULL ;


--  2)  Add coreID fields for contactAddressID, createdID, updatedID
    ALTER TABLE #mc_contact_emails ADD
        contactsID      UNIQUEIDENTIFIER NULL
      , contactEmailsID UNIQUEIDENTIFIER NULL DEFAULT NEWSEQUENTIALID()  WITH VALUES
      , createdID       UNIQUEIDENTIFIER NULL 
      , updatedID       UNIQUEIDENTIFIER NULL ;

--  4)  Set incoming contactID to new values 
    UPDATE  #mc_contact_emails
       SET  contactID = p.id
      FROM  #mc_contact_emails AS m
INNER JOIN  Portal.Contacts    AS p 
        ON  p.portalID = m.user_id 
            AND p.systemID = @systemID ;
    
--  3)  Set incoming contactEmailsID to existing Core.ContactEmails records when data matches
    UPDATE  #mc_contact_emails
       SET  contactEmailsID = e.id
      FROM  #mc_contact_emails AS m 
INNER JOIN  Core.ContactEmails AS e ON e.email = m.email ; 


--  4)  Set incoming createdID, updatedID to new values
    UPDATE  #mc_contact_emails
       SET  createdID  = @adminUser
          , updatedID  = @adminUser ;

          

--  5)  MERGE incoming data onto Core.ContactEmails
     MERGE  Core.ContactEmails AS tgt
     USING  #mc_contact_emails AS src
        ON  src.contactEmailsID = tgt.id
      WHEN  MATCHED
      THEN  UPDATE
               SET  contactsID  = src.contactsID     
                  , email       = src.email
                  , typeID      = src.type_id
                  , isDefault   = src.edefault        
                  , isActive    = src.active          
                  , isPublic    = src.epublic         
                  , isAlert     = src.alert           
                  , isEmergency = src.is_emergency    
                  , updatedOn   = SYSDATETIME()     
                  , updatedBy   = src.updatedID      

      WHEN  NOT MATCHED BY TARGET
      THEN  INSERT ( id, contactsID, email, typeID
                        , isDefault, isActive, isPublic
                        , isAlert, isEmergency 
                        , createdOn, createdBy )
            VALUES  ( src.contactEmailsID, src.contactsID, src.email, src.type_id
                        , src.edefault, src.active, src.epublic
                        , src.alert, src.is_emergency    
                        , SYSDATETIME(), src.createdID ) 
    OUTPUT  $action, inserted.id INTO @coreMergeResults ;
    SELECT  @rows = @@ROWCOUNT ;

    SELECT  @coreContactEmailsInserts = ( SELECT COUNT(*) FROM @coreMergeResults WHERE action = 'INSERT' )
          , @coreContactEmailsUpdates = ( SELECT COUNT(*) FROM @coreMergeResults WHERE action = 'UPDATE' ) ;

--        IF  ( @rows <> @recordsIN ) OR ( ( @organizationInserts + @organizationUpdates ) <> @recordsIN )
--        BEGIN
--            SELECT  @errorMessage = N'Error on dbo.Organizations MERGE' + CHAR(13) +
--                                    N'Records in were       : ' + CAST( @recordsIN           AS NVARCHAR(20) ) + CHAR(13) +
--                                    N'Records INSERTed were : ' + CAST( @organizationInserts AS NVARCHAR(20) ) + CHAR(13) +
--                                    N'Records UPDATEd were  : ' + CAST( @organizationUpdates AS NVARCHAR(20) ) + CHAR(13) +
--                                    N'Records MERGEd were   : ' + CAST( @rows                AS NVARCHAR(20) ) ;
--            RETURN 2 ;
--        END


--  6)  MERGE incoming data onto Portal.ContactEmails
     MERGE  Portal.ContactEmails AS tgt
     USING  #mc_contact_emails   AS src
        ON  src.contactEmailsID = tgt.id
      WHEN  MATCHED
      THEN  UPDATE
               SET  systemID    = @systemID
                  , updatedOn   = SYSDATETIME()
                  , updatedBy   = src.updatedID
                  , portalID    = src.id

      WHEN  NOT MATCHED BY TARGET
      THEN  INSERT ( id, systemID, createdOn, createdBy, portalID )
            VALUES ( src.contactEmailsID, @systemID, SYSDATETIME(), src.createID, src.id )
    OUTPUT  $action, inserted.id INTO @portalMergeResults ;
    SELECT  @rows = @@ROWCOUNT ;

    SELECT  @portalContactEmailsInserts = ( SELECT COUNT(*) FROM @portalMergeResults WHERE action = 'INSERT' )
          , @portalContactEmailsUpdates = ( SELECT COUNT(*) FROM @portalMergeResults WHERE action = 'UPDATE' ) ;


END
