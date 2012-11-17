﻿ALTER TABLE [dbo].[chat_content]
    ADD CONSTRAINT [PK_chat_content_line_id] PRIMARY KEY CLUSTERED ([line_id] ASC) WITH (FILLFACTOR = 90, ALLOW_PAGE_LOCKS = ON, ALLOW_ROW_LOCKS = ON, PAD_INDEX = OFF, IGNORE_DUP_KEY = OFF, STATISTICS_NORECOMPUTE = OFF);

