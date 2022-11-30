ALTER PROCEDURE [dbo].[MagazineTags_Update]
	@Id INT,
	@Name NVARCHAR(50),
	@NameFa NVARCHAR(50),
	@TagCategoryId INT,
	@Description NVARCHAR(MAX)
AS 
BEGIN
	SET TRANSACTION ISOLATION LEVEL SNAPSHOT;

	UPDATE MagazineTags
	SET Name = @Name, NameFa = @NameFa, TagCategoryId = @TagCategoryId, [Description] = @Description
	WHERE Id = @Id
END