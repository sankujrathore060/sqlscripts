CREATE TABLE ArtistSeries
(
	Id INT IDENTITY(1,1),
	Name NVARCHAR(50) NOT NULL,
	NameFa NVARCHAR(50) NOT NULL,
	ArtistId INT NOT NULL,
	CreatedDate DATETIME NOT NULL,
	CONSTRAINT PK_ArtistSeries PRIMARY KEY (Id)
)