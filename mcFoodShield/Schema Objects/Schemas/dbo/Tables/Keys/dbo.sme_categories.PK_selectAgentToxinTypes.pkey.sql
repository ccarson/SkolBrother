﻿ALTER TABLE [dbo].[sme_categories]
    ADD CONSTRAINT [PK_selectAgentToxinTypes] PRIMARY KEY CLUSTERED ([id] ASC) WITH (ALLOW_PAGE_LOCKS = ON, ALLOW_ROW_LOCKS = ON, PAD_INDEX = OFF, IGNORE_DUP_KEY = OFF, STATISTICS_NORECOMPUTE = OFF);

