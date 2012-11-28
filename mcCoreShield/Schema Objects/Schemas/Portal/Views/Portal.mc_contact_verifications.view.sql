CREATE VIEW Portal.mc_contact_verification
WITH SCHEMABINDING
AS
/*
************************************************************************************************************************************

       View:    Portal.mc_contact_verification
     Author:    Chris Carson
    Purpose:    All portals view of Core.ContactVerification joined on Portal.ContactVerification

    revisor    date            description
    ---------  -----------     ----------------------------
    ccarson    ###DATE###      Created

************************************************************************************************************************************
*/

    SELECT  id                      = p.portalID
          , user_id                 = c.portalID
          , verified_by             = v.portalID
          , verified_date           = cv.verifiedOn
          , portalDB                = s.systemDBName
          , contactsID              = cv.contactsID
          , coreID                  = cv.id

      FROM  Core.ContactVerifications   AS cv
INNER JOIN  Portal.ContactVerifications AS p ON p.id = cv.id
INNER JOIN  Portal.Contacts             AS c ON c.id = cv.contactsID AND c.systemID = p.systemID
INNER JOIN  Portal.Contacts             AS v ON v.id = cv.verifiedBy AND v.systemID = p.systemID
INNER JOIN  dbo.Systems                 AS s ON s.id = p.systemID ;

