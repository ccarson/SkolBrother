﻿ALTER TABLE [dbo].[mtsch_users]
    ADD CONSTRAINT [DF_mtsch_users_mtsch_userLevel] DEFAULT (NULL) FOR [mtsch_userLevel];

