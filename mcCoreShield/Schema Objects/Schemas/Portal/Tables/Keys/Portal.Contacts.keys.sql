ALTER TABLE Portal.Contacts
    ADD CONSTRAINT PK_Contacts
    PRIMARY KEY CLUSTERED ( id ASC, systemID ASC ) ;
GO

ALTER TABLE Portal.Contacts
    ADD CONSTRAINT FK_Contacts_Systems
    FOREIGN KEY ( systemID )
    REFERENCES dbo.Systems ( id )
    ON DELETE NO ACTION ON UPDATE NO ACTION ;
GO

ALTER TABLE Portal.Contacts
    ADD CONSTRAINT FK_Contacts_Core
    FOREIGN KEY ( id )
    REFERENCES Core.Contacts ( id )
    ON DELETE NO ACTION ON UPDATE NO ACTION ;


