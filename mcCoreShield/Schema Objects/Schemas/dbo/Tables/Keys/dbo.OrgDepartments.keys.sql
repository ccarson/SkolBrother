ALTER TABLE dbo.OrgDepartments
    ADD CONSTRAINT PK_OrgDepartments
    PRIMARY KEY CLUSTERED ( id ASC ) ;
GO

ALTER TABLE dbo.OrgDepartments
    ADD CONSTRAINT FK_OrgDepartments_Organizations 
    FOREIGN KEY ( organizationsID ) 
    REFERENCES Core.Organizations ( id ) 
    ON DELETE NO ACTION ON UPDATE NO ACTION ;
GO
