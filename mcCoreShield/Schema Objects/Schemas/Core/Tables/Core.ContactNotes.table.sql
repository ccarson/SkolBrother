CREATE TABLE Core.ContactNotes (
    id          UNIQUEIDENTIFIER    NOT NULL
  , contactsID  UNIQUEIDENTIFIER    NOT NULL
  , typeID      INT                 NULL
  , adminID     UNIQUEIDENTIFIER    NULL
  , notes       NVARCHAR (500)      NULL
  , createdOn   DATETIME2 (7)       NULL
  , createdBy   UNIQUEIDENTIFIER    NULL
  , updatedOn   DATETIME2 (0)       NULL
  , updatedBy   UNIQUEIDENTIFIER    NULL ) ;
