﻿ALTER TABLE [dbo].[plfSubscriberListSubscribers]
    ADD CONSTRAINT [PK_plfSubscriberListSubscribers] PRIMARY KEY CLUSTERED ([subscriberListSubscriberId] ASC) WITH (ALLOW_PAGE_LOCKS = ON, ALLOW_ROW_LOCKS = ON, PAD_INDEX = OFF, IGNORE_DUP_KEY = OFF, STATISTICS_NORECOMPUTE = OFF);

