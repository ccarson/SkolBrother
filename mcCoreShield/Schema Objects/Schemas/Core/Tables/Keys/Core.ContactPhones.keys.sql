ALTER TABLE Core.ContactPhones
    ADD CONSTRAINT PK_ContactPhones
    PRIMARY KEY CLUSTERED ( id ASC ) ;
GO

ALTER TABLE Core.ContactPhones
    ADD CONSTRAINT FK_ContactPhones_Contacts 
    FOREIGN KEY ( contactsID ) 
    REFERENCES Core.Contacts ( id ) 
    ON DELETE NO ACTION ON UPDATE NO ACTION ;
