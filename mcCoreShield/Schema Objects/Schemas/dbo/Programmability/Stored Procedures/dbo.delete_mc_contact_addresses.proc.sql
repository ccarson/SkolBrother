CREATE PROCEDURE dbo.delete_mc_contact_addresses ( @systemDBName AS NVARCHAR (50)
                                                 , @recordsIN    AS INT
                                                 , @errorMessage AS NVARCHAR (MAX) OUTPUT )
AS
/*
************************************************************************************************************************************

  Procedure: dbo.delete_mc_contact_addresses
     Author: Chris Carson
    Purpose: Processes data from portal view trigger for Core.ContactAddresses and Portal.ContactAddresses on core

    revisor     date            description
    ---------   -----------     ----------------------------
    ccarson     ###DATE###      created


    Logic Summary:
        1)  Determine systemID from incoming @systemDBName
        2)  Add contactAddressID field to incoming data
        3)  UPDATE contactAddressID from existing Portal.ContactAddresses.id
        4)  DELETE Portal.ContactAddresses
        5)  DELETE Core.ContactAddresses records when all Portal.ContactAddresses records are deleted

************************************************************************************************************************************
*/
BEGIN
    SET NOCOUNT ON ;

    DECLARE @systemID           AS INT = 0 ; 


--  1)  Determine systemID from incoming @systemDBName
    SELECT  @systemID = id FROM dbo.Systems WHERE systemDBName = @systemDBName ;


--  2)  Add contactAddressID field to incoming data
    ALTER TABLE #mc_contact_addresses 
        ADD contactAddressID UNIQUEIDENTIFIER NULL ;


--  3)  UPDATE contactAddressID from existing Portal.ContactAddresses.id
    UPDATE  #mc_contact_addresses
       SET  contactAddressID = p.id
      FROM  #mc_contact_addresses   AS m
INNER JOIN  Portal.ContactAddresses AS p ON p.portalID = m.id AND p.systemID = @systemID ;


--  4)  DELETE Portal.ContactAddresses
      WITH  records AS (
            SELECT  *
              FROM  Portal.ContactAddresses AS p
             WHERE  EXISTS ( SELECT  1
                               FROM  #mc_contact_addresses AS m
                              WHERE  m.contactAddressID = p.id AND p.systemID = @systemID ) )
    DELETE  records ;


--  5)  DELETE Core.ContactAddresses records when all Portal.ContactAddresses records are deleted
      WITH  records AS (
            SELECT * FROM Core.ContactAddresses AS c
             WHERE EXISTS ( SELECT  1
                              FROM  #mc_contact_addresses AS m
                             WHERE  m.contactID = c.id )
               AND NOT EXISTS ( SELECT  1
                                  FROM  Portal.ContactAddresses AS p
                                 WHERE  p.id = c.id ) )
    DELETE  records ;

END
