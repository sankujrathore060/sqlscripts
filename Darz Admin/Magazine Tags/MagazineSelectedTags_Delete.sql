CREATE PROCEDURE [dbo].[MagazineSelectedTags_Delete]
	@Id INT
AS 
BEGIN
	SET TRANSACTION ISOLATION LEVEL SNAPSHOT;

	DELETE FROM MagazineSelectedTags
	WHERE MagazineSelectedTagId = @Id
END