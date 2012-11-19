ALTER TABLE Portal.ContactAddresses
    ADD CONSTRAINT PK_ContactAddresses
    PRIMARY KEY CLUSTERED ( id ASC, systemID ASC ) ;
GO

ALTER TABLE Portal.ContactAddresses
    ADD CONSTRAINT FK_ContactAddresses_Systems
    FOREIGN KEY ( systemID )
    REFERENCES dbo.Systems ( id )
    ON DELETE NO ACTION ON UPDATE NO ACTION ;
GO

ALTER TABLE Portal.ContactAddresses
    ADD CONSTRAINT FK_ContactAddresses_CorePortal
    FOREIGN KEY ( id )
    REFERENCES Core.ContactAddresses ( id )
    ON DELETE NO ACTION ON UPDATE NO ACTION ;


