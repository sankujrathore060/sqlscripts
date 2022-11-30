CREATE TABLE MagazineReadMoreLinks
(
	Id INT IDENTITY(1,1),
	MagazineId INT,	
	Title  NVARCHAR(MAX),	
	TitleFa NVARCHAR(MAX),
	Link NVARCHAR(MAX),
	ModifiedDate DATETIME NOT NULL,
	CONSTRAINT PK_MagazineReadMoreLinks PRIMARY KEY (Id),
)

