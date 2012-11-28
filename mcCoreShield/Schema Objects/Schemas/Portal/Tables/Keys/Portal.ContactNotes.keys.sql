ALTER TABLE Portal.ContactNotes
    ADD CONSTRAINT PK_ContactNotes
    PRIMARY KEY CLUSTERED ( id ASC ) ;
GO

ALTER TABLE Portal.ContactNotes
    ADD CONSTRAINT FK_ContactNotes_Systems
    FOREIGN KEY ( systemID )
    REFERENCES dbo.Systems ( id )
    ON DELETE NO ACTION ON UPDATE NO ACTION ;
GO

ALTER TABLE Portal.ContactNotes
    ADD CONSTRAINT FK_ContactNotes_Core
    FOREIGN KEY ( id )
    REFERENCES Core.ContactNotes ( id )
    ON DELETE NO ACTION ON UPDATE NO ACTION ;
