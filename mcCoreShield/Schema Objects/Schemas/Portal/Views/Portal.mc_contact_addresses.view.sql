CREATE VIEW Portal.mc_contact_addresses
AS
/*
************************************************************************************************************************************

       View:    Portal.mc_contact_addresses
     Author:    Chris Carson
    Purpose:    All portals view of Core.ContactAddresses joined on Portal.ContactAddresses

    revisor    date            description
    ---------  -----------     ----------------------------
    ccarson    ###DATE###      Created

************************************************************************************************************************************
*/

    SELECT  id                  = p.portalID
          , add_type            = a.addressType
          , address1            = a.address1
          , address2            = a.address2
          , address3            = a.address3
          , city                = a.city
          , state               = a.state
          , zip                 = a.zip
          , country             = a.country
          , user_id             = c.portalID
          , defaultAddress      = a.isDefault
          , name                = a.addressName
          , createdDate         = a.createdOn
          , portalDB            = s.systemDBName
          , contactID           = a.contactsID
          , contactAddressID    = a.id

      FROM  Core.ContactAddresses   AS a
INNER JOIN  Portal.ContactAddresses AS p ON p.id = a.id
INNER JOIN  Portal.Contacts         AS c ON c.id = a.contactsID AND c.systemID = p.systemID
INNER JOIN  dbo.Systems             AS s ON s.id = p.systemID ;

