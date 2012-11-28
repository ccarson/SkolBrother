ALTER TABLE Portal.ContactPhones
    ADD CONSTRAINT PK_ContactPhones
    PRIMARY KEY CLUSTERED ( id ASC ) ;
GO

ALTER TABLE Portal.ContactPhones
    ADD CONSTRAINT FK_ContactPhones_Systems
    FOREIGN KEY ( systemID )
    REFERENCES dbo.Systems ( id )
    ON DELETE NO ACTION ON UPDATE NO ACTION ;
GO

ALTER TABLE dbo.ContactPhones
    ADD CONSTRAINT FK_ContactPhones_Core
    FOREIGN KEY ( id )
    REFERENCES Core.ContactPhones ( id )
    ON DELETE NO ACTION ON UPDATE NO ACTION ;
