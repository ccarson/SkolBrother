CREATE PROCEDURE dbo.merge_mc_contact_notes ( @systemDBName AS NVARCHAR (50)
                                            , @recordsIN    AS INT
                                            , @errorMessage AS NVARCHAR (MAX) OUTPUT )
AS
/*
************************************************************************************************************************************

  Procedure:    dbo.merge_mc_contact_notes
     Author:    Chris Carson
    Purpose:    Apply INSERTs and UPDATEs from portal to Core.ContactNotes and Portal.ContactNotes

    revisor     date            description
    ---------   -----------     ----------------------------
    ccarson     ###DATE###      created


    Logic Summary:

    1)  Assign new portalID to incoming records that are not already assigned
    2)  Add coreID fields for contactID, contactEmailsID, createdID, updatedID
    4)  Set incoming contactID to new values 
    3)  Set incoming contactEmailsID to existing Core.ContactNotes records when data matches
    4)  Set incoming createdID, updatedID to new values 
    5)  MERGE incoming data onto Core.ContactNotes
    6)  MERGE incoming data onto Portal.ContactNotes

    Notes:
    
    createdID and updatedID are set to AdminID because portal views do not contain audit information

    TODO    Determine error handling and control counts

************************************************************************************************************************************
*/
BEGIN

    SET NOCOUNT ON ;

    DECLARE @rows                        AS INT = 0
          , @coreContactNotesUpdates    AS INT = 0
          , @portalContactNotesInserts  AS INT = 0
          , @portalContactNotesUpdates  AS INT = 0
          , @coreContactNotesInserts    AS INT = 0
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
      FROM  Portal.ContactNotes
     WHERE  systemID = @systemID ;

    UPDATE  #mc_contact_notes
       SET  @legacyID = id = @legacyID + 1
     WHERE  id IS NULL ;


--  2)  Add coreID fields for contactAddressID, createdID, updatedID
    ALTER TABLE #mc_contact_notes ADD
        contactsID      UNIQUEIDENTIFIER NULL
      , contactNotesID  UNIQUEIDENTIFIER NULL DEFAULT NEWSEQUENTIALID() WITH VALUES
      , adminID         UNIQUEIDENTIFIER NULL
      , createdID       UNIQUEIDENTIFIER NULL 
      , updatedID       UNIQUEIDENTIFIER NULL ;

--  3)  Set incoming coreIDs to new values 
    UPDATE  #mc_contact_notes
       SET  contactID = p.id
          , adminID   = COALESCE( a.id, @adminUser )
      FROM  #mc_contact_notes AS m
INNER JOIN  Portal.Contacts   AS p ON p.portalID = m.user_id  AND p.systemID = @systemID
 LEFT JOIN  Portal.Contacts   AS a ON a.portalID = m.admin_id AND a.systemID = @systemID ; 
    
--  3)  Set incoming contactEmailsID to existing Core.ContactNotes records when data matches
    UPDATE  #mc_contact_notes
       SET  contactNotesID = n.id 
      FROM  #mc_contact_notes   AS m 
INNER JOIN  Core.ContactNotes   AS n ON n.typeID = m.type_id AND n.contactsID = m.contactsID ; 


--  4)  Set incoming createdID, updatedID to new values
    UPDATE  #mc_contact_notes
       SET  createdID  = adminID
          , updatedID  = adminID ;
          

--  5)  MERGE incoming data onto Core.ContactNotes
     MERGE  Core.ContactNotes AS tgt
     USING  #mc_contact_notes AS src
        ON  src.contactNotesID = tgt.id
      WHEN  MATCHED
      THEN  UPDATE
               SET  contactsID       = src.contactsID     
                  , typeID           = src.type_ID
                  , adminID          = src.adminID
                  , notes            = src.notes
                  , updatedOn        = SYSDATETIME()
                  , updatedBy        = src.updatedID

      WHEN  NOT MATCHED BY TARGET
      THEN  INSERT  ( id, contactsID, typeID, adminID
                        , notes, createdOn, createdBy ) 
            VALUES  ( src.contactNotesID, src.contactsID, src.type_id, src.adminID
                        , src.notes, src.DateAdded, src.createdID ) 
    OUTPUT  $action, inserted.id INTO @coreMergeResults ;
    SELECT  @rows = @@ROWCOUNT ;

    SELECT  @coreContactNotesInserts = ( SELECT COUNT(*) FROM @coreMergeResults WHERE action = 'INSERT' )
          , @coreContactNotesUpdates = ( SELECT COUNT(*) FROM @coreMergeResults WHERE action = 'UPDATE' ) ;

--        IF  ( @rows <> @recordsIN ) OR ( ( @organizationInserts + @organizationUpdates ) <> @recordsIN )
--        BEGIN
--            SELECT  @errorMessage = N'Error on dbo.Organizations MERGE' + CHAR(13) +
--                                    N'Records in were       : ' + CAST( @recordsIN           AS NVARCHAR(20) ) + CHAR(13) +
--                                    N'Records INSERTed were : ' + CAST( @organizationInserts AS NVARCHAR(20) ) + CHAR(13) +
--                                    N'Records UPDATEd were  : ' + CAST( @organizationUpdates AS NVARCHAR(20) ) + CHAR(13) +
--                                    N'Records MERGEd were   : ' + CAST( @rows                AS NVARCHAR(20) ) ;
--            RETURN 2 ;
--        END


--  6)  MERGE incoming data onto Portal.ContactNotes
     MERGE  Portal.ContactNotes AS tgt
     USING  #mc_contact_notes   AS src
        ON  src.contactNotesID = tgt.id
      WHEN  MATCHED
      THEN  UPDATE
               SET  systemID    = @systemID
                  , updatedOn   = SYSDATETIME()
                  , updatedBy   = src.updatedID
                  , portalID    = src.id

      WHEN  NOT MATCHED BY TARGET
      THEN  INSERT ( id, systemID, createdOn, createdBy, portalID )
            VALUES ( src.contactNotesID, @systemID, SYSDATETIME(), src.createdID, src.id )
    OUTPUT  $action, inserted.id INTO @portalMergeResults ;
    SELECT  @rows = @@ROWCOUNT ;

    SELECT  @portalContactNotesInserts = ( SELECT COUNT(*) FROM @portalMergeResults WHERE action = 'INSERT' )
          , @portalContactNotesUpdates = ( SELECT COUNT(*) FROM @portalMergeResults WHERE action = 'UPDATE' ) ;


END
