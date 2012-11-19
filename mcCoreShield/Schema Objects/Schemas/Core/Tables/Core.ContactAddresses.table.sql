CREATE TABLE Core.ContactAddresses (
    id             UNIQUEIDENTIFIER NOT NULL
  , addressName    NVARCHAR (100)   NULL
  , contactsID     UNIQUEIDENTIFIER NOT NULL
  , addressType    INT              NULL
  , address1       NVARCHAR (200)   NULL
  , address2       NVARCHAR (200)   NULL
  , address3       NVARCHAR (200)   NULL
  , city           NVARCHAR (150)   NULL
  , state          NVARCHAR (50)    NULL
  , zip            NVARCHAR (20)    NULL
  , country        NVARCHAR (20)    NULL
  , isDefault      BIT              NULL
  , createdOn      DATETIME2 (7)    NULL 
  , createdBy      UNIQUEIDENTIFIER NULL 
  , updatedOn      DATETIME2 (7)    NULL 
  , updatedBy      UNIQUEIDENTIFIER NULL ) ;

