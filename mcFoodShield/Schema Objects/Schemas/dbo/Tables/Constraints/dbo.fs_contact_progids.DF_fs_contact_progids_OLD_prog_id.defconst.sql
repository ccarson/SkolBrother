﻿ALTER TABLE [dbo].[fs_contact_progids]
    ADD CONSTRAINT [DF_fs_contact_progids_OLD_prog_id] DEFAULT ('0') FOR [OLD_prog_id];

