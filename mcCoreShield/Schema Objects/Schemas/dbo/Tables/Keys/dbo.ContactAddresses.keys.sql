ALTER TABLE dbo.ContactAddresses
    ADD CONSTRAINT PK_ContactAddresses
    PRIMARY KEY CLUSTERED ( id ASC ) ;
GO

ALTER TABLE dbo.ContactAddresses
    ADD CONSTRAINT FK_ContactAddresses_Contacts 
    FOREIGN KEY ( contactsID ) 
    REFERENCES Core.Contacts ( id ) 
    ON DELETE NO ACTION ON UPDATE NO ACTION ;
