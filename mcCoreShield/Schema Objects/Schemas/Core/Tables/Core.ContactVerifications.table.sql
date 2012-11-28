CREATE TABLE Core.ContactVerifications (
    id            UNIQUEIDENTIFIER NOT NULL
  , contactsID    UNIQUEIDENTIFIER NOT NULL
  , verifiedBy    UNIQUEIDENTIFIER NULL
  , verifiedOn    DATETIME2 (7)    NULL
  , createdOn     DATETIME2 (7)    NOT NULL
  , createdBy     UNIQUEIDENTIFIER NOT NULL
  , updatedOn     DATETIME2 (7)    NULL
  , updatedBy     UNIQUEIDENTIFIER NULL ) ;
