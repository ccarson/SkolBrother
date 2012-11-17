CREATE VIEW dbo.vw_expandedOrganizations
/*
************************************************************************************************************************************
            
       View:  dbo.vw_expandedOrganizations
     Author:  Chris Carson
    Purpose:  Expanded view of dbo.Organizations for mergeOrganizations process

    revisor     date          description
    ---------   -----------   ----------------------------
    ccarson     2012-09-17    Created


    Notes:

************************************************************************************************************************************
*/
AS

      WITH  orgTypes AS ( 
            SELECT  s.id
                 ,  s.systemName
                 ,  OrganizationTypeID = h.id
                 ,  OrgType            = h.typename
              FROM  dbo.transitionSystems AS s
       CROSS APPLY  Reference.tvf_OrganizationTypes ( systemname ) AS h ) , 

            verticals AS ( 
            SELECT  s.id
                 ,  s.systemName
                 ,  VerticalID = h.id
                 ,  Vertical   = h.verticalName
              FROM  dbo.transitionSystems AS s
       CROSS APPLY  Reference.tvf_Verticals ( systemname ) AS h )

    SELECT  TOP 100 PERCENT
            c.id
          , c.Name
          , c.Website
          , c.Status
          , c.Summary
          , c.isActive
          , c.isDemo
          , c.isTemp
          , c.brandID
          , orgCreatedOn    = c.CreatedOn
          , orgCreatedBy    = c.CreatedBy
          , orgUpdatedOn    = c.UpdatedOn
          , orgUpdatedBy    = c.UpdatedBy
          , portal          = COALESCE(s.systemName,'No Portals')
          , OrgTypeID       = COALESCE(p.organizationTypeID, 0)
          , OrgType         = COALESCE(ot.OrgType, 'NONE')
          , VerticalID      = COALESCE(p.verticalID,0)
          , Vertical        = COALESCE(v.Vertical, 'NONE')
          , PortalCreatedOn = p.createdOn
          , PortalCreatedBy = p.createdBy
          , PortalUpdatedOn = p.updatedOn
          , PortalUpdatedBy = p.updatedBy
          , p.portalID
      FROM  Core.Organizations    AS c
 LEFT JOIN  Portal.Organizations  AS p ON p.id = c.id
 LEFT JOIN  dbo.transitionSystems AS s ON s.id = p.systemID
 LEFT JOIN  orgTypes AS ot ON ot.id = p.systemID AND ot.OrganizationTypeID = p.OrganizationTypeID
 LEFT JOIN  verticals AS v ON v.id = p.systemID AND v.VerticalID = p.verticalID 
  ORDER BY  Name, portal, portalID ;

