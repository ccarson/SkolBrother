CREATE TABLE Conversion.convertingTables (
    id                 INT           IDENTITY (1, 1) NOT NULL
  , tableName          NVARCHAR (50) NOT NULL
  , isReady            BIT           NOT NULL
  , conversionSequence INT           NULL ) ;

