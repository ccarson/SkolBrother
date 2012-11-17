ALTER TABLE dbo.OrganizationSystems
    ADD CONSTRAINT PK_OrganizationSystems
    PRIMARY KEY CLUSTERED ( id ASC, systemID ASC ) ;
GO

ALTER TABLE dbo.OrganizationSystems
    ADD CONSTRAINT FK_OrganizationSystems_Systems
    FOREIGN KEY ( systemID )
    REFERENCES dbo.Systems ( id ) ;
GO

ALTER TABLE dbo.OrganizationSystems
    ADD CONSTRAINT FK_OrganizationSystems_Organizations
    FOREIGN KEY ( id )
    REFERENCES dbo.Organizations ( id )
    ON DELETE NO ACTION ON UPDATE NO ACTION ;


