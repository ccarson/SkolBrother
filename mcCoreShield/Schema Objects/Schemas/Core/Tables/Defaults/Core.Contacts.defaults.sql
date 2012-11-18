ALTER TABLE Core.Contacts
    ADD CONSTRAINT DF_Contacts_iDocUsage 
    DEFAULT 0
    FOR iDocUsage ;
