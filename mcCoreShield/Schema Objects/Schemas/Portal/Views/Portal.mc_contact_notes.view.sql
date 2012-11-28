CREATE VIEW Portal.mc_contact_notes
AS
/*
************************************************************************************************************************************

       View:    Portal.mc_contact_notes
     Author:    Chris Carson
    Purpose:    All portals view of Core.ContactNotes joined on Portal.ContactNotes

    revisor    date            description
    ---------  -----------     ----------------------------
    ccarson    ###DATE###      Created

************************************************************************************************************************************
*/

    SELECT  id              = p.portalID
          , user_id         = c.portalID
          , notes           = n.notes
          , admin_id        = a.portalID
          , dateAdded       = n.createdOn
          , type_id         = n.typeID
          , portalDB        = s.systemDBName
          , contactID       = a.contactsID
          , contactNotesID  = a.id

      FROM  Core.ContactNotes   AS n
INNER JOIN  Portal.ContactNotes AS p ON p.id = n.id
INNER JOIN  Portal.Contacts     AS c ON c.id = n.contactsID AND c.systemID = p.systemID
INNER JOIN  Portal.Contacts     AS a ON a.id = n.adminID AND a.systemID = p.systemID
INNER JOIN  dbo.Systems         AS s ON s.id = p.systemID ;

