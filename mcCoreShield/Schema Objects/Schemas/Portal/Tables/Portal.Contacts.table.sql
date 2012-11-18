CREATE TABLE Portal.Contacts (
    id          UNIQUEIDENTIFIER NOT NULL
  , systemID    INT              NOT NULL
  , isVerified  BIT              NULL
  , verifiedBy  UNIQUEIDENTIFIER NULL
  , verifiedOn  DATETIME2 (7)    NULL
  , createdOn   DATETIME2 (7)    NOT NULL
  , createdBy   UNIQUEIDENTIFIER NOT NULL
  , updatedOn   DATETIME2 (7)    NULL
  , updatedBy   UNIQUEIDENTIFIER NULL
  , portalID    INT              NOT NULL ) ;
