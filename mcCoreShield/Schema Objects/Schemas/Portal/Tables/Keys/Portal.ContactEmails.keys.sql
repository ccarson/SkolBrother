ALTER TABLE Portal.ContactEmails
    ADD CONSTRAINT PK_ContactEmails
    PRIMARY KEY CLUSTERED ( id ASC, systemID ASC ) ;
GO

ALTER TABLE Portal.ContactEmails
    ADD CONSTRAINT FK_ContactEmails_Systems
    FOREIGN KEY ( systemID )
    REFERENCES dbo.Systems ( id )
    ON DELETE NO ACTION ON UPDATE NO ACTION ;
GO

ALTER TABLE Portal.ContactEmails
    ADD CONSTRAINT FK_ContactEmails_Core
    FOREIGN KEY ( id )
    REFERENCES Core.ContactEmails ( id )
    ON DELETE NO ACTION ON UPDATE NO ACTION ;


