CREATE VIEW Portal.mc_organization
WITH SCHEMABINDING
AS
/*
************************************************************************************************************************************

       View:    Portal.mc_organization
     Author:    Chris Carson
    Purpose:    All portals view of core.Organizations joined on core.OrganizationSystems

    revisor    date            description
    ---------  -----------     ----------------------------
    ccarson    ###DATE###      Created

************************************************************************************************************************************
*/
    SELECT  id              = os.mc_organizationID
          , Name            = o.Name
          , Website         = o.Website
          , Status          = o.Status
          , Summary         = o.Summary
          , type_id         = os.organizationTypeID
          , vertical_id     = os.verticalID
          , active          = o.isActive
          , brand_id        = o.brandID
          , is_demo         = o.isDemo
          , temp            = o.isTemp
          , date_added      = os.createdOn
          , added_by        = ISNULL( x.ContactsID, 0 )
          , date_updated    = os.updatedOn
          , updated_by      = ISNULL( y.ContactsID, 0 )
          , portalDB        = s.systemDBName
          , OrganizationID  = o.id
      FROM  dbo.Organizations       AS o
INNER JOIN  dbo.OrganizationSystems AS os
        ON  os.id = o.id
INNER JOIN  dbo.Systems             AS s
        ON  s.id  = os.systemID
 LEFT JOIN  dbo.vw_transitionContacts AS x
        ON  x.id = os.createdBy AND x.transitionSystemsID = s.ID
 LEFT JOIN  dbo.vw_transitionContacts AS y
        ON  y.id = os.updatedBy AND y.transitionSystemsID = s.ID ;

