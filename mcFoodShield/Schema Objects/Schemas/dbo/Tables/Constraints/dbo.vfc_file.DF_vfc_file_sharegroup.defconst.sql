﻿ALTER TABLE [dbo].[vfc_file]
    ADD CONSTRAINT [DF_vfc_file_sharegroup] DEFAULT ((0)) FOR [sharegroup];

