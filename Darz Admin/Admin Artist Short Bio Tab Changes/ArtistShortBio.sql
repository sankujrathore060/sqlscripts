CREATE TABLE ArtistShortBio
(
	ArtistShortBioId INT IDENTITY(1,1),
	ArtistId INT NOT NULL,
	Body NVARCHAR(MAX),
	BodyFa NVARCHAR(MAX),
	Quote NVARCHAR(MAX),
	QuoteFa NVARCHAR(MAX),
	VerificationStatus INT,
	CheckingType INT,
	CoverImage NVARCHAR(MAX),
	CoverImageWidth INT,
	CoverImageHeight INT,
	CreatedDate DATETIME,
	ModifiedDate DATETIME
	CONSTRAINT PK_ArtistShortBio PRIMARY KEY (ArtistShortBioId)
)
