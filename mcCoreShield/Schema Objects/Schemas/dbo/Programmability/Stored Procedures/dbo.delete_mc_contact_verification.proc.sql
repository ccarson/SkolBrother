CREATE PROCEDURE dbo.delete_mc_contact_verification ( @systemDBName AS NVARCHAR (50)
                                                    , @recordsIN    AS INT
                                                    , @errorMessage AS NVARCHAR (MAX) OUTPUT )
AS
/*
************************************************************************************************************************************

  Procedure: dbo.delete_mc_contact_verification
     Author: Chris Carson
    Purpose: Processes data from portal view trigger for Core.ContactVerifications and Portal.ContactVerifications on core

    revisor     date            description
    ---------   -----------     ----------------------------
    ccarson     ###DATE###      created


    Logic Summary:
        1)  Determine systemID from incoming @systemDBName
        2)  Add contactVerificationID field to incoming data
        3)  UPDATE contactVerificationID from existing Portal.ContactVerifications.id
        4)  DELETE Portal.ContactVerifications
        5)  DELETE Core.ContactVerifications records when all Portal.ContactVerifications records are deleted

************************************************************************************************************************************
*/
BEGIN
    SET NOCOUNT ON ;

    DECLARE @systemID           AS INT = 0 ; 


--  1)  Determine systemID from incoming @systemDBName
    SELECT  @systemID = id FROM dbo.Systems WHERE systemDBName = @systemDBName ;


--  2)  Add contactVerificationID field to incoming data
    ALTER TABLE #mc_contact_verification 
        ADD contactVerificationID UNIQUEIDENTIFIER NULL ;


--  3)  UPDATE contactVerificationID from existing Portal.ContactVerifications.id
    UPDATE  #mc_contact_verification
       SET  contactVerificationID = p.id
      FROM  #mc_contact_verification   AS m
INNER JOIN  Portal.ContactVerifications AS p ON p.portalID = m.id AND p.systemID = @systemID ;


--  4)  DELETE Portal.ContactVerifications
      WITH  records AS (
            SELECT  *
              FROM  Portal.ContactVerifications AS p
             WHERE  EXISTS ( SELECT  1
                               FROM  #mc_contact_verification AS m
                              WHERE  m.contactVerificationID = p.id AND p.systemID = @systemID ) )
    DELETE  records ;


--  5)  DELETE Core.ContactVerifications records when all Portal.ContactVerifications records are deleted
      WITH  records AS (
            SELECT * FROM Core.ContactVerifications AS c
             WHERE EXISTS ( SELECT  1
                              FROM  #mc_contact_verification AS m
                             WHERE  m.contactID = c.id )
               AND NOT EXISTS ( SELECT  1
                                  FROM  Portal.ContactVerifications AS p
                                 WHERE  p.id = c.id ) )
    DELETE  records ;

END
