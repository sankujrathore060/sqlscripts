
CREATE TABLE MagazineBodyImage
(
	Id INT IDENTITY(1,1),
	MagazineId INT,
	FileName NVARCHAR(200),
	BodyPicture NVARCHAR(256),
	BodyPictureHeight INT,
	BodyPictureWidth INT,
	ModifiedDate DATETIME NOT NULL,
	rowguid UNIQUEIDENTIFIER NOT NULL,
	CONSTRAINT PK_MagazinesBody PRIMARY KEY (Id)
)

ALTER Table MagazineBodyImage
ADD BodyImageInfo NVARCHAR(50), HyperLink NVARCHAR(MAX)

ALTER Table MagazineBodyImage
ADD BodyCode NVARCHAR(100)

