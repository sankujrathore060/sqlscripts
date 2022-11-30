-- GetArtistById @ArtistId = 67
CREATE PROCEDURE [dbo].[GetArtistById] 
	@ArtistId INT = 0
AS
BEGIN
	SET TRANSACTION ISOLATION LEVEL SNAPSHOT;
	SET NOCOUNT ON;

	SELECT 
		ar.*,
		CASE WHEN (ap.IsMainProfession = 1) THEN ap.ProfessionId
		ELSE 0 END AS ProfessionId
	FROM 
		Artist AS ar WITH(NOLOCK)
		LEFT JOIN ArtistProfession AS ap WITH(NOLOCK) ON ar.Id = ap.ArtistId
	WHERE
		ar.Id = @ArtistId
	ORDER BY ap.IsMainProfession DESC;
END	