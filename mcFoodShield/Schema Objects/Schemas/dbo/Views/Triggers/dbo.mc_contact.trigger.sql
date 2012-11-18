﻿CREATE TRIGGER  dbo.tr_mc_contact
            ON  dbo.mc_contact
INSTEAD OF INSERT, DELETE, UPDATE
AS
/*
************************************************************************************************************************************

    Trigger:  dbo.tr_mc_contact
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
          , @errorMessage   AS NVARCHAR(MAX) 
          , @unknownUser    AS UNIQUEIDENTIFIER = N'00000000-0000-0000-0000-000000000001' 

    SELECT  @systemID = id
      FROM  dbo.transitionSystems
     WHERE  systemName = db_name() ;

    CREATE TABLE #mc_contact ( id               INT
                             , Salutation       NVARCHAR (20)
                             , JobTitle         NVARCHAR (255)
                             , Firstname        NVARCHAR (50)
                             , Initial          NVARCHAR (50)
                             , Lastname         NVARCHAR (50)
                             , Suffix           NVARCHAR (40)
                             , Email            NVARCHAR (50)
                             , Login            NVARCHAR (50)
                             , Password         NVARCHAR (500)
                             , salt             NVARCHAR (35)
                             , AccessID         INT
                             , Expires          DATETIME2 (7)
                             , Hits             INT
                             , LastLogin        DATETIME2 (0)
                             , Status           NVARCHAR (20)
                             , ModifiedBy       NVARCHAR (50)
                             , DateModified     DATETIME2 (0)
                             , datejoined       DATETIME2 (0)
                             , membertype       INT
                             , photo            NVARCHAR (120)
                             , resume           NVARCHAR (120)
                             , thumb            NVARCHAR (120)
                             , PIN              INT
                             , reset            BIT
                             , mailsent         BIT
                             , sysmember        INT
                             , maildate         DATETIME2 (7)
                             , updatesent       DATETIME2 (7)
                             , updatenum        INT
                             , nosend           BIT
                             , hidden           BIT
                             , security_level   INT
                             , review           BIT
                             , Q1               NVARCHAR (50)
                             , Q2               NVARCHAR (50)
                             , Q3               NVARCHAR (50)
                             , iAnswer          NVARCHAR (50)
                             , ipMac            NVARCHAR (100)
                             , frequency_id     INT
                             , refer            INT
                             , is_active        BIT
                             , TimeZone         NVARCHAR (35)
                             , usesDaylight     BIT
                             , TzOffset         INT
                             , iDefault_Quota   INT
                             , iDoc_Usage       DECIMAL (10)
                             , assist_id        INT
                             , layout           INT
                             , bTOS             BIT
                             , bOnlineNow       BIT
                             , uID              UNIQUEIDENTIFIER
                             , iwkgrplayout     INT
                             , sAboutMe         NVARCHAR (500)
                             , folder_id        INT
                             , signature        NVARCHAR (MAX)
                             , dateAdded        DATETIME2(7)
                             , addedBy          INT
                             , bAuditLock       BIT
                             , bProfileUpdate   BIT
                             , bexpirereminder  BIT
                             , bPingSent        BIT
                             , dPingDate        DATETIME2 (7)
                             , bVerified        BIT
                             , iVerifiedBy      INT
                             , dVerifiedDate    DATETIME2 (7)
                             , inetwork         INT ) ;

    IF  EXISTS ( SELECT 1 FROM inserted )
        IF  EXISTS ( SELECT 1 FROM deleted )
            SELECT  @operation = N'UPDATE' ;
        ELSE
            SELECT  @operation = N'INSERT' ;
    ELSE
        SELECT  @operation = N'DELETE' ;
        
    INSERT #mc_contact
    SELECT * FROM deleted  WHERE @operation = 'DELETE'
        UNION ALL
    SELECT * FROM inserted WHERE @operation <> 'DELETE'  ;
    SELECT  @recordsIN = @@ROWCOUNT ;

    ALTER TABLE #mc_contact ADD 
        contactID   UNIQUEIDENTIFIER DEFAULT NEWSEQUENTIALID()  WITH VALUES 
      , createdID   UNIQUEIDENTIFIER DEFAULT @unknownUser()     WITH VALUES 
      , updatedID   UNIQUEIDENTIFIER DEFAULT @unknownUser()     WITH VALUES 
      , verifiedID  UNIQUEIDENTIFIER DEFAULT @unknownUser()     WITH VALUES ; 
        
    EXECUTE @rc = Portal.process_mc_contact @systemDBName
                                          , @recordsIN
                                          , @operation
                                          , @errorMessage OUTPUT ;

    IF ( @rc > 0 )
        RAISERROR ( @errorMessage, 16, @rc ) ;
END