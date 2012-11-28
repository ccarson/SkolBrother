CREATE NONCLUSTERED INDEX ix_ContactEmails
    ON Core.ContactEmails( contactsID ASC, email ASC ) 
    ON [PRIMARY] ;
