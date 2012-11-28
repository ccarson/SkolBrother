CREATE PROCEDURE dbo.delete_mc_contact_notes ( @systemDBName AS NVARCHAR (50)
                                             , @recordsIN    AS INT
                                             , @errorMessage AS NVARCHAR (MAX) OUTPUT )
AS
/*
************************************************************************************************************************************

  Procedure: dbo.delete_mc_contact_notes
     Author: Chris Carson
    Purpose: Processes data from portal view trigger for Core.ContactNotes and Portal.ContactNotes on core

    revisor     date            description
    ---------   -----------     ----------------------------
    ccarson     ###DATE###      created


    Logic Summary:
        1)  Determine systemID from incoming @systemDBName
        2)  Add contactNotesID field to incoming data
        3)  UPDATE contactNotesID from existing Portal.ContactNotes.id
        4)  DELETE Portal.ContactNotes
        5)  DELETE Core.ContactNotes records when all Portal.ContactNotes records are deleted

************************************************************************************************************************************
*/
BEGIN
    SET NOCOUNT ON ;

    DECLARE @systemID           AS INT = 0 ; 


--  1)  Determine systemID from incoming @systemDBName
    SELECT  @systemID = id FROM dbo.Systems WHERE systemDBName = @systemDBName ;


--  2)  Add contactNotesID field to incoming data
    ALTER TABLE #mc_contact_notes 
        ADD contactNotesID UNIQUEIDENTIFIER NULL ;


--  3)  UPDATE contactNotesID from existing Portal.ContactNotes.id
    UPDATE  #mc_contact_notes
       SET  contactNotesID = p.id
      FROM  #mc_contact_notes   AS m
INNER JOIN  Portal.ContactNotes AS p ON p.portalID = m.id AND p.systemID = @systemID ;


--  4)  DELETE Portal.ContactNotes
      WITH  records AS (
            SELECT  *
              FROM  Portal.ContactNotes AS p
             WHERE  EXISTS ( SELECT  1
                               FROM  #mc_contact_notes AS m
                              WHERE  m.contactNotesID = p.id AND p.systemID = @systemID ) )
    DELETE  records ;


--  5)  DELETE Core.ContactNotes records when all Portal.ContactNotes records are deleted
      WITH  records AS (
            SELECT * FROM Core.ContactNotes AS c
             WHERE EXISTS ( SELECT  1
                              FROM  #mc_contact_notes AS m
                             WHERE  m.contactID = c.id )
               AND NOT EXISTS ( SELECT  1
                                  FROM  Portal.ContactNotes AS p
                                 WHERE  p.id = c.id ) )
    DELETE  records ;

END
