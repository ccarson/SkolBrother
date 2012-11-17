ALTER TABLE Portal.Organizations
    ADD CONSTRAINT PK_Organizations
    PRIMARY KEY CLUSTERED ( id ASC, systemID ASC ) ;
GO

ALTER TABLE Portal.Organizations
    ADD CONSTRAINT FK_Organizations_Systems
    FOREIGN KEY ( systemID )
    REFERENCES dbo.Systems ( id ) ;
GO

ALTER TABLE Portal.Organizations
    ADD CONSTRAINT FK_Organizations_Organizations
    FOREIGN KEY ( id )
    REFERENCES Core.Organizations ( id )
    ON DELETE NO ACTION ON UPDATE NO ACTION ;


