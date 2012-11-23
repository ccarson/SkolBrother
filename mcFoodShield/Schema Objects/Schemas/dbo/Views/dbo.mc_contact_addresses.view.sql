CREATE VIEW dbo.mc_contact_addresses
AS
/*
************************************************************************************************************************************

       View:    dbo.mc_contact_addresses
     Author:    Chris Carson
    Purpose:    Portal view of core Portal.mc_contact_addresses

    revisor    date            description
    ---------  -----------     ----------------------------
    ccarson    ###DATE###      Created

************************************************************************************************************************************
*/

    SELECT  id                  = v.id
          , add_type            = v.add_type
          , address1            = v.address1
          , address2            = v.address2
          , address3            = v.address3
          , city                = v.city
          , state               = v.state
          , zip                 = v.zip
          , country             = v.country
          , user_id             = v.user_id
          , defaultaddress      = v.defaultaddress
          , name                = v.name
          , createdDate         = v.createdDate

      FROM  Portal.mc_contact_addresses AS v
     WHERE  v.portalDB = DB_NAME() ;


