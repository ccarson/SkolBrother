CREATE UNIQUE NONCLUSTERED INDEX ixContactNotes
    ON Portal.ContactNotes( systemID ASC, portalID ASC )
        INCLUDE( id ) 
    ON [PRIMARY] ;
