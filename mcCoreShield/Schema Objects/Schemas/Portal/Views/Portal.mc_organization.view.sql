﻿CREATE VIEW Portal.mc_organization
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
          , added_by        = ISNULL( x.ContactsID, 0 )
          , date_updated    = p.updatedOn
          , updated_by      = ISNULL( y.ContactsID, 0 )
          , portalDB        = s.systemDBName
          , OrganizationID  = c.id
      FROM  Core.Organizations        AS c
INNER JOIN  Portal.Organizations      AS p ON  p.id = c.id
INNER JOIN  dbo.Systems               AS s ON  s.id = p.systemID
 LEFT JOIN  dbo.vw_transitionContacts AS x
        ON  x.id = p.createdBy AND x.transitionSystemsID = s.ID
 LEFT JOIN  dbo.vw_transitionContacts AS y
        ON  y.id = p.updatedBy AND y.transitionSystemsID = s.ID ;

