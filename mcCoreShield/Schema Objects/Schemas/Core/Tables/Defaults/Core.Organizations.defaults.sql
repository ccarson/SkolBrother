ALTER TABLE Core.Organizations
    ADD CONSTRAINT DF_Organizations_brandID
    DEFAULT 1 FOR brandID ;
GO

ALTER TABLE Core.Organizations
    ADD CONSTRAINT DF_Organizations_isDemo
    DEFAULT 0 FOR isDemo ;
