﻿CREATE TABLE dbo.Organizations (
    id        UNIQUEIDENTIFIER NOT NULL,
    Name      NVARCHAR (255)   NULL,
    Website   NVARCHAR (255)   NULL,
    Status    NVARCHAR (50)    NULL,
    Summary   NVARCHAR (500)   NULL,
    isActive  BIT              NULL,
    isDemo    BIT              NOT NULL,
    isTemp    BIT              NULL,
    brandID   INT              NOT NULL,
    CreatedBy UNIQUEIDENTIFIER NULL,
    UpdatedBy UNIQUEIDENTIFIER NULL,
    CreatedOn DATETIME2 (7)    NULL,
    UpdatedOn DATETIME2 (7)    NULL
);

