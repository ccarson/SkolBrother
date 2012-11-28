CREATE TABLE Core.ContactSMEProfiles (
    id                 UNIQUEIDENTIFIER NOT NULL
  , contactsID         UNIQUEIDENTIFIER NOT NULL
  , areasOfExpertise   NVARCHAR (500)   NULL
  , discipline         NVARCHAR (500)   NULL
  , experience         NVARCHAR (MAX)   NULL
  , methodologiesTools NVARCHAR (MAX)   NULL
  , createdOn          DATETIME2 (7)    NOT NULL
  , createdBy          UNIQUEIDENTIFIER NOT NULL
  , updatedOn          DATETIME2 (7)    NULL
  , updatedBy          UNIQUEIDENTIFIER NULL ) ;
