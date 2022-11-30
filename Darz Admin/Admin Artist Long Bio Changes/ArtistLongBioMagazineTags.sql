CREATE TABLE ArtistLongBioMagazineTags
(
	ArtistLongBioMagazineTagsId INT IDENTITY(1,1),
	ArtistLongBioId INT NOT NULL,
	ArtistId INT NOT NULL,
	MagazineTagId INT NOT NULL,
	CreatedDate DATETIME
	CONSTRAINT PK_ArtistLongBioMagazineTags PRIMARY KEY (ArtistLongBioMagazineTagsId)
)