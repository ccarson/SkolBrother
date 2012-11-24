CREATE PROCEDURE dbo.mc_contact_emailsDelete ( @systemDBName AS NVARCHAR (50)
                                             , @recordsIN    AS INT
                                             , @errorMessage AS NVARCHAR (MAX) OUTPUT )
AS
/*
************************************************************************************************************************************

  Procedure: dbo.mc_contact_emailsDelete
     Author: Chris Carson
    Purpose: Processes data from portal view trigger for Core.ContactAddresses and Portal.ContactAddresses on core

    revisor     date            description
    ---------   -----------     ----------------------------
    ccarson     ###DATE###      created


    Logic Summary:
        1)  Determine systemID from incoming @systemDBName
        2)  Add contactEmailsID field to incoming data
        3)  UPDATE contactEmailsID from existing Portal.ContactEmails.id
        4)  DELETE Portal.ContactEmails
        5)  DELETE Core.ContactEmails records when all Portal.ContactEmails records are deleted

************************************************************************************************************************************
*/
BEGIN
    SET NOCOUNT ON ;

    DECLARE @systemID           AS INT = 0 ; 


--  1)  Determine systemID from incoming @systemDBName
    SELECT  @systemID = id FROM dbo.Systems WHERE systemDBName = @systemDBName ;


--  2)  Add contactEmailsID field to incoming data
    ALTER TABLE #mc_contact_emails ADD contactEmailsID   UNIQUEIDENTIFIER NULL ;


--  3)  UPDATE contactEmailsID from existing Portal.ContactEmails.id
    UPDATE  #mc_contact_emails
       SET  contactEmailsID = p.id
      FROM  #mc_contact_emails   AS m
INNER JOIN  Portal.ContactEmails AS p ON p.portalID = m.id AND p.systemID = @systemID ;


--  4)  DELETE Portal.ContactEmails
      WITH  records AS (
            SELECT  *
              FROM  Portal.ContactEmails AS p
             WHERE  EXISTS ( SELECT  1
                               FROM  #mc_contact_emails AS m
                              WHERE  m.contactEmailsID = p.id AND p.systemID = @systemID ) )
    DELETE  records ;


--  5)  DELETE Core.ContactEmails records when all Portal.ContactEmails records are deleted
      WITH  records AS (
            SELECT * FROM Core.ContactEmails AS c
             WHERE EXISTS ( SELECT  1
                              FROM  #mc_contact_emails AS m
                             WHERE  m.contactEmailsID = c.id )
               AND NOT EXISTS ( SELECT  1
                                  FROM  Portal.ContactEmails AS p
                                 WHERE  p.id = c.id ) )
    DELETE  records ;

END
