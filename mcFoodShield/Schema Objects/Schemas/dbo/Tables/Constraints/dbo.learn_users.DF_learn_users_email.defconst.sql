﻿ALTER TABLE [dbo].[learn_users]
    ADD CONSTRAINT [DF_learn_users_email] DEFAULT (N'') FOR [email];

