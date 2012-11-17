ALTER TABLE dbo.OrgLocations
    ADD CONSTRAINT PK_OrgLocations 
    PRIMARY KEY CLUSTERED ( id ASC ) ;
GO

ALTER TABLE dbo.OrgLocations
    ADD CONSTRAINT FK_OrgLocations_Organizations 
    FOREIGN KEY ( organizationsID ) 
    REFERENCES Core.Organizations ( id ) 
    ON DELETE NO ACTION ON UPDATE NO ACTION ;
GO
