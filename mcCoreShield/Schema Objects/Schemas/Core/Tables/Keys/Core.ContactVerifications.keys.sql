ALTER TABLE Core.ContactVerifications
    ADD CONSTRAINT PK_ContactVerifications
    PRIMARY KEY CLUSTERED ( id ASC ) ;
GO

ALTER TABLE Core.ContactVerifications
    ADD CONSTRAINT FK_ContactVerifications_Contacts
    FOREIGN KEY ( contactsID ) 
    REFERENCES Core.Contacts ( id ) 
    ON DELETE NO ACTION ON UPDATE NO ACTION ;
GO

ALTER TABLE Core.ContactVerifications
    ADD CONSTRAINT FK_ContactVerifications_Verified
    FOREIGN KEY ( verifiedBy ) 
    REFERENCES Core.Contacts ( id ) 
    ON DELETE NO ACTION ON UPDATE NO ACTION ;
