CREATE PROCEDURE [dbo].[MagazineRelatedPosts_InsertOrUpdate]
	@Id INT = 0,
	@MagazineId INT = 0,	
	@RelatedMagazineId INT = 0,
	@ModifiedDate DATETIME
AS
BEGIN
	SET TRANSACTION ISOLATION LEVEL SNAPSHOT;

	IF @Id > 0
	BEGIN			
		UPDATE MagazineRelatedPosts 
		SET MagazineId = @MagazineId, RelatedMagazineId = @RelatedMagazineId, ModifiedDate = @ModifiedDate
		WHERE Id = @Id
	END
	ELSE
	BEGIN	
		INSERT INTO MagazineRelatedPosts(MagazineId, RelatedMagazineId, ModifiedDate)
		VALUES (@MagazineId, @RelatedMagazineId, @ModifiedDate)
	END
END