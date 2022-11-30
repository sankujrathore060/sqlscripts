CREATE TABLE MagazineRelatedPosts
(
	Id INT IDENTITY(1,1),
	MagazineId INT NOT NULL,	
	RelatedMagazineId INT NOT NULL,
	ModifiedDate DATETIME NOT NULL,
	CONSTRAINT PK_MagazineRelatedPosts PRIMARY KEY (Id)
)