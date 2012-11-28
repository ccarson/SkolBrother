CREATE TABLE Core.ContactPhones (
    id          UNIQUEIDENTIFIER NOT NULL
  , contactsID  UNIQUEIDENTIFIER NOT NULL
  , phone       NVARCHAR (100)   NULL
  , extension   NVARCHAR (10)    NULL
  , typeID      INT              NULL
  , isDefault   BIT              NULL
  , isActive    BIT              NULL
  , isPublic    BIT              NULL
  , isAlert     BIT              NULL
  , isEmergency BIT              NULL
  , createdOn   DATETIME2 (7)    NOT NULL
  , createdBy   UNIQUEIDENTIFIER NOT NULL
  , updatedOn   DATETIME2 (7)    NULL
  , updatedBy   UNIQUEIDENTIFIER NULL ) ;
