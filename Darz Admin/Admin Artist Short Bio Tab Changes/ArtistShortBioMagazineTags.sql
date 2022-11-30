CREATE TABLE ArtistShortBioMagazineTags
(
	ArtistShortBioMagazineTagsId INT IDENTITY(1,1),
	ArtistShortBioId INT NOT NULL,
	ArtistId INT NOT NULL,
	MagazineTagId INT NOT NULL,
	CreatedDate DATETIME
	CONSTRAINT PK_ArtistShortBioMagazineTags PRIMARY KEY (ArtistShortBioMagazineTagsId)
)
