CREATE PROCEDURE [dbo].[MagazineReadMoreLinks_GetByMagazineId]
	@MagazineId INT = 0
AS
BEGIN
	SET TRANSACTION ISOLATION LEVEL SNAPSHOT;

	SELECT * 
	FROM MagazineReadMoreLinks WITH(nolock)
	WHERE (ISNULL(@MagazineId,0) = 0 OR (MagazineId = @MagazineId))
	ORDER BY ModifiedDate DESC
END