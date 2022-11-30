ALTER PROCEDURE [dbo].[MagazineCategory_Delete]
	@Id int = 0 
AS
BEGIN
	SET NOCOUNT ON
	SET TRANSACTION ISOLATION LEVEL SNAPSHOT

	UPDATE MagazineCategory
	SET ParentCategoryId = 0
	WHERE ParentCategoryId = @Id

	DELETE FROM MagazineCategory
	WHERE Id = @Id
END
