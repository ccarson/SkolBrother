CREATE PROCEDURE dbo.merge_mc_contact_phones ( @systemDBName AS NVARCHAR (50)
                                             , @recordsIN    AS INT
                                             , @errorMessage AS NVARCHAR (MAX) OUTPUT )
AS
/*
************************************************************************************************************************************

  Procedure:    dbo.merge_mc_contact_phones
     Author:    Chris Carson
    Purpose:    Apply INSERTs and UPDATEs from portal to Core.ContactPhones and Portal.ContactPhones

    revisor     date            description
    ---------   -----------     ----------------------------
    ccarson     ###DATE###      created


    Logic Summary:

    1)  Assign new portalID to incoming records that are not already assigned
    2)  Add coreID fields for contactID, contactPhonesID, createdID, updatedID
    4)  Set incoming contactID to new values 
    3)  Set incoming contactPhonesID to existing Core.ContactPhones records when data matches
    4)  Set incoming createdID, updatedID to new values 
    5)  MERGE incoming data onto Core.ContactPhones
    6)  MERGE incoming data onto Portal.ContactPhones

    Notes:
    
    createdID and updatedID are set to AdminID because portal views do not contain audit information

    TODO    Determine error handling and control counts

************************************************************************************************************************************
*/
BEGIN

    SET NOCOUNT ON ;

    DECLARE @rows                        AS INT = 0
          , @coreContactPhonesUpdates    AS INT = 0
          , @portalContactPhonesInserts  AS INT = 0
          , @portalContactPhonesUpdates  AS INT = 0
          , @coreContactPhonesInserts    AS INT = 0
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
      FROM  Portal.ContactPhones
     WHERE  systemID = @systemID ;

    UPDATE  #mc_contact_phones
       SET  @legacyID = id = @legacyID + 1
     WHERE  id IS NULL ;


--  2)  Add coreID fields for contactAddressID, createdID, updatedID
    ALTER TABLE #mc_contact_phones ADD
        contactsID      UNIQUEIDENTIFIER NULL
      , contactPhonesID UNIQUEIDENTIFIER NULL DEFAULT NEWSEQUENTIALID()  WITH VALUES
      , createdID       UNIQUEIDENTIFIER NULL 
      , updatedID       UNIQUEIDENTIFIER NULL ;

--  4)  Set incoming contactID to new values 
    UPDATE  #mc_contact_phones
       SET  contactID = p.id
      FROM  #mc_contact_phones AS m
INNER JOIN  Portal.Contacts    AS p ON p.portalID = m.user_id AND p.systemID = @systemID ;
    
--  3)  Set incoming contactPhonesID to existing Core.ContactPhones records when data matches
    UPDATE  #mc_contact_phones
       SET  contactPhonesID = p.id
      FROM  #mc_contact_phones AS m 
INNER JOIN  Core.ContactPhones AS p ON p.contactsID = m.contactsID AND p.phone = m.phone AND p.extension = m.extension ; 


--  4)  Set incoming createdID, updatedID to new values
    UPDATE  #mc_contact_phones
       SET  createdID  = @adminUser
          , updatedID  = @adminUser ;

          

--  5)  MERGE incoming data onto Core.ContactPhones
     MERGE  Core.ContactPhones AS tgt
     USING  #mc_contact_phones AS src
        ON  src.contactPhonesID = tgt.id
      WHEN  MATCHED
      THEN  UPDATE SET contactsID  = src.contactsID 
                     , phone       = src.phone           
                     , extension   = src.extension       
                     , typeID      = src.type_id         
                     , isDefault   = src.edefault        
                     , isActive    = src.active          
                     , isPublic    = src.epublic         
                     , isAlert     = src.alert           
                     , isEmergency = src.is_emergency    
                     , updatedOn   = SYSDATETIME()     
                     , updatedBy   = src.updatedID      

      WHEN  NOT MATCHED BY TARGET
      THEN  INSERT ( id, contactsID, phone, extension, typeID
                        , isDefault, isActive, isPublic, isAlert
                        , isEmergency, createdOn, createdBy ) 
            VALUES ( src.contactPhonesID, src.contactsID, src.phone, src.extension, src.type_id 
                        , src.edefault, src.active, src.epublic, src.alert
                        , src.is_emergency, SYSDATETIME(), src.createdID ) 
    OUTPUT  $action, inserted.id INTO @coreMergeResults ;
    SELECT  @rows = @@ROWCOUNT ;

    SELECT  @coreContactPhonesInserts = ( SELECT COUNT(*) FROM @coreMergeResults WHERE action = 'INSERT' )
          , @coreContactPhonesUpdates = ( SELECT COUNT(*) FROM @coreMergeResults WHERE action = 'UPDATE' ) ;

--        IF  ( @rows <> @recordsIN ) OR ( ( @organizationInserts + @organizationUpdates ) <> @recordsIN )
--        BEGIN
--            SELECT  @errorMessage = N'Error on dbo.Organizations MERGE' + CHAR(13) +
--                                    N'Records in were       : ' + CAST( @recordsIN           AS NVARCHAR(20) ) + CHAR(13) +
--                                    N'Records INSERTed were : ' + CAST( @organizationInserts AS NVARCHAR(20) ) + CHAR(13) +
--                                    N'Records UPDATEd were  : ' + CAST( @organizationUpdates AS NVARCHAR(20) ) + CHAR(13) +
--                                    N'Records MERGEd were   : ' + CAST( @rows                AS NVARCHAR(20) ) ;
--            RETURN 2 ;
--        END


--  6)  MERGE incoming data onto Portal.ContactPhones
     MERGE  Portal.ContactPhones AS tgt
     USING  #mc_contact_phones   AS src
        ON  src.contactPhonesID = tgt.id
      WHEN  MATCHED
      THEN  UPDATE
               SET  systemID    = @systemID
                  , updatedOn   = SYSDATETIME()
                  , updatedBy   = src.updatedID
                  , portalID    = src.id

      WHEN  NOT MATCHED BY TARGET
      THEN  INSERT ( id, systemID, createdOn, createdBy, portalID )
            VALUES ( src.contactPhonesID, @systemID, SYSDATETIME(), src.createID, src.id )
    OUTPUT  $action, inserted.id INTO @portalMergeResults ;
    SELECT  @rows = @@ROWCOUNT ;

    SELECT  @portalContactPhonesInserts = ( SELECT COUNT(*) FROM @portalMergeResults WHERE action = 'INSERT' )
          , @portalContactPhonesUpdates = ( SELECT COUNT(*) FROM @portalMergeResults WHERE action = 'UPDATE' ) ;


END
