CREATE FUNCTION dbo.tvf_getCoreOrganizationsID ( @mc_organizationID AS INT
                                               , @systemID          AS INT )
RETURNS TABLE
AS
/*
************************************************************************************************************************************

   Function:    dbo.tvf_getCoreOrganizationsID
     Author:    Chris Carson, DSCXN
    Purpose:    returns coreSHIELD Core.Organizations.id given a portal dbo.mc_organization.id and system id

    Revision History:
    revisor     date            description
    ---------   -----------     ----------------------------
    ccarson     2012-09-01      Created

Function Arguments:
    @mc_organizationID    INT        portalID
    @systemID             INT        Portal.Organizations.systemID

    Notes:

    Use NULL as input to return all records

************************************************************************************************************************************
*/
RETURN

    SELECT  organizationsID = id
          , systemID        = systemID
      FROM  Portal.Organizations
     WHERE  portalID = ISNULL( @mc_organizationID, portalID )
       AND  systemID = ISNULL( @systemID, systemID ) ;

