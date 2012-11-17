﻿ALTER TABLE [dbo].[pt_issues]
    ADD CONSTRAINT [PK_pt_issues_issueID] PRIMARY KEY CLUSTERED ([issueID] ASC) WITH (FILLFACTOR = 90, ALLOW_PAGE_LOCKS = ON, ALLOW_ROW_LOCKS = ON, PAD_INDEX = OFF, IGNORE_DUP_KEY = OFF, STATISTICS_NORECOMPUTE = OFF);

