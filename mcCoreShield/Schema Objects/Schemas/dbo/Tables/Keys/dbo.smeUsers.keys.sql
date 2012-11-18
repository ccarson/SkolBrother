ALTER TABLE dbo.smeUsers
    ADD CONSTRAINT PK_smeUsers
    PRIMARY KEY CLUSTERED ( id ASC ) ;
GO

ALTER TABLE dbo.smeUsers
    ADD CONSTRAINT FK_smeUsers_Contacts
    FOREIGN KEY ( userID )
    REFERENCES Core.Contacts ( id )
    ON DELETE NO ACTION ON UPDATE NO ACTION ;
GO

ALTER TABLE dbo.smeUsers
    ADD CONSTRAINT FK_smeUsers_smeLevels
    FOREIGN KEY ( levelID )
    REFERENCES dbo.smeLevels ( id )
    ON DELETE NO ACTION ON UPDATE NO ACTION ;
GO

ALTER TABLE dbo.smeUsers
    ADD CONSTRAINT FK_smeUsers_smeRecords
    FOREIGN KEY ( recordID )
    REFERENCES dbo.smeRecords ( id )
    ON DELETE NO ACTION ON UPDATE NO ACTION ;



