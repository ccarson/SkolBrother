CREATE  NONCLUSTERED INDEX IX_Contacts1
    ON  Core.Contacts( Lastname ASC, Firstname ASC )
        INCLUDE ( id ) 
    WITH ( ALLOW_PAGE_LOCKS       = ON
         , ALLOW_ROW_LOCKS        = ON
         , PAD_INDEX              = OFF
         , SORT_IN_TEMPDB         = OFF
         , DROP_EXISTING          = OFF
         , IGNORE_DUP_KEY         = OFF
         , STATISTICS_NORECOMPUTE = OFF
         , ONLINE                 = OFF
         , MAXDOP                 = 0 )
    ON [PRIMARY] ;
GO

CREATE  NONCLUSTERED INDEX IX_Contacts2
    ON  Core.Contacts( id ASC, Firstname ASC, Lastname ASC ) 
    WITH ( ALLOW_PAGE_LOCKS       = ON
         , ALLOW_ROW_LOCKS        = ON
         , PAD_INDEX              = OFF
         , SORT_IN_TEMPDB         = OFF
         , DROP_EXISTING          = OFF
         , IGNORE_DUP_KEY         = OFF
         , STATISTICS_NORECOMPUTE = OFF
         , ONLINE                 = OFF
         , MAXDOP                 = 0 )
    ON [PRIMARY] ;

