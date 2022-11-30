ALTER PROCEDURE [dbo].[MagazineTagCategory_Delete]
	@Id INT
AS
BEGIN
	SET TRANSACTION ISOLATION LEVEL SNAPSHOT;

	UPDATE MagazineTags 
	SET TagCategoryId = 0 
	WHERE TagCategoryId = @Id

	DELETE FROM MagazineTagCategory
	WHERE Id = @Id
END