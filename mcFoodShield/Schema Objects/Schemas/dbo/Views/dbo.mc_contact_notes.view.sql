CREATE VIEW dbo.mc_contact_notes
AS
/*
************************************************************************************************************************************

       View:    dbo.mc_contact_notes
     Author:    Chris Carson
    Purpose:    Portal view of Core.ContactEmails joined on Portal.ContactEmails

    revisor    date            description
    ---------  -----------     ----------------------------
    ccarson    ###DATE###      Created

************************************************************************************************************************************
*/

    SELECT  id          = v.id
          , user_id     = v.user_id
          , notes       = v.notes
          , admin_id    = v.admin_id
          , dateAdded   = v.epublic
          , type_id     = v.type_id
      FROM  Portal.mc_contact_notes AS v
     WHERE  v.portalDB = DB_NAME() ;