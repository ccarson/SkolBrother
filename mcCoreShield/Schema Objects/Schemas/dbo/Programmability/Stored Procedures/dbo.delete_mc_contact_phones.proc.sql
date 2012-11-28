CREATE PROCEDURE dbo.delete_mc_contact_phones ( @systemDBName AS NVARCHAR (50)
                                              , @recordsIN    AS INT
                                              , @errorMessage AS NVARCHAR (MAX) OUTPUT )
AS
/*
************************************************************************************************************************************

  Procedure: dbo.delete_mc_contact_phones
     Author: Chris Carson
    Purpose: Processes data from portal view trigger for Core.ContactPhones and Portal.ContactPhones on core

    revisor     date            description
    ---------   -----------     ----------------------------
    ccarson     ###DATE###      created


    Logic Summary:
        1)  Determine systemID from incoming @systemDBName
        2)  Add contactPhonesID field to incoming data
        3)  UPDATE contactPhonesID from existing Portal.ContactPhones.id
        4)  DELETE Portal.ContactPhones
        5)  DELETE Core.ContactPhones records when all Portal.ContactPhones records are deleted

************************************************************************************************************************************
*/
BEGIN
    SET NOCOUNT ON ;

    DECLARE @systemID           AS INT = 0 ; 


--  1)  Determine systemID from incoming @systemDBName
    SELECT  @systemID = id FROM dbo.Systems WHERE systemDBName = @systemDBName ;


--  2)  Add contactPhonesID field to incoming data
    ALTER TABLE #mc_contact_phones 
        ADD contactPhonesID UNIQUEIDENTIFIER NULL ;


--  3)  UPDATE contactPhonesID from existing Portal.ContactPhones.id
    UPDATE  #mc_contact_phones
       SET  contactPhonesID = p.id
      FROM  #mc_contact_phones   AS m
INNER JOIN  Portal.ContactPhones AS p ON p.portalID = m.id AND p.systemID = @systemID ;


--  4)  DELETE Portal.ContactPhones
      WITH  records AS (
            SELECT  *
              FROM  Portal.ContactPhones AS p
             WHERE  EXISTS ( SELECT  1
                               FROM  #mc_contact_phones AS m
                              WHERE  m.contactPhonesID = p.id AND p.systemID = @systemID ) )
    DELETE  records ;


--  5)  DELETE Core.ContactPhones records when all Portal.ContactPhones records are deleted
      WITH  records AS (
            SELECT * FROM Core.ContactPhones AS c
             WHERE EXISTS ( SELECT  1
                              FROM  #mc_contact_phones AS m
                             WHERE  m.contactID = c.id )
               AND NOT EXISTS ( SELECT  1
                                  FROM  Portal.ContactPhones AS p
                                 WHERE  p.id = c.id ) )
    DELETE  records ;

END
