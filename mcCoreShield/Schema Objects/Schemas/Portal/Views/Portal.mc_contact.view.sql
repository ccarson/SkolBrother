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
    SELECT  id              = p.portalID
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
          , ModifiedBy      = COALESCE( u.portalID, 0 )
          , DateModified    = p.updatedOn
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
          , dateAdded       = p.createdOn
          , addedBy         = COALESCE( a.portalID,0 )
          , bAuditLock      = c.bAuditLock
          , bProfileUpdate  = c.bProfileUpdate
          , bexpirereminder = c.bexpirereminder
          , bPingSent       = c.bPingSent
          , dPingDate       = c.dPingDate
          , bVerified       = p.isVerified
          , iVerifiedBy     = COALESCE( v.portalID,0 )
          , dVerifiedDate   = p.verifiedOn
          , inetwork        = c.inetwork
          , portalDB        = s.systemDBName
          , ContactID       = c.id
      FROM  Core.Contacts   AS c
INNER JOIN  Portal.Contacts AS p ON p.id = c.id
INNER JOIN  dbo.Systems     AS s ON s.id = p.systemID
 LEFT JOIN  Portal.Contacts AS a ON a.id = p.createdBy  AND a.systemID = s.id
 LEFT JOIN  Portal.Contacts AS u ON u.id = p.updatedBy  AND u.systemID = s.id
 LEFT JOIN  Portal.Contacts AS v ON v.id = p.verifiedBy AND v.systemID = s.id ;