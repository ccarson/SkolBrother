CREATE VIEW dbo.mc_contact_verification
AS
/*
************************************************************************************************************************************

       View:    dbo.mc_contact_verification
     Author:    Chris Carson
    Purpose:    Portal view of Core.ContactEmails joined on Portal.ContactEmails

    revisor    date            description
    ---------  -----------     ----------------------------
    ccarson    ###DATE###      Created

************************************************************************************************************************************
*/

    SELECT  id              = v.id           
          , user_id         = v.user_id      
          , verified_by     = v.verified_by  
          , verified_date   = v.verified_date
      FROM  Portal.mc_contact_verification AS v
     WHERE  v.portalDB = DB_NAME() ;