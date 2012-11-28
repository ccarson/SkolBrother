ALTER TABLE Portal.ContactVerifications
    ADD CONSTRAINT PK_ContactVerifications
    PRIMARY KEY CLUSTERED ( id ASC, systemID ASC ) ;
GO

ALTER TABLE Portal.ContactVerifications
    ADD CONSTRAINT FK_ContactVerifications_Systems
    FOREIGN KEY ( systemID )
    REFERENCES dbo.Systems ( id )
    ON DELETE NO ACTION ON UPDATE NO ACTION ;
GO

ALTER TABLE Portal.ContactVerifications
    ADD CONSTRAINT FK_ContactVerifications_Core
    FOREIGN KEY ( id )
    REFERENCES Core.ContactVerifications ( id )
    ON DELETE NO ACTION ON UPDATE NO ACTION ;
