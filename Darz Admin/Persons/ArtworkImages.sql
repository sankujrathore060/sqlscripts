CREATE TABLE ArtworkImages
(
	Id INT IDENTITY(1,1),
	ArtworkId INT,
	FileName NVARCHAR(500),
    Picture NVARCHAR(MAX),
    PictureHeight INT,
    PictureWidth INT,
    rowguid UNIQUEIDENTIFIER,
	ModifiedDate DATETIME NOT NULL,
	CONSTRAINT PK_ArtworkImages PRIMARY KEY (Id),
)
