CREATE VIEW Portal.mc_organization
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
    SELECT  id              = p.portalID
          , Name            = c.Name
          , Website         = c.Website
          , Status          = c.Status
          , Summary         = c.Summary
          , type_id         = p.organizationTypeID
          , vertical_id     = p.verticalID
          , active          = c.isActive
          , brand_id        = c.brandID
          , is_demo         = c.isDemo
          , temp            = c.isTemp
          , date_added      = p.createdOn
          , added_by        = ISNULL( a.portalID, 0 )
          , date_updated    = p.updatedOn
          , updated_by      = ISNULL( u.portalID, 0 )
          , portalDB        = s.systemDBName
          , OrganizationID  = c.id
      FROM  Core.Organizations      AS c
INNER JOIN  Portal.Organizations    AS p ON  p.id = c.id
INNER JOIN  dbo.Systems             AS s ON  s.id = p.systemID
 LEFT JOIN  Portal.Contacts         AS a ON  a.id = c.createdBy AND a.systemID = s.id
 LEFT JOIN  Portal.Contacts         AS u ON  u.id = c.updatedBy AND u.systemID = s.id ;
