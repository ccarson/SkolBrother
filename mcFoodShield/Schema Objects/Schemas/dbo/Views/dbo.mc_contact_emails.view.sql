CREATE VIEW dbo.mc_contact_emails
AS
/*
************************************************************************************************************************************

       View:    dbo.mc_contact_emails
     Author:    Chris Carson
    Purpose:    Portal view of Core.ContactEmails joined on Portal.ContactEmails

    revisor    date            description
    ---------  -----------     ----------------------------
    ccarson    ###DATE###      Created

************************************************************************************************************************************
*/

    SELECT  id              = v.id
          , email           = v.email
          , user_id         = v.user_id
          , type_id         = v.type_id
          , edefault        = v.edefault
          , active          = v.active
          , epublic         = v.epublic
          , alert           = v.alert
          , is_emergency    = v.is_emergency
      FROM  Portal.mc_contact_emails AS v
     WHERE  v.portalDB = DB_NAME() ;
