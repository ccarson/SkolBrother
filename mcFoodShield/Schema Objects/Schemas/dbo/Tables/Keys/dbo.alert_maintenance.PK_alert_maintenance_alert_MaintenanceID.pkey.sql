﻿ALTER TABLE [dbo].[alert_maintenance]
    ADD CONSTRAINT [PK_alert_maintenance_alert_MaintenanceID] PRIMARY KEY CLUSTERED ([alert_MaintenanceID] ASC) WITH (ALLOW_PAGE_LOCKS = ON, ALLOW_ROW_LOCKS = ON, PAD_INDEX = OFF, IGNORE_DUP_KEY = OFF, STATISTICS_NORECOMPUTE = OFF);

