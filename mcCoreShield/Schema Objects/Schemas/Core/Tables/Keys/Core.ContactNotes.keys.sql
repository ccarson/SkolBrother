ALTER TABLE Core.ContactNotes
    ADD CONSTRAINT PK_ContactNotes
    PRIMARY KEY CLUSTERED ( id ASC ) ;
GO

ALTER TABLE Core.ContactNotes
    ADD CONSTRAINT FK_ContactNotes_Contacts
    FOREIGN KEY ( contactsID ) 
    REFERENCES Core.Contacts ( id ) 
    ON DELETE NO ACTION ON UPDATE NO ACTION ;
GO

ALTER TABLE Core.ContactNotes
    ADD CONSTRAINT FK_ContactNotes_Admin
    FOREIGN KEY ( adminID ) 
    REFERENCES Core.Contacts ( id ) 
    ON DELETE NO ACTION ON UPDATE NO ACTION ;

