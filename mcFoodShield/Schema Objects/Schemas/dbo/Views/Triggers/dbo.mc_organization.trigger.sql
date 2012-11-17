CREATE TRIGGER  dbo.tr_mc_organization
            ON  dbo.mc_organization
INSTEAD OF INSERT, DELETE, UPDATE
AS
/*
************************************************************************************************************************************

    Trigger:  dbo.tr_mc_organization
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

    CREATE TABLE #mc_organization ( id              INT
                                  , Name            NVARCHAR (255)
                                  , Website         NVARCHAR (255)
                                  , Status          NVARCHAR (50)
                                  , Summary         NVARCHAR (500)
                                  , type_id         INT
                                  , vertical_id     INT
                                  , Active          BIT
                                  , brand_id        INT
                                  , is_Demo         BIT
                                  , Temp            BIT
                                  , date_added      DATETIME2 (7)
                                  , added_by        INT
                                  , date_updated    DATETIME2 (7)
                                  , updated_by      INT ) ;

    IF  EXISTS ( SELECT 1 FROM inserted )
        IF  EXISTS ( SELECT 1 FROM deleted )
            SELECT  @operation = N'UPDATE' ;
        ELSE
            SELECT  @operation = N'INSERT' ;
    ELSE
        SELECT  @operation = N'DELETE' ;

    INSERT #mc_organization
    SELECT * FROM deleted  WHERE @operation = 'DELETE'
        UNION ALL
    SELECT * FROM inserted WHERE @operation <> 'DELETE'  ;
    SELECT  @recordsIN = @@ROWCOUNT ;

    ALTER TABLE #mc_organization 
        ADD organizationID UNIQUEIDENTIFIER 
        DEFAULT NEWSEQUENTIALID() WITH VALUES ;

    EXECUTE @rc = Portal.process_mc_organization @systemDBName
                                               , @recordsIN
                                               , @operation
                                               , @errorMessage OUTPUT ;

    IF ( @rc > 0 )
        RAISERROR ( @errorMessage, 16, @rc ) ;
END
