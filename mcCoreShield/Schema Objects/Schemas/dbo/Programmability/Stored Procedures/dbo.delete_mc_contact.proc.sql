CREATE PROCEDURE dbo.delete_mc_contact ( @systemDBName AS NVARCHAR (50)
                                       , @recordsIN    AS INT
                                       , @errorMessage AS NVARCHAR (MAX) OUTPUT )
AS
/*
************************************************************************************************************************************
            
  Procedure:    dbo.delete_mc_contact
     Author:    Chris Carson
    Purpose:    deletes core Contact data

    revisor     date            description
    ---------   -----------     ----------------------------
    ccarson     ###DATE###      created


    Logic Summary:
        1)  Determine systemID from incoming @systemDBName
        2)  Add contactID field to incoming data
        3)  UPDATE contactID from existing Portal.Contacts.id 
        4)  DELETE Portal.Contacts
        5)  DELETE Core.Contacts records when all Portal.Contacts records are deleted

************************************************************************************************************************************
*/
BEGIN
    SET NOCOUNT ON ;

    DECLARE @systemID           AS INT = 0 ; 


--  1)  Determine systemID from incoming @systemDBName
    SELECT  @systemID = id FROM dbo.Systems WHERE systemDBName = @systemDBName ;

    
--  2)  Add contactID field to incoming data
    ALTER TABLE #mc_contact 
        ADD contactID UNIQUEIDENTIFIER NULL ; 
    
--  3)  UPDATE contactID from existing Portal.Contacts.id     
    UPDATE  #mc_contact
       SET  contactID = p.id 
      FROM  #mc_contact     AS m
INNER JOIN  Portal.Contacts AS p ON p.portalID = m.id AND p.systemID = @systemID ; 


--  4)  DELETE Portal.Contacts
      WITH  records AS ( 
            SELECT * FROM Portal.Contacts AS p 
             WHERE EXISTS ( SELECT 1 FROM #mc_contact AS m WHERE m.contactID = p.id AND p.systemID = @systemID ) )
    DELETE  records ; 
    

--  5)  DELETE Core.Contacts records when all Portal.Contacts records are deleted
      WITH  records AS ( 
            SELECT * FROM Core.Contacts AS c
             WHERE EXISTS ( SELECT 1 FROM #mc_contact AS m WHERE m.contactID = c.id ) 
               AND NOT EXISTS ( SELECT 1 FROM Portal.Contacts AS p WHERE p.id = c.id ) ) 
    DELETE  records ; 
    
END


