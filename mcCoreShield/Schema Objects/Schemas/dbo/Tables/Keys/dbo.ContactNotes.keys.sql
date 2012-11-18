ALTER TABLE dbo.ContactNotes
    ADD CONSTRAINT PK_ContactNotes
    PRIMARY KEY CLUSTERED ( id ASC ) ;
GO

ALTER TABLE dbo.ContactNotes
    ADD CONSTRAINT FK_ContactNotes_Contacts1
    FOREIGN KEY ( contactsID ) 
    REFERENCES Core.Contacts ( id ) 
    ON DELETE NO ACTION ON UPDATE NO ACTION ;
GO

ALTER TABLE dbo.ContactNotes
    ADD CONSTRAINT FK_ContactNotes_Contacts2
    FOREIGN KEY ( adminID ) 
    REFERENCES Core.Contacts ( id ) 
    ON DELETE NO ACTION ON UPDATE NO ACTION ;

