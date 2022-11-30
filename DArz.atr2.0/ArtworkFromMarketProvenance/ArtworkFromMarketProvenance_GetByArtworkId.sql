CREATE PROCEDURE [dbo].[ArtworkFromMarketProvenance_GetByArtworkId]
	@ArtworkId INT = 0
AS
BEGIN
	SET TRANSACTION ISOLATION LEVEL SNAPSHOT;

	SELECT * 
	FROM ArtworkFromMarketProvenance WITH(nolock)
	WHERE (ISNULL(@ArtworkId,0) = 0 OR (ArtworkId = @ArtworkId))
	ORDER BY CreationDate DESC
END