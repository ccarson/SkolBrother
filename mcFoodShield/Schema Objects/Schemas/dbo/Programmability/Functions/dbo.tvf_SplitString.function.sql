CREATE FUNCTION dbo.tvf_SplitString ( @pString    AS NVARCHAR(4000)
                                    , @pDelimiter AS NCHAR(1) )
RETURNS TABLE
WITH SCHEMABINDING
AS
/*
************************************************************************************************************************************
            
   Function:    dbo.tvf_SplitString
     Author:    Chris Carson ( not author, see references below for credits )
    Purpose:    splits a delimited string, wickedly fast

    Revision History:
    revisor     date            description
    ---------   ----------      ----------------------------
    ccarson     2011-02-17      Implemented

    Function Arguments:
        @pString    NVARCHAR(MAX)      input string
        @systemID   NCHAR(1)            delimiter

    References:
        www.sqlservercentral.com/articles/Tally+Table/72993/
        www.sqlservercentral.com/articles/T-SQL/74118/
            ( fun ways to count quickly )
    
************************************************************************************************************************************
*/
RETURN

      WITH  E1 AS ( 
            SELECT N = 1 
                UNION ALL SELECT 1 UNION ALL SELECT 1 UNION ALL SELECT 1 
                UNION ALL SELECT 1 UNION ALL SELECT 1 UNION ALL SELECT 1 
                UNION ALL SELECT 1 UNION ALL SELECT 1 UNION ALL SELECT 1 ) , 
            E2 AS ( SELECT N = 1 FROM E1 AS a, E1 AS b ) ,
            E4 AS ( SELECT N = 1 FROM E2 AS a, E2 AS b ) , 
            E8 AS ( SELECT N = 1 FROM E4 AS a, E4 AS b ) , 
            
            cteTally AS (
            SELECT  TOP ( ISNULL( DATALENGTH( @pString )/2, 0 ) ) 
                    delimiterPosition = ROW_NUMBER() OVER ( ORDER BY ( SELECT NULL ) ) 
              FROM  E8 ) ,
              
            cteStart AS ( 
            SELECT  startingPosition = 1
                UNION ALL 
            SELECT  startingPosition = delimiterPosition + 1
              FROM  cteTally
             WHERE  SUBSTRING( @pString, delimiterPosition, 1 ) = @pDelimiter ) , 
             
            cteLen AS (
                 SELECT  startingPosition = startingPosition
                       , strLength        = ISNULL( NULLIF( CHARINDEX( @pDelimiter, @pString, startingPosition), 0 ) - startingPosition, DATALENGTH( @pString )/2 )
                   FROM cteStart ) 

    SELECT  ItemNumber = ROW_NUMBER() OVER( ORDER BY startingPosition )
          , Item       = SUBSTRING( @pString, startingPosition, strLength )
      FROM  cteLen ;
