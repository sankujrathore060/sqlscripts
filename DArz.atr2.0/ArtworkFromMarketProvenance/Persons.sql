CREATE TABLE Persons
(
	Id INT IDENTITY(1,1),
	Name NVARCHAR(100),
	NameFa NVARCHAR(100),
	CreationDate DATETIME NOT NULL,
	ModifiedDate DATETIME NOT NULL,
	CONSTRAINT PK_Persons PRIMARY KEY (Id),
)

