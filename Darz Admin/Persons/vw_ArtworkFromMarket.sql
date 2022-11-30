CREATE VIEW [dbo].[vw_ArtworkFromMarket]
AS
	SELECT
		*
	FROM
		ArtWork WITH(NOLOCK)
	WHERE
		(Censorship IS NULL OR Censorship <> 1)
		AND VerificationStatus = 2
		AND IsArtworkFromMarket = 1;
