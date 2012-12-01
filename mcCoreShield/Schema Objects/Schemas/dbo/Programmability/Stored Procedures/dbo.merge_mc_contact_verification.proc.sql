CREATE PROCEDURE dbo.merge_mc_contact_verification ( @systemDBName AS NVARCHAR (50)
                                                   , @recordsIN    AS INT
                                                   , @errorMessage AS NVARCHAR (MAX) OUTPUT )
AS
/*
************************************************************************************************************************************

  Procedure:    dbo.merge_mc_contact_verification
     Author:    Chris Carson
    Purpose:    Apply INSERTs and UPDATEs from portal to Core.ContactVerifications and Portal.ContactVerifications

    revisor     date            description
    ---------   -----------     ----------------------------
    ccarson     ###DATE###      created


    Logic Summary:

    1)  Assign new portalID to incoming records that are not already assigned
    2)  Add coreID fields for contactID, contactVerificationsID, createdID, updatedID
    4)  Set incoming contactID to new values
    3)  Set incoming contactVerificationsID to existing Core.ContactVerifications records when data matches
    4)  Set incoming createdID, updatedID to new values
    5)  MERGE incoming data onto Core.ContactVerifications
    6)  MERGE incoming data onto Portal.ContactVerifications

    Notes:

    createdID and updatedID are set to AdminID because portal views do not contain audit information

    TODO    Determine error handling and control counts

************************************************************************************************************************************
*/
BEGIN

    SET NOCOUNT ON ;

    DECLARE @rows                        AS INT = 0
          , @coreContactVerificationsUpdates    AS INT = 0
          , @portalContactVerificationsInserts  AS INT = 0
          , @portalContactVerificationsUpdates  AS INT = 0
          , @coreContactVerificationsInserts    AS INT = 0
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
      FROM  Portal.ContactVerifications
     WHERE  systemID = @systemID ;

    UPDATE  #mc_contact_verification
       SET  @legacyID = id = @legacyID + 1
     WHERE  id IS NULL ;


--  2)  Add coreID fields for contactAddressID, createdID, updatedID
    ALTER TABLE #mc_contact_verification ADD
        contactsID              UNIQUEIDENTIFIER NULL
      , contactVerificationsID  UNIQUEIDENTIFIER NULL DEFAULT NEWSEQUENTIALID()  WITH VALUES
      , verifiedID              UNIQUEIDENTIFIER NULL ;

--  4)  Set incoming contactID to new values
    UPDATE  #mc_contact_verification
       SET  contactID  = p.id
          , verifiedID = COALESCE( v.id, @adminUser )
      FROM  #mc_contact_verification    AS m
INNER JOIN  Portal.Contacts             AS p ON p.portalID = m.user_id     AND p.systemID = @systemID
 LEFT JOIN  Portal.ContactVerifications AS v ON v.portalID = m.verified_by AND v.systemID = @systemID ;


--  5)  MERGE incoming data onto Core.ContactVerifications
     MERGE  Core.ContactVerifications AS tgt
     USING  #mc_contact_verification AS src
        ON  src.contactVerificationsID = tgt.id
      WHEN  MATCHED
      THEN  UPDATE SET  contactsID  = src.user_id
                      , verifiedBy  = src.verified_date
                      , verifiedOn  = src.verifiedID
                      , updatedOn   = SYSDATETIME()
                      , updatedBy   = src.verifiedID

      WHEN  NOT MATCHED BY TARGET
      THEN  INSERT  ( id, contactsID
                        , verifiedBy, verifiedOn
                        , createdOn, createdBy ) 
            VALUES  ( src.contactVerificationsID, src.contactsID
                        , src.verified_date, src.verifiedID
                        , SYSDATETIME(), src.verifiedID ) 
    OUTPUT  $action, inserted.id INTO @coreMergeResults ;
    SELECT  @rows = @@ROWCOUNT ;

    SELECT  @coreContactVerificationsInserts = ( SELECT COUNT(*) FROM @coreMergeResults WHERE action = 'INSERT' )
          , @coreContactVerificationsUpdates = ( SELECT COUNT(*) FROM @coreMergeResults WHERE action = 'UPDATE' ) ;

--        IF  ( @rows <> @recordsIN ) OR ( ( @organizationInserts + @organizationUpdates ) <> @recordsIN )
--        BEGIN
--            SELECT  @errorMessage = N'Error on dbo.Organizations MERGE' + CHAR(13) +
--                                    N'Records in were       : ' + CAST( @recordsIN           AS NVARCHAR(20) ) + CHAR(13) +
--                                    N'Records INSERTed were : ' + CAST( @organizationInserts AS NVARCHAR(20) ) + CHAR(13) +
--                                    N'Records UPDATEd were  : ' + CAST( @organizationUpdates AS NVARCHAR(20) ) + CHAR(13) +
--                                    N'Records MERGEd were   : ' + CAST( @rows                AS NVARCHAR(20) ) ;
--            RETURN 2 ;
--        END


--  6)  MERGE incoming data onto Portal.ContactVerifications
     MERGE  Portal.ContactVerifications AS tgt
     USING  #mc_contact_verification    AS src
        ON  src.contactVerificationsID = tgt.id
      WHEN  MATCHED
      THEN  UPDATE
               SET  systemID    = @systemID
                  , updatedOn   = SYSDATETIME()
                  , updatedBy   = src.updatedID
                  , portalID    = src.id

      WHEN  NOT MATCHED BY TARGET
      THEN  INSERT ( id, systemID, createdOn, createdBy, portalID )
            VALUES ( src.contactVerificationsID, @systemID, SYSDATETIME(), src.createdID, src.id )
    OUTPUT  $action, inserted.id INTO @portalMergeResults ;
    SELECT  @rows = @@ROWCOUNT ;

    SELECT  @portalContactVerificationsInserts = ( SELECT COUNT(*) FROM @portalMergeResults WHERE action = 'INSERT' )
          , @portalContactVerificationsUpdates = ( SELECT COUNT(*) FROM @portalMergeResults WHERE action = 'UPDATE' ) ;


END
