﻿ALTER TABLE [dbo].[cal_event]
    ADD CONSTRAINT [DF_cal_event_EventAddDate] DEFAULT (NULL) FOR [EventAddDate];

