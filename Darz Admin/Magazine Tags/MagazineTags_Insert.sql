ALTER PROCEDURE [dbo].[MagazineTags_Insert]
	@Name NVARCHAR(50),
	@NameFa NVARCHAR(50),
	@TagCategoryId INT,
	@CreationDate DATETIME,
	@Description NVARCHAR(MAX)
AS 
BEGIN
	SET TRANSACTION ISOLATION LEVEL SNAPSHOT;

	INSERT INTO MagazineTags(Name, NameFa, CreationDate, TagCategoryId, [Description])
	VALUES (@Name, @NameFa, @CreationDate, @TagCategoryId, @Description)

	SELECT @@IDENTITY
END