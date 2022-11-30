CREATE PROCEDURE [dbo].[MagazineSelectedTags_Update]
	@Id INT,
	@MagazineId INT,
	@MagazineTagId INT
AS 
BEGIN
	SET TRANSACTION ISOLATION LEVEL SNAPSHOT;

	UPDATE MagazineSelectedTags
	SET MagazineId = @MagazineId, MagazineTagId = @MagazineTagId
	WHERE MagazineSelectedTagId = @Id
END

SP_HELPTEXT [InsertOrUpdateGalleryEvent]
