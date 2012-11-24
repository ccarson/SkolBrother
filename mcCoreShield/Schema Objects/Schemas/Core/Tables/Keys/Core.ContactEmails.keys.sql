ALTER TABLE Core.ContactEmails
    ADD CONSTRAINT PK_ContactEmails
    PRIMARY KEY CLUSTERED ( id ASC ) ;
GO

ALTER TABLE Core.ContactEmails
    ADD CONSTRAINT FK_ContactEmails_Contacts 
    FOREIGN KEY ( contactsID ) 
    REFERENCES Core.Contacts ( id ) 
    ON DELETE NO ACTION ON UPDATE NO ACTION ;
