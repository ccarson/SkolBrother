﻿ALTER TABLE [dbo].[kb_files]
    ADD CONSTRAINT [PK_kb_files_FileID] PRIMARY KEY CLUSTERED ([FileID] ASC) WITH (FILLFACTOR = 90, ALLOW_PAGE_LOCKS = ON, ALLOW_ROW_LOCKS = ON, PAD_INDEX = OFF, IGNORE_DUP_KEY = OFF, STATISTICS_NORECOMPUTE = OFF);
