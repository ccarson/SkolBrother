CREATE PROCEDURE dbo.mc_contact_addressesMerge ( @systemDBName AS NVARCHAR (50)
                                               , @recordsIN    AS INT
                                               , @errorMessage AS NVARCHAR (MAX) OUTPUT )
AS
/*
************************************************************************************************************************************

  Procedure:    dbo.mc_contact_addressesMerge
     Author:    Chris Carson
    Purpose:    Apply INSERTs and UPDATEs from portal to Core.ContactAddresses and Portal.ContactAddresses

    revisor     date            description
    ---------   -----------     ----------------------------
    ccarson     ###DATE###      created


    Logic Summary:

    1)  Assign new portalID to incoming records that are not already assigned
    2)  Add coreID fields for contactID, contactAddressID, createdID, updatedID
    4)  Set incoming contactID to new values 
    3)  Set incoming contactAddressID to existing Core.ContactAddresses records when data matches
    4)  Set incoming createdID, updatedID to new values 
    5)  MERGE incoming data onto Core.ContactAddresses
    6)  MERGE incoming data onto Portal.ContactAddresses

    Notes:
    
    createdID and updatedID are set to AdminID because portal views do not contain audit information

    TODO    Determine match criteria for updating addresses
            Determine error handling and control counts

************************************************************************************************************************************
*/
BEGIN

    SET NOCOUNT ON ;

    DECLARE @rows                           AS INT = 0
          , @coreContactAddressesUpdates    AS INT = 0
          , @portalContactAddressesInserts  AS INT = 0
          , @portalContactAddressesUpdates  AS INT = 0
          , @coreContactAddressesInserts    AS INT = 0
          , @legacyID                       AS INT = 0
          , @systemID                       AS INT = 0
          , @adminUser                      AS UNIQUEIDENTIFIER = N'00000000-0000-0000-0000-000000000000' ; 
          
    DECLARE @coreMergeResults   TABLE ( action NVARCHAR(10), id UNIQUEIDENTIFIER ) ; 
    DECLARE @portalMergeResults TABLE ( action NVARCHAR(10), id UNIQUEIDENTIFIER ) ; 


--  1)  Assign new portalID to incoming records that are not already assigned
    SELECT  @systemID = id
      FROM  dbo.Systems
     WHERE  systemDBName = @systemDBName ;

    SELECT  @legacyID = COALESCE( MAX( portalID ), 0 )
      FROM  Portal.ContactAddresses
     WHERE  systemID = @systemID ;

    UPDATE  #mc_contact_addresses
       SET  @legacyID = id = @legacyID + 1
     WHERE  id IS NULL ;


--  2)  Add coreID fields for contactAddressID, createdID, updatedID
    ALTER TABLE #mc_contact_addresses ADD
        contactsID          UNIQUEIDENTIFIER NULL
      , contactAddressID    UNIQUEIDENTIFIER NULL DEFAULT NEWSEQUENTIALID()  WITH VALUES
      , createdID           UNIQUEIDENTIFIER NULL 
      , updatedID           UNIQUEIDENTIFIER NULL ;

--  4)  Set incoming contactID to new values 
    UPDATE  #mc_contact_addresses
       SET  contactID = p.id
      FROM  #mc_contact_addresses AS m
INNER JOIN  Portal.Contacts       AS p 
        ON  p.portalID = m.user_id 
            AND p.systemID = @systemID ;
    
--  3)  Set incoming contactAddressID to existing Core.ContactAddresses records when data matches
         


--  4)  Set incoming createdID, updatedID to new values
    UPDATE  #mc_contact_addresses
       SET  createdID  = @adminUser
          , updatedID  = @adminUser ;

          

--  5)  MERGE incoming data onto Core.ContactAddresses
     MERGE  Core.ContactAddresses AS tgt
     USING  #mc_contact_addresses AS src
        ON  src.contactAddressID = tgt.id
      WHEN  MATCHED
      THEN  UPDATE
               SET  addressName    = src.name    
                  , contactsID     = src.contactsID     
                  , addressType    = src.add_type    
                  , address1       = src.address1       
                  , address2       = src.address2       
                  , address3       = src.address3       
                  , city           = src.city           
                  , state          = src.state          
                  , zip            = src.zip            
                  , country        = src.country        
                  , isDefault      = src.defaultAddress      
                  , createdOn      = createdDate    
                  , createdBy      = src.createdID
                  , updatedOn      = SYSDATETIME()     
                  , updatedBy      = src.updatedID      

      WHEN  NOT MATCHED BY TARGET
      THEN  INSERT ( id, addressName, contactsID, addressType
                        , address1, address2, address3, city
                        , state, zip, country, isDefault
                        , createdOn, createdBy )
            VALUES  ( src.contactAddressID
                        , src.name, src.contactsID, src.add_type    
                        , src.address1, src.address2, src.address3, src.city
                        , src.state, src.zip, src.country, src.defaultAddress
                        , createdDate, src.createdID ) 
    OUTPUT  $action, inserted.id INTO @coreMergeResults ;
    SELECT  @rows = @@ROWCOUNT ;

    SELECT  @coreContactAddressesInserts = ( SELECT COUNT(*) FROM @coreMergeResults WHERE action = 'INSERT' )
          , @coreContactAddressesUpdates = ( SELECT COUNT(*) FROM @coreMergeResults WHERE action = 'UPDATE' ) ;

--        IF  ( @rows <> @recordsIN ) OR ( ( @organizationInserts + @organizationUpdates ) <> @recordsIN )
--        BEGIN
--            SELECT  @errorMessage = N'Error on dbo.Organizations MERGE' + CHAR(13) +
--                                    N'Records in were       : ' + CAST( @recordsIN           AS NVARCHAR(20) ) + CHAR(13) +
--                                    N'Records INSERTed were : ' + CAST( @organizationInserts AS NVARCHAR(20) ) + CHAR(13) +
--                                    N'Records UPDATEd were  : ' + CAST( @organizationUpdates AS NVARCHAR(20) ) + CHAR(13) +
--                                    N'Records MERGEd were   : ' + CAST( @rows                AS NVARCHAR(20) ) ;
--            RETURN 2 ;
--        END


--  6)  MERGE incoming data onto Portal.Contacts
     MERGE  Portal.ContactAddresses AS tgt
     USING  #mc_contact_addresses   AS src
        ON  src.contactAddressID = tgt.id
      WHEN  MATCHED
      THEN  UPDATE
               SET  systemID    = @systemID
                  , createdOn   = src.createdDate
                  , createdBy   = src.createdID
                  , updatedOn   = SYSDATETIME()
                  , updatedBy   = src.updatedID
                  , portalID    = src.id

      WHEN  NOT MATCHED BY TARGET
      THEN  INSERT ( id, systemID, createdOn, createdBy, portalID )
            VALUES ( src.contactAddressID, src.systemID, src.createdDate, src.createID, src.id )
    OUTPUT  $action, inserted.id INTO @portalMergeResults ;
    SELECT  @rows = @@ROWCOUNT ;

    SELECT  @portalContactAddressesInserts = ( SELECT COUNT(*) FROM @portalMergeResults WHERE action = 'INSERT' )
          , @portalContactAddressesUpdates = ( SELECT COUNT(*) FROM @portalMergeResults WHERE action = 'UPDATE' ) ;


END
