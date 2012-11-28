ALTER TABLE Portal.ContactSMEProfiles
    ADD CONSTRAINT PK_ContactSMEProfiles
    PRIMARY KEY CLUSTERED ( id ASC ) ;
GO

ALTER TABLE Portal.ContactSMEProfiles
    ADD CONSTRAINT FK_ContactSMEProfiles_Systems
    FOREIGN KEY ( systemID )
    REFERENCES dbo.Systems ( id )
    ON DELETE NO ACTION ON UPDATE NO ACTION ;
GO

ALTER TABLE Portal.ContactSMEProfiles
    ADD CONSTRAINT FK_ContactSMEProfiles_Core
    FOREIGN KEY ( id )
    REFERENCES Core.ContactSMEProfiles ( id )
    ON DELETE NO ACTION ON UPDATE NO ACTION ;
