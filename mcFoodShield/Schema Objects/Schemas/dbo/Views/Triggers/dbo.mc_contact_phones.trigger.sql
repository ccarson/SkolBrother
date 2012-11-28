CREATE TRIGGER  dbo.tr_mc_contact_phones
            ON  dbo.mc_contact_phones
INSTEAD OF INSERT, DELETE, UPDATE
AS
/*
************************************************************************************************************************************

    Trigger:  dbo.tr_mc_contact_phones
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

    CREATE TABLE #mc_contact_phones ( id   INT ) ; 
    
    EXECUTE @rc = dbo.buildTriggerTable @tableName = 'mc_contact_phones' ; 
    
    IF  ( @rc > 0 )
    BEGIN
        RAISERROR( 'buildTriggerTable returned non-zero error code', 16, @rc ) ;
        RETURN ;
    END
    
    INSERT #mc_contact_phones
    SELECT * FROM inserted i 
        UNION ALL
    SELECT * FROM deleted d WHERE NOT EXISTS ( SELECT 1 FROM inserted i WHERE i.id = d.id ) ; 
    SELECT  @recordsIN = @@ROWCOUNT ;

    IF  EXISTS ( SELECT 1 FROM inserted ) 
        EXECUTE @rc = Portal.merge_mc_contact_phones @systemDBName
                                                   , @recordsIN
                                                   , @errorMessage OUTPUT ;
    ELSE
        EXECUTE @rc = Portal.delete_mc_contact_phones @systemDBName
                                                    , @recordsIN
                                                    , @errorMessage OUTPUT ;
        
    IF ( @rc > 0 )
        RAISERROR ( @errorMessage, 16, @rc ) ;
        
END