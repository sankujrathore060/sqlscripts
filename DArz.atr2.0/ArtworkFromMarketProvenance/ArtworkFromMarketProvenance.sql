CREATE TABLE ArtworkFromMarketProvenance
(
	Id INT IDENTITY(1,1),
	Provenance NVARCHAR(50),
	ProvenanceFa NVARCHAR(50),
	OwnerId INT DEFAULT 0,
	CollectorId INT DEFAULT 0,
	BuyerId INT DEFAULT 0,
	GalleryId INT DEFAULT 0,
	Deal INT DEFAULT 0,
	CreationDate DATETIME NOT NULL,
	ModifiedDate DATETIME NOT NULL,
	CONSTRAINT PK_ArtworkFromMarketProvenance PRIMARY KEY (Id),
)

