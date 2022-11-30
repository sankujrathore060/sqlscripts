CREATE TABLE [dbo].[MagazineCategory]
(
	[Id] INT IDENTITY(1,1),
	[Name] NVARCHAR(50) NOT NULL,
	[Namefa] NVARCHAR(50) NOT NULL,
	[ModifiedDate] DATETIME NOT NULL,
	[rowguid] UNIQUEIDENTIFIER NOT NULL,
	[OrderInSeries]  INT,
	[IsActive] BIT,
	[ParentCategoryId] INT CONSTRAINT DF_MagazineCategory_ParentCategoryId DEFAULT 0,
	CONSTRAINT PK_MagazineCategory PRIMARY KEY (Id)
);
