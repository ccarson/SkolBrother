CREATE VIEW dbo.vw_transitionContacts 
WITH SCHEMABINDING 
AS 
    SELECT  id                  = id
          , transitionSystemsID = systemID
          , ContactsID          = portalID
      FROM  Portal.Contacts ;
