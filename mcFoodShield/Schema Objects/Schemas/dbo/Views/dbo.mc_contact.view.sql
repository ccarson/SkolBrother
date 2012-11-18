CREATE VIEW dbo.mc_contact
AS
/*
************************************************************************************************************************************
       View:    dbo.mc_contact
     Author:    Chris Carson
    Purpose:    portal-specific view of core.mc_contact data
    revisor    date         description
    ---------  ---------    ----------------------------
    ccarson    ##DATE###    Created
************************************************************************************************************************************
*/
SELECT  id              = id
      , Salutation      = salutation
      , JobTitle        = jobTitle
      , Firstname       = firstname
      , Initial         = initial
      , Lastname        = lastname
      , Suffix          = suffix
      , Email           = email
      , Login           = login
      , Password        = password
      , salt            = salt
      , AccessID        = accessID
      , Expires         = expires
      , Hits            = hits
      , LastLogin       = lastLogin
      , Status          = status
      , ModifiedBy      = modifiedBy
      , DateModified    = dateModified
      , datejoined      = datejoined
      , membertype      = membertype
      , photo           = photo
      , resume          = resume
      , thumb           = thumb
      , PIN             = PIN
      , reset           = reset
      , mailsent        = mailsent
      , sysmember       = sysmember
      , maildate        = maildate
      , updatesent      = updatesent
      , updatenum       = updatenum
      , nosend          = nosend
      , hidden          = hidden
      , security_level  = security_level
      , review          = review
      , Q1              = q1
      , Q2              = q2
      , Q3              = q3
      , iAnswer         = iAnswer
      , ipMac           = ipMac
      , frequency_id    = frequency_id
      , refer           = refer
      , is_active       = is_active
      , TimeZone        = timeZone
      , usesDaylight    = usesDaylight
      , TzOffset        = tzOffset
      , iDefault_Quota  = iDefault_Quota
      , iDoc_Usage      = iDoc_Usage
      , assist_id       = assist_id
      , layout          = layout
      , bTOS            = bTOS
      , bOnlineNow      = bOnlineNow
      , uID             = uID
      , iwkgrplayout    = iwkgrplayout
      , sAboutMe        = sAboutMe
      , folder_id       = folder_id
      , signature       = signature
      , dateAdded       = dateAdded
      , addedBy         = addedBy
      , bAuditLock      = bAuditLock
      , bProfileUpdate  = bProfileUpdate
      , bexpirereminder = bexpirereminder
      , bPingSent       = bPingSent
      , dPingDate       = dPingDate
      , bVerified       = bVerified
      , iVerifiedBy     = iVerifiedBy
      , dVerifiedDate   = dVerifiedDate
      , inetwork        = inetwork
  FROM  Portal.mc_contact
 WHERE  portalDB = DB_NAME() ;

