CREATE VIEW Portal.mc_contact_phones
AS
/*
************************************************************************************************************************************

       View:    Portal.mc_contact_phones
     Author:    Chris Carson
    Purpose:    All portals view of Core.ContactPhones joined on Portal.ContactPhones

    revisor    date            description
    ---------  -----------     ----------------------------
    ccarson    ###DATE###      Created

************************************************************************************************************************************
*/

    SELECT  id              = p.portalID
          , phone           = t.phone
          , user_id         = c.portalID
          , type_id         = t.typeID
          , edefault        = t.isDefault   
          , active          = t.isActive    
          , epublic         = t.isPublic    
          , extension       = t.extension
          , alert           = t.isAlert     
          , is_emergency    = t.isEmergency 
          , portalDB        = s.systemDBName
          , contactID       = t.contactsID
          , contactPhonesID = t.id
      FROM  Core.ContactPhones   AS t
INNER JOIN  Portal.ContactPhones AS p ON p.id = t.id
INNER JOIN  Portal.Contacts      AS c ON c.id = t.contactsID AND c.systemID = p.systemID
INNER JOIN  dbo.Systems          AS s ON s.id = p.systemID ;

