CREATE TRIGGER  dbo.tr_mc_contact_emails 
            ON  dbo.mc_contact_emails
INSTEAD OF INSERT, UPDATE, DELETE
AS
/*
************************************************************************************************************************************

    Trigger:  dbo.tr_mc_contact_emails
     Author:  Chris Carson
    Purpose:  Prepares data for coreSHIELD processing

    revisor     date          description
    ---------   -----------   ----------------------------
    ccarson     ###DATE###    Created


    Logic Summary:

************************************************************************************************************************************
*/
BEGIN
    IF  @@ROWCOUNT = 0 RETURN ;

    SET NOCOUNT ON;

    DECLARE @rc             AS INT
          , @systemDBName   AS NVARCHAR(50) = DB_NAME()
          , @operation      AS NVARCHAR(50)
          , @recordsIN      AS INT
          , @errorMessage   AS NVARCHAR(MAX) ; 
          
    CREATE TABLE #mc_contact_emails ( id INT ) ; 
    
    EXECUTE @rc = dbo.buildTriggerTable @tableName = 'mc_contact_emails' ; 
    
    IF  ( @rc > 0 )
    BEGIN
        RAISERROR( 'buildTriggerTable returned non-zero error code', 16, @rc ) ;
        RETURN ;
    END
                            
    INSERT #mc_contact_emails
    SELECT * FROM inserted i 
        UNION ALL
    SELECT * FROM deleted d WHERE NOT EXISTS ( SELECT 1 FROM inserted i WHERE i.id = d.id ) ; 
    SELECT  @recordsIN = @@ROWCOUNT ;

    IF  EXISTS ( SELECT 1 FROM inserted ) 
        EXECUTE @rc = Portal.mc_contact_emailsMerge @systemDBName
                                                  , @recordsIN
                                                  , @errorMessage OUTPUT ;
    ELSE
        EXECUTE @rc = Portal.mc_contact_emailsDelete @systemDBName
                                                   , @recordsIN
                                                   , @errorMessage OUTPUT ;
        
    IF ( @rc > 0 )
        RAISERROR ( @errorMessage, 16, @rc ) ;
END
