CREATE TABLE ArtistLongBioBodyImageList
(
	ArtistLongBioBodyImageListId INT IDENTITY(1,1),
	ArtistLongBioId INT NOT NULL,
	ArtistId INT NOT NULL,
	ImageLink NVARCHAR(MAX),
	ImageWidth INT,
	ImageHeight INT,
	CreatedDate DATETIME
	CONSTRAINT PK_ArtistLongBioBodyImageList PRIMARY KEY (ArtistLongBioBodyImageListId)
)