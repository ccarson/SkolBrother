CREATE VIEW dbo.mc_organization
AS
/*
************************************************************************************************************************************

       View:    dbo.mc_organization
     Author:    Chris Carson
    Purpose:    portal-specific view of core.mc_organization data

    revisor    date         description
    ---------  ---------    ----------------------------
    ccarson    ##DATE###    Created

************************************************************************************************************************************
*/
        SELECT  id              = id
              , Name            = Name
              , Website         = Website
              , Status          = Status
              , Summary         = Summary
              , type_id         = type_id
              , vertical_id     = vertical_id
              , active          = active
              , brand_id        = brand_id
              , is_demo         = is_demo
              , temp            = temp
              , date_added      = date_added
              , added_by        = added_by
              , date_updated    = date_updated
              , updated_by      = updated_by
          FROM  Portal.mc_organization
         WHERE  portalDB = DB_NAME() ;
