CREATE PROCEDURE dbo.mc_contact_notesDelete ( @systemDBName AS NVARCHAR (50)
                                      , @recordsIN    AS INT
                                      , @errorMessage AS NVARCHAR (MAX) OUTPUT )
AS
/*
************************************************************************************************************************************

  Procedure: dbo.mc_contactDelete
     Author: Chris Carson
    Purpose: Processes data from portal view trigger for Core.Contacts and Portal.Contacts on core

    revisor     date            description
    ---------   -----------     ----------------------------
    ccarson     ###DATE###      created


    Logic Summary:
        1)  Add contactID field to incoming data
        2)  UPDATE contactID from existing Portal.Contacts.id 
        3)  DELETE Portal.Contacts
        4)  DELETE Core.Contacts records when all Portal.Contacts records are deleted

************************************************************************************************************************************
*/
BEGIN

    SET NOCOUNT ON ;

    DECLARE @updated            AS INT = 0
          , @rows               AS INT = 0
          , @contactInserts     AS INT = 0
          , @contactUpdates     AS INT = 0
          , @legacyID           AS INT = 0
          , @inserted           AS INT = 0
          , @deleted            AS INT = 0
          , @systemID           AS INT = 0 
          , @unknownUser    AS UNIQUEIDENTIFIER = N'00000000-0000-0000-0000-000000000001' ; 
          
--  1)  Add contactID field to incoming data
    ALTER TABLE #mc_contact ADD contactID   UNIQUEIDENTIFIER NULL ; 
    
--  2)  UPDATE contactID from existing Portal.Contacts.id     
    UPDATE  #mc_contact
       SET  contactID = p.id 
      FROM  #mc_contact     AS m
INNER JOIN  Portal.Contacts AS p ON p.portalID = m.id AND p.systemID = @systemID ; 


--  3)  DELETE Portal.Contacts
      WITH  records AS ( 
            SELECT * FROM Portal.Contacts AS p 
             WHERE EXISTS ( SELECT 1 FROM #mc_contact AS m WHERE m.contactID = p.id AND p.systemID = @systemID ) )
    DELETE  records ; 
    

--  4)  DELETE Core.Contacts records when all Portal.Contacts records are deleted
      WITH  records AS ( 
            SELECT * FROM Core.Contacts AS c
             WHERE EXISTS ( SELECT 1 FROM #mc_contact AS m WHERE m.contactID = c.id ) 
               AND NOT EXISTS ( SELECT 1 FROM Portal.Contacts AS p WHERE p.id = c.id ) ) 
    DELETE  records ; 
    
END


