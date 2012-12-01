CREATE PROCEDURE dbo.merge_mc_contact ( @systemDBName AS NVARCHAR (50)
                                      , @recordsIN    AS INT
                                      , @errorMessage AS NVARCHAR (MAX) OUTPUT )
AS
/*
************************************************************************************************************************************

  Procedure:    dbo.merge_mc_contact
     Author:    Chris Carson
    Purpose:    Apply INSERTs and UPDATEs from portal to Core.Contacts and Portal.Contacts

    revisor     date            description
    ---------   -----------     ----------------------------
    ccarson     ###DATE###      created


    Logic Summary:

    1)  Assign new portalID to incoming records that are not already assigned
    2)  Add coreID fields for contactID, createdID, updatedID, verifiedID
    3)  Set incoming contactID to existing Core.Contacts records when data matches
    4)  Set incoming createdID, updatedID, verifiedID to new values
    5)  MERGE incoming data onto Core.Contacts
    6)  MERGE incoming data onto Portal.Contacts

    Notes:

    TODO    Determine logic for matching Contacts
            Determine error handling and control counts

************************************************************************************************************************************
*/
BEGIN

    SET NOCOUNT ON ;

    DECLARE @updated            AS INT = 0
          , @rows               AS INT = 0
          , @coreContactInserts     AS INT = 0
          , @coreContactUpdates     AS INT = 0
          , @portalContactInserts     AS INT = 0
          , @portalContactUpdates     AS INT = 0
          , @legacyID           AS INT = 0
          , @inserted           AS INT = 0
          , @deleted            AS INT = 0
          , @systemID           AS INT = 0
          , @adminUser          AS UNIQUEIDENTIFIER = N'00000000-0000-0000-0000-000000000000' ; 
          
    DECLARE @coreMergeResults   TABLE ( action NVARCHAR(10), id UNIQUEIDENTIFIER ) ; 
    DECLARE @portalMergeResults TABLE ( action NVARCHAR(10), id UNIQUEIDENTIFIER ) ; 


--  1)  Assign new portalID to incoming records that are not already assigned
    SELECT  @systemID = id
      FROM  dbo.Systems
     WHERE  systemDBName = @systemDBName ;

    SELECT  @legacyID = COALESCE( MAX( portalID ), 0 )
      FROM  Portal.Contacts
     WHERE  systemID = @systemID ;

    UPDATE  #mc_contact
       SET  @legacyID = id = @legacyID + 1
     WHERE  id IS NULL ;


--  2)  Add coreID fields for contactID, createdID, updatedID, verifiedID
    ALTER TABLE #mc_contact ADD
        contactID   UNIQUEIDENTIFIER NULL DEFAULT NEWSEQUENTIALID()  WITH VALUES
      , createdID   UNIQUEIDENTIFIER NULL
      , updatedID   UNIQUEIDENTIFIER NULL
      , verifiedID  UNIQUEIDENTIFIER NULL ;


--  3)  Set incoming contactID to existing Core.Contacts records when data matches


--  4)  Set incoming createdID, updatedID, verifiedID to new values
      WITH  newIDs AS (
            SELECT  id        = portalID
                  , ContactID = id
              FROM  Portal.Contacts WHERE systemID = @systemID
                UNION
            SELECT  id        = id
                  , ContactID = contactID
              FROM  #mc_contact )

    UPDATE  #mc_contact
       SET  createdID  = c.ContactID
          , updatedID  = u.ContactID
          , verifiedID = v.ContactID
      FROM  #mc_contact AS m
 LEFT JOIN  newIDs      AS c ON m.AddedBy     = c.id
 LEFT JOIN  newIDs      AS u ON m.ModifiedBy  = u.id
 LEFT JOIN  newIDs      AS v ON m.iVerifiedBy = v.id ;


--  5)  MERGE incoming data onto Core.Contacts
     MERGE  Core.Contacts AS tgt
     USING  #mc_contact   AS src
        ON  src.contactID = tgt.id
      WHEN  MATCHED
      THEN  UPDATE
               SET  salutation      = src.Salutation
                  , jobTitle        = src.JobTitle
                  , firstName       = src.Firstname
                  , initial         = src.Initial
                  , lastName        = src.Lastname
                  , suffix          = src.Suffix
                  , email           = src.Email
                  , login           = src.Login
                  , password        = src.Password
                  , salt            = src.salt
                  , accessID        = src.AccessID
                  , expires         = src.Expires
                  , hits            = src.Hits
                  , lastLogin       = src.LastLogin
                  , status          = src.Status
                  , datejoined      = src.datejoined
                  , membertype      = src.membertype
                  , photo           = src.photo
                  , resume          = src.resume
                  , thumb           = src.thumb
                  , PIN             = src.PIN
                  , reset           = src.reset
                  , mailsent        = src.mailsent
                  , sysmember       = src.sysmember
                  , maildate        = src.maildate
                  , updatesent      = src.updatesent
                  , updatenum       = src.updatenum
                  , nosend          = src.nosend
                  , hidden          = src.hidden
                  , securityLevel   = src.security_level
                  , review          = src.review
                  , q1              = src.Q1
                  , q2              = src.Q2
                  , q3              = src.Q3
                  , iAnswer         = src.iAnswer
                  , ipMac           = src.ipMac
                  , frequencyID     = src.frequency_id
                  , refer           = src.refer
                  , isActive        = src.is_active
                  , timeZone        = src.TimeZone
                  , usesDaylight    = src.usesDaylight
                  , tzOffset        = src.TzOffset
                  , iDefaultQuota   = src.iDefault_Quota
                  , iDocUsage       = src.iDoc_Usage
                  , assistID        = src.assist_id
                  , layout          = src.layout
                  , bTOS            = src.bTOS
                  , bOnlineNow      = src.bOnlineNow
                  , uID             = src.uID
                  , iwkgrplayout    = src.iwkgrplayout
                  , sAboutMe        = src.sAboutMe
                  , folderID        = src.folder_id
                  , signature       = src.signature
                  , bAuditLock      = src.bAuditLock
                  , bProfileUpdate  = src.bProfileUpdate
                  , bexpirereminder = src.bexpirereminder
                  , bPingSent       = src.bPingSent
                  , dPingDate       = src.dPingDate
                  , inetwork        = src.inetwork
                  , createdBy       = src.createdID
                  , createdOn       = src.dateAdded
                  , updatedBy       = src.updatedID
                  , updatedOn       = src.DateModified

      WHEN  NOT MATCHED BY TARGET
      THEN  INSERT ( id, salutation, jobTitle, firstName, initial, lastName, suffix
                        , email, login, password, salt, accessID, expires, hits, lastLogin
                        , status, datejoined, membertype, photo, resume, thumb, PIN, reset
                        , mailsent, sysmember, maildate, updatesent, updatenum, nosend
                        , hidden, securityLevel, review, q1, q2, q3, iAnswer, ipMac
                        , frequencyID, refer, isActive, timeZone, usesDaylight, tzOffset
                        , iDefaultQuota, iDocUsage, assistID, layout, bTOS, bOnlineNow
                        , uID, iwkgrplayout, sAboutMe, folderID, signature, bAuditLock
                        , bProfileUpdate, bexpirereminder, bPingSent, dPingDate, inetwork
                        , createdOn, createdBy, updatedOn, updatedBy )
            VALUES  ( src.contactID, src.salutation, src.jobTitle, src.firstName, src.initial, src.lastName, src.suffix
                        , src.email, src.login, src.password, src.salt, src.accessID, src.expires, src.hits, src.lastLogin
                        , src.status, src.datejoined, src.membertype, src.photo, src.resume, src.thumb, src.PIN, src.reset
                        , src.mailsent, src.sysmember, src.maildate, src.updatesent, src.updatenum, src.nosend
                        , src.hidden, src.security_level, src.review, src.Q1, src.Q2, src.Q3, src.iAnswer, src.ipMac
                        , src.frequency_ID, src.refer, src.is_Active, src.timeZone, src.usesDaylight, src.tzOffset, src.iDefault_Quota
                        , src.iDoc_Usage, src.assist_id, src.layout, src.bTOS, src.bOnlineNow, src.uID, src.iwkgrplayout
                        , src.sAboutMe, src.folder_ID, src.signature, src.bAuditLock, src.bProfileUpdate
                        , src.bexpirereminder, src.bPingSent, src.dPingDate, src.inetwork
                        , src.createdOn, src.createdBy, src.updatedOn, src.updatedBy ) 
    OUTPUT  $action, inserted.id INTO @coreMergeResults ;
    SELECT  @rows = @@ROWCOUNT ;

    SELECT  @coreContactInserts = ( SELECT COUNT(*) FROM @coreMergeResults WHERE action = 'INSERT' )
          , @coreContactUpdates = ( SELECT COUNT(*) FROM @coreMergeResults WHERE action = 'UPDATE' ) ;

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
     MERGE  Portal.Contacts AS tgt
     USING  #mc_contact     AS src
        ON  src.contactID = tgt.id
      WHEN  MATCHED
      THEN  UPDATE
               SET  systemID    = @systemID
                  , isVerified  = src.bVerified
                  , verifiedBy  = src.verifiedID
                  , verifiedOn  = src.dVerifiedDate
                  , createdOn   = src.dateAdded
                  , createdBy   = src.createdID
                  , updatedOn   = src.DateModified
                  , updatedBy   = src.updatedID
                  , portalID    = src.id

      WHEN  NOT MATCHED BY TARGET
      THEN  INSERT ( id, systemID, isVerified, verifiedBy, verifiedOn
                       , createdOn, createdBy, updatedOn, updatedBy, portalID )
            VALUES ( src.contactID, src.systemID, src.bVerified, src.verifiedID, src.dVerifiedDate
                       , src.dateAdded, src.createID, src.DateModified, src.updatedID, src.id )
    OUTPUT  $action, inserted.id INTO @portalMergeResults ;
    SELECT  @rows = @@ROWCOUNT ;

    SELECT  @portalContactInserts = ( SELECT COUNT(*) FROM @portalMergeResults WHERE action = 'INSERT' )
          , @portalContactUpdates = ( SELECT COUNT(*) FROM @portalMergeResults WHERE action = 'UPDATE' ) ;


END
