CREATE VIEW Portal.mc_contact 
WITH SCHEMABINDING
AS
/*
************************************************************************************************************************************

       View:    Portal.mc_contact
     Author:    Chris Carson
    Purpose:    All portals view of Core.Contacts joined on Portal.Contacts

    revisor    date            description
    ---------  -----------     ----------------------------
    ccarson    ###DATE###      Created

************************************************************************************************************************************
*/
    SELECT  id              = p1.portalID
          , Salutation      = c.salutation
          , JobTitle        = c.jobTitle
          , Firstname       = c.firstname
          , Initial         = c.initial
          , Lastname        = c.lastname
          , Suffix          = c.suffix
          , Email           = c.email
          , Login           = c.login
          , Password        = c.password
          , salt            = c.salt
          , AccessID        = c.accessID
          , Expires         = c.expires
          , Hits            = c.hits
          , LastLogin       = c.lastLogin
          , Status          = c.status
          , ModifiedBy      = c.modifiedBy
          , DateModified    = p1.updatedOn
          , datejoined      = c.datejoined
          , membertype      = c.membertype
          , photo           = c.photo
          , resume          = c.resume
          , thumb           = c.thumb
          , PIN             = c.PIN
          , reset           = c.reset
          , mailsent        = c.mailsent
          , sysmember       = c.sysmember
          , maildate        = c.maildate
          , updatesent      = c.updatesent
          , updatenum       = c.updatenum
          , nosend          = c.nosend
          , hidden          = c.hidden
          , security_level  = c.securityLevel
          , review          = c.review
          , Q1              = c.q1
          , Q2              = c.q2
          , Q3              = c.q3
          , iAnswer         = c.iAnswer
          , ipMac           = c.ipMac
          , frequency_id    = c.frequencyID
          , refer           = c.refer
          , is_active       = c.isActive
          , TimeZone        = c.timeZone
          , usesDaylight    = c.usesDaylight
          , TzOffset        = c.tzOffset
          , iDefault_Quota  = c.iDefaultQuota
          , iDoc_Usage      = c.iDocUsage
          , assist_id       = c.assistID
          , layout          = c.layout
          , bTOS            = c.bTOS
          , bOnlineNow      = c.bOnlineNow
          , uID             = c.uID
          , iwkgrplayout    = c.iwkgrplayout
          , sAboutMe        = c.sAboutMe
          , folder_id       = c.folderID
          , signature       = c.signature
          , dateAdded       = p1.createdOn
          , addedBy         = COALESCE( p2.portalID,0 )
          , bAuditLock      = c.bAuditLock           
          , bProfileUpdate  = c.bProfileUpdate
          , bexpirereminder = c.bexpirereminder
          , bPingSent       = c.bPingSent
          , dPingDate       = c.dPingDate
          , bVerified       = p1.isVerified
          , iVerifiedBy     = COALESCE( p3.portalID,0 ) 
          , dVerifiedDate   = p1.verifiedOn
          , inetwork        = c.inetwork
          , portalDB        = s.systemDBName
          , ContactID       = c.id
      FROM  Core.Contacts   AS c
INNER JOIN  Portal.Contacts AS p1 ON p1.id = c.id
INNER JOIN  dbo.Systems     AS s  ON  s.id = p1.systemID
 LEFT JOIN  Portal.Contacts AS p2 ON p2.id = p1.createdBy 
            AND p2.systemID = s.id
 LEFT JOIN  Portal.Contacts AS p3 ON p3.id = p1.verifiedBy
            AND p3.systemID = s.id ; 