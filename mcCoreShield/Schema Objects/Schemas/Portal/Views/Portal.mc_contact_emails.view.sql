CREATE VIEW Portal.mc_contact_emails
WITH SCHEMABINDING
AS
/*
************************************************************************************************************************************

       View:    Portal.mc_contact_addresses
     Author:    Chris Carson
    Purpose:    All portals view of Core.ContactEmails joined on Portal.ContactEmails

    revisor    date            description
    ---------  -----------     ----------------------------
    ccarson    ###DATE###      Created

************************************************************************************************************************************
*/

    SELECT  id              = p.portalID
          , email           = e.email
          , user_id         = c.portalID
          , type_id         = e.typeID
          , edefault        = e.isDefault   
          , active          = e.isActive    
          , epublic         = e.isPublic    
          , alert           = e.isAlert     
          , is_emergency    = e.isEmergency 
          , portalDB        = s.systemDBName
          , contactsID      = e.contactsID
          , coreID          = e.id
          
      FROM  Core.ContactEmails   AS e
INNER JOIN  Portal.ContactEmails AS p ON p.id = e.id
INNER JOIN  Portal.Contacts      AS c ON c.id = e.contactsID AND c.systemID = p.systemID
INNER JOIN  dbo.Systems          AS s ON s.id = p.systemID ;

