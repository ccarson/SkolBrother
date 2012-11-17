ALTER TABLE dbo.ContactOrgRoles
    ADD CONSTRAINT PK_ContactOrgRoles
    PRIMARY KEY CLUSTERED ( id ASC ) ;
GO

ALTER TABLE dbo.ContactOrgRoles
    ADD CONSTRAINT FK_ContactOrgRoles_Contacts 
    FOREIGN KEY ( contactsID ) REFERENCES dbo.Contacts ( id ) 
    ON DELETE NO ACTION ON UPDATE NO ACTION ;
GO

ALTER TABLE dbo.ContactOrgRoles
    ADD CONSTRAINT FK_ContactOrgRoles_Organizations 
    FOREIGN KEY ( organizationsID ) 
    REFERENCES Core.Organizations ( id ) 
    ON DELETE NO ACTION ON UPDATE NO ACTION ;
GO

ALTER TABLE dbo.ContactOrgRoles
    ADD CONSTRAINT FK_ContactOrgRoles_Roles 
    FOREIGN KEY ( rolesID ) 
    REFERENCES dbo.Roles ( id ) 
    ON DELETE NO ACTION ON UPDATE NO ACTION ;
