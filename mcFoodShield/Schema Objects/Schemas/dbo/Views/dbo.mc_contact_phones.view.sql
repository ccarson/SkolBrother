CREATE VIEW dbo.mc_contact_phones
AS
/*
************************************************************************************************************************************

       View:    dbo.mc_contact_phones
     Author:    Chris Carson
    Purpose:    Portal view of Core.ContactEmails joined on Portal.ContactEmails

    revisor    date            description
    ---------  -----------     ----------------------------
    ccarson    ###DATE###      Created

************************************************************************************************************************************
*/

    SELECT  id              = v.id
          , phone           = v.email
          , user_id         = v.user_id
          , type_id         = v.type_id
          , edefault        = v.edefault
          , active          = v.active
          , epublic         = v.epublic
          , extension       = v.extension
          , alert           = v.alert
          , is_emergency    = v.is_emergency
      FROM  Portal.mc_contact_phones AS v
     WHERE  v.portalDB = DB_NAME() ;