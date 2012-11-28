ALTER TABLE Core.ContactSMEProfiles
    ADD CONSTRAINT PK_ContactSMEProfiles 
    PRIMARY KEY CLUSTERED ( id ASC ) ;
GO

ALTER TABLE Core.ContactSMEProfiles
    ADD CONSTRAINT FK_ContactSMEProfiles_Contacts 
    FOREIGN KEY ( contactsID ) 
    REFERENCES Core.Contacts ( id ) 
    ON DELETE NO ACTION ON UPDATE NO ACTION ;
