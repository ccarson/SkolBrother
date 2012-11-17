ALTER TABLE dbo.ContactOrganizations
    ADD CONSTRAINT PK_ContactOrganizations 
    PRIMARY KEY CLUSTERED ( id ASC ) ; 
GO

ALTER TABLE dbo.ContactOrganizations
    ADD CONSTRAINT FK_ContactOrganizations_Organizations 
    FOREIGN KEY ( organizationsID ) 
    REFERENCES Core.Organizations ( id ) 
    ON DELETE NO ACTION ON UPDATE NO ACTION ;
GO

ALTER TABLE dbo.ContactOrganizations
    ADD CONSTRAINT FK_ContactOrganizations_Contacts 
    FOREIGN KEY ( contactsID ) 
    REFERENCES dbo.Contacts ( id ) 
    ON DELETE NO ACTION ON UPDATE NO ACTION ;
GO
