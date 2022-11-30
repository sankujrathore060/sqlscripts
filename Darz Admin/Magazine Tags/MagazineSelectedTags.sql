CREATE TABLE MagazineSelectedTags
(
	MagazineSelectedTagId INT IDENTITY(1,1),
	MagazineId INT NOT NULL,
	MagazineTagId INT NOT NULL,
	CreatedDate DATETIME NOT NULL,
	CONSTRAINT PK_MagazineSelectedTags PRIMARY KEY (MagazineSelectedTagId),
	CONSTRAINT FK_MagazineSelectedTags_Magazines FOREIGN KEY (MagazineId)
    REFERENCES Magazines(Id),
	CONSTRAINT FK_MagazineSelectedTags_MagazineTags FOREIGN KEY (MagazineTagId)
    REFERENCES MagazineTags(Id)
)