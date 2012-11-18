CREATE VIEW [dbo].[vw_transitionContacts] with schemabinding AS 
	SELECT id
		, transitionSystemsID
		, legacyID AS ContactsID
	FROM dbo.transitionIdentities AS ti
	WHERE EXISTS (
		SELECT 1
		FROM dbo.coreConvertedTables 
		WHERE id = ti.convertedTableID AND 
			tableName = 'mc_contact' )
