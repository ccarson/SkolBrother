﻿CREATE TRIGGER dbo.transitionIdentities_trigger 
            ON dbo.transitionIdentities
AFTER UPDATE
AS
/*
************************************************************************************************************************************
  Procedure: dbo.transitionIdentities_trigger
     Author: Chris Carson
       Date: 2012-09-01
    Purpose: Temporary trigger on transitionIdentities to facilitate org merging

    revisor    Version  date            description
    ---------  -------  -----------     ----------------------------
    ccarson    1.0      2012-09-01      created


    Logic Summary:
        1)  If updates to transitionIdentities are related to mc_organization, continue
        2)  update OrganizationSystems with new mc_organizationID
************************************************************************************************************************************
*/
BEGIN

    IF @@rowcount = 0 RETURN ;

    SET NOCOUNT ON ;

    IF  NOT EXISTS ( SELECT 1 FROM inserted
                      WHERE convertedTableID = ( SELECT id FROM coreConvertedTables
                                                  WHERE tableName = 'mc_organization' ) )
    RETURN ;

    UPDATE  Portal.Organizations
       SET  portalID = i.legacyID
      FROM  Portal.Organizations AS p
INNER JOIN  inserted AS i
        ON  i.id = p.id
            AND i.transitionSystemsID = p.systemID
            AND i.legacyID <> p.portalID ;
END
