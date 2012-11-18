ALTER TABLE Core.Contacts
    ADD CONSTRAINT DF_Contacts_iDoc_Usage 
    DEFAULT 0
    FOR iDoc_Usage ;

