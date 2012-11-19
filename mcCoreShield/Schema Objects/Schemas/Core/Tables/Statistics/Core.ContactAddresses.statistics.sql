CREATE STATISTICS statContactAddresses1
    ON Core.ContactAddresses( contactsID, id ) ;
GO

CREATE STATISTICS statContactAddresses2
    ON Core.ContactAddresses( state, id, contactsID ) ;
GO

CREATE STATISTICS statContactAddresses3
    ON Core.ContactAddresses( state, contactsID ) ;
