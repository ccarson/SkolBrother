CREATE VIEW dbo.vw_transitionContactAddresses
WITH SCHEMABINDING
AS
    SELECT  id                  = id
          , transitionSystemsID = systemID
          , ContactAddressesID  = portalID
      FROM  Portal.ContactAddresses ;
