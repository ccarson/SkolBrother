﻿CREATE TABLE [dbo].[contentTraining] (
    [id]                 UNIQUEIDENTIFIER NOT NULL,
    [agencyID]           INT              NULL,
    [locationID]         INT              NULL,
    [startTime]          DATETIME2 (7)    NULL,
    [endTime]            DATETIME2 (7)    NULL,
    [registrationStarts] DATETIME2 (7)    NULL,
    [registrationEnds]   DATETIME2 (7)    NULL,
    [sponsor]            NVARCHAR (150)   NULL,
    [owner]              NVARCHAR (150)   NULL,
    [targetAudience]     NVARCHAR (150)   NULL,
    [courseStatus]       NVARCHAR (150)   NULL,
    [preRequisites]      NVARCHAR (150)   NULL,
    [application]        NVARCHAR (150)   NULL,
    [selection]          NVARCHAR (150)   NULL,
    [questions]          NVARCHAR (150)   NULL,
    [name]               NVARCHAR (500)   NOT NULL,
    [url]                NVARCHAR (500)   NOT NULL,
    [description]        NVARCHAR (MAX)   NOT NULL,
    [otherInformation]   NVARCHAR (MAX)   NOT NULL,
    [isActive]           BIT              NOT NULL,
    [created]            DATETIME2 (7)    NOT NULL,
    [createdBy]          INT              NOT NULL,
    [updated]            DATETIME2 (7)    NULL,
    [updatedBy]          INT              NULL
);

