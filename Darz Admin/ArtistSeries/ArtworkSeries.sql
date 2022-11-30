CREATE TABLE ArtworkSeries
(
	Id INT IDENTITY(1,1),
	ArtistSeriesId INT NOT NULL, 
	ArtworkId INT NOT NULL,
	ArtistId INT NOT NULL,
	CreatedDate DATETIME NOT NULL,
	CONSTRAINT PK_ArtworkSeries PRIMARY KEY (Id),
	CONSTRAINT FK_ArtworkSeries_ArtworkSeries FOREIGN KEY (ArtistSeriesId)
	REFERENCES ArtistSeries (Id),
	CONSTRAINT FK_ArtworkSeries_Artwork FOREIGN KEY (ArtworkId)
	REFERENCES Artwork (Id),
	CONSTRAINT FK_ArtworkSeries_Artist FOREIGN KEY (ArtistId)
	REFERENCES Artist (Id)
)