CREATE TABLE MagazineSource
(
	Id INT IDENTITY(1,1),
	MagazineId INT,
	SourceLink NVARCHAR(MAX),
	CreatedDate DATETIME NOT NULL,
	CONSTRAINT PK_MagazineSource PRIMARY KEY (Id),
	CONSTRAINT FK_MagazineSource_Magazines FOREIGN KEY (MagazineId)
	REFERENCES Magazines(Id)
)