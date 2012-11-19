CREATE TABLE Core.Organizations (
    id        UNIQUEIDENTIFIER NOT NULL
  , name      NVARCHAR (255)   NULL
  , website   NVARCHAR (255)   NULL
  , status    NVARCHAR (50)    NULL
  , summary   NVARCHAR (500)   NULL
  , isActive  BIT              NULL
  , isDemo    BIT              NOT NULL
  , isTemp    BIT              NULL
  , brandID   INT              NOT NULL
  , createdBy UNIQUEIDENTIFIER NULL
  , updatedBy UNIQUEIDENTIFIER NULL
  , createdOn DATETIME2 (7)    NULL
  , updatedOn DATETIME2 (7)    NULL ) ;
