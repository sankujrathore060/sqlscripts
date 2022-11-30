CREATE TABLE ArtistVerification
(
	Id INT IDENTITY(1,1),
	ArtistId INT NOT NULL,
	IsVerified BIT,
	ArtistLastModifiedDate DATETIME,
	VerifiedByFa NVARCHAR(255),
	VerifiedBy NVARCHAR(255),
	VerifiedEmails VARCHAR(MAX),
	MainVerifiedEmail VARCHAR(MAX),
	PhoneNumber VARCHAR(255),
	CreatedDate DATETIME,
	ModifiedDate DATETIME
	CONSTRAINT PK_ArtistVerification PRIMARY KEY (Id)
)
