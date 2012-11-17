﻿CREATE NONCLUSTERED INDEX [_dta_index_transitionIdentities_8_1884338273__K2_K1_K3_K4]
    ON [dbo].[transitionIdentities]([transitionSystemsID] ASC, [id] ASC, [convertedTableID] ASC, [legacyID] ASC) WITH (ALLOW_PAGE_LOCKS = ON, ALLOW_ROW_LOCKS = ON, PAD_INDEX = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, IGNORE_DUP_KEY = OFF, STATISTICS_NORECOMPUTE = OFF, ONLINE = OFF, MAXDOP = 0)
    ON [PRIMARY];

