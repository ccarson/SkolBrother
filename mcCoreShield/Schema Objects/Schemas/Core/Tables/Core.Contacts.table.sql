CREATE TABLE Core.Contacts (
    id              UNIQUEIDENTIFIER NOT NULL
  , salutation      NVARCHAR (20)    NULL
  , jobTitle        NVARCHAR (255)   NULL
  , firstName       NVARCHAR (50)    NULL
  , initial         NVARCHAR (50)    NULL
  , lastName        NVARCHAR (50)    NULL
  , suffix          NVARCHAR (40)    NULL
  , email           NVARCHAR (50)    NULL
  , login           NVARCHAR (50)    NULL
  , password        NVARCHAR (500)   NULL
  , salt            NVARCHAR (35)    NULL
  , accessID        INT              NULL
  , expires         DATETIME2 (7)    NULL
  , hits            INT              NULL
  , lastLogin       DATETIME2 (0)    NULL
  , status          NVARCHAR (20)    NULL
  , datejoined      DATETIME2 (0)    NULL
  , membertype      INT              NULL
  , photo           NVARCHAR (120)   NULL
  , resume          NVARCHAR (120)   NULL
  , thumb           NVARCHAR (120)   NULL
  , PIN             INT              NULL
  , reset           BIT              NULL
  , mailsent        BIT              NULL
  , sysmember       INT              NULL
  , maildate        DATETIME2 (7)    NULL
  , updatesent      DATETIME2 (7)    NULL
  , updatenum       INT              NULL
  , nosend          BIT              NULL
  , hidden          BIT              NULL
  , securityLevel   INT              NULL
  , review          BIT              NULL
  , q1              NVARCHAR (50)    NULL
  , q2              NVARCHAR (50)    NULL
  , q3              NVARCHAR (50)    NULL
  , iAnswer         NVARCHAR (50)    NULL
  , ipMac           NVARCHAR (100)   NULL
  , frequencyID     INT              NULL
  , refer           INT              NULL
  , isActive        BIT              NULL
  , timeZone        NVARCHAR (35)    NULL
  , usesDaylight    BIT              NULL
  , tzOffset        INT              NULL
  , iDefaultQuota   INT              NULL
  , iDocUsage       DECIMAL (10)     NULL
  , assistID        INT              NULL
  , layout          INT              NULL
  , bTOS            BIT              NULL
  , bOnlineNow      BIT              NULL
  , uID             UNIQUEIDENTIFIER NULL
  , iwkgrplayout    INT              NULL
  , sAboutMe        NVARCHAR (500)   NULL
  , folderID        INT              NULL
  , signature       NVARCHAR (MAX)   NULL
  , bAuditLock      BIT              NULL
  , bProfileUpdate  BIT              NULL
  , bexpirereminder BIT              NULL
  , bPingSent       BIT              NULL
  , dPingDate       DATETIME2 (7)    NULL
  , inetwork        INT              NULL
  , createdOn       DATETIME2 (7)    NULL
  , createdBy       UNIQUEIDENTIFIER NULL
  , updatedOn       DATETIME2 (0)    NULL
  , updatedBy       UNIQUEIDENTIFIER NULL ) ;
