﻿CREATE VIEW Portal.c_zip
/*
************************************************************************
      View:  Portal.c_zip
    Author:  Chris Carson
      Date:  2012-08-24
   Purpose:  retrieves portal version of coreZipCodes


revisor     date          description
---------   -----------   ----------------------------
ccarson     2012-08-24    Created


************************************************************************
*/
AS
    SELECT  TOP 100 PERCENT
            *
      FROM  Reference.ZipCodes
     ORDER  BY 1 ;
