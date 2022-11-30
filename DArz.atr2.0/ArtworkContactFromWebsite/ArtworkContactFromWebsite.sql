CREATE TABLE ArtworkContactFromWebsite
(
	Id INT IDENTITY(1,1),
	ArtworkId INT NOT NULL,
	UserId UNIQUEIDENTIFIER,
	Message NVARCHAR(MAX),
	PageId INT,
	PageRelativeId INT,
	CreatedDate DATETIME
	CONSTRAINT PK_ArtworkContactFromWebsite PRIMARY KEY (Id)
)

ALTER tABLE ArtworkContactFromWebsite 
ADD UserId UNIQUEIDENTIFIER