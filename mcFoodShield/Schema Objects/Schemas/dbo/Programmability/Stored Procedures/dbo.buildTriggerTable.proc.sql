CREATE PROCEDURE dbo.buildTriggerTable ( @tableName NVARCHAR(100) ) 
AS
/*
************************************************************************************************************************************

    Trigger:  dbo.buildTriggerTable
     Author:  Chris Carson
    Purpose:  Build a temporary table for data based on INFORMATION_SCHEMA.COLUMNS

    revisor     date          description
    ---------   -----------   ----------------------------
    ccarson     ###DATE###    Created


    Logic Summary:
        1)  Validate input
        2)  Build ALTER TABLE statements for each data_type
        3)  Execute ALTER TABLE statement on temporary table, filling out temp table

************************************************************************************************************************************
*/
BEGIN

    DECLARE @tempTableName  AS NVARCHAR(50)
          , @objectName     AS NVARCHAR(50)
          , @SQL            AS NVARCHAR(MAX)
          , @SQL1           AS NVARCHAR(MAX)
          , @SQL2           AS NVARCHAR(MAX) ;


    SELECT  @tempTableName = '#' + @tableName
          , @objectName    = 'tempdb..#' + @tableName ;

--  1)  Validate input
    IF  OBJECT_ID ( @objectName ) IS NULL
    BEGIN
        RAISERROR ( 'buildTriggerTable invoked improperly', 16, 1 )
        RETURN 1 ;
    END

    IF NOT EXISTS ( SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = @tableName )
    BEGIN
        RAISERROR ( 'Table %s does not exist ', 16, 1, @tableName ) ;
        RETURN 2 ;
    END

--  2)  create temporary SQL table holding column definitions
    DECLARE @columns AS TABLE ( ordinal     INT
                              , name        NVARCHAR (50)
                              , definition  NVARCHAR (200)
                              , precision   INT
                              , scale       INT
                              , nullable    BIT ) ;

    INSERT  @columns
    SELECT  ordinal_position
          , column_name
          , data_type
          , CASE
                WHEN DATA_TYPE LIKE '%CHAR' THEN CHARACTER_MAXIMUM_LENGTH
                WHEN DATA_TYPE LIKE 'DATE%' THEN DATETIME_PRECISION
                WHEN DATA_TYPE = 'decimal'  THEN NUMERIC_PRECISION
                WHEN DATA_TYPE = 'numeric'  THEN NUMERIC_PRECISION
                ELSE NULL
            END
          , CASE
                WHEN DATA_TYPE = 'decimal' THEN NUMERIC_SCALE
                WHEN DATA_TYPE = 'numeric' THEN NUMERIC_SCALE
                ELSE NULL
            END
          , CASE IS_NULLABLE WHEN 'YES' THEN 1 ELSE 0 END
      FROM  INFORMATION_SCHEMA.COLUMNS
     WHERE  TABLE_NAME = @tableName;

--  3)  UPDATE definitions based on DATA_TYPE
    UPDATE  @columns
       SET  definition = definition + ' ('
                       + CAST ( precision AS NVARCHAR(20) ) + ','
                       + CAST ( scale     AS NVARCHAR(20) ) + ') '
     WHERE  definition IN ( 'decimal', 'numeric' ) ;

    UPDATE  @columns
       SET  definition = definition + ' ('
                       + CAST ( precision AS NVARCHAR(20) ) + ') '
     WHERE  definition like '%CHAR'
        or  definition  like 'Datetime%' ;

    UPDATE  @columns
       SET  definition = REPLACE( definition, '-1', 'MAX' ) ;

    UPDATE  @columns
       SET  definition = definition + CASE nullable WHEN 0 THEN ' NOT NULL 'ELSE ' NULL ' END ;


--  4)  build ALTER TABLE statement
    SELECT  @SQL1 = 'ALTER TABLE ' + @tempTableName + ' ADD ' + CHAR(13)
                  + '    ' + name + ' ' + definition + CHAR(13)
      from  @columns
     where  ordinal = 2 ;

    SELECT  @SQL2 = ISNULL(@SQL2,'') + '  , ' + name + ' ' + definition + CHAR(13)
      from  @columns
     WHERE  ordinal > 2
  ORDER BY  ordinal ;

    SELECT  @SQL = @sql1 + @sql2 + ' ;' 
    
    EXECUTE sp_executesql @SQL ; 
    
    RETURN 0 ; 

END