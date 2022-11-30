ALTER PROCEDURE [dbo].[MagazineRelatedPosts_GetByMagazineId]
	@MagazineId INT = 0
AS
BEGIN
	SET TRANSACTION ISOLATION LEVEL SNAPSHOT;

	SELECT mrs.*, m.MagazineCoverImageUri 
	FROM MagazineRelatedPosts as mrs WITH(nolock)
	INNER JOIN Magazines as m ON mrs.MagazineId = m.Id
	WHERE (ISNULL(@MagazineId,0) = 0 OR (mrs.MagazineId = @MagazineId))
	ORDER BY ModifiedDate DESC
END