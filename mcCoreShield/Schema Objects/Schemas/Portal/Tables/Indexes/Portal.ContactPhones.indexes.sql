CREATE UNIQUE NONCLUSTERED INDEX ixContactPhones
    ON Portal.ContactPhones( systemID ASC, portalID ASC )
        INCLUDE( id ) 
    ON [PRIMARY] ;
