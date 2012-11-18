ALTER TABLE dbo.ContactVerifications
    ADD CONSTRAINT PK_ContactVerifications
    PRIMARY KEY CLUSTERED ( id ASC ) ;
GO

ALTER TABLE dbo.ContactVerifications
    ADD CONSTRAINT FK_ContactVerifications_Contacts1
    FOREIGN KEY ( contactsID ) 
    REFERENCES Core.Contacts ( id ) 
    ON DELETE NO ACTION ON UPDATE NO ACTION ;
GO

ALTER TABLE dbo.ContactVerifications
    ADD CONSTRAINT FK_ContactVerifications_Contacts2
    FOREIGN KEY ( verified_by ) 
    REFERENCES Core.Contacts ( id ) 
    ON DELETE NO ACTION ON UPDATE NO ACTION ;
