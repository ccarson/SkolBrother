﻿ALTER TABLE [dbo].[mc_groups]
    ADD CONSTRAINT [DF_mc_groups_allownotes] DEFAULT ((1)) FOR [allownotes];
