ALTER PROCEDURE  [dbo].[Artwork_ArtfairAndArtfairEventGetByIdAndIds]		
	@ArtWorkId INT = 0,
	@ArtFairId INT = 0,
	@ArtFairEventId INT = 0
AS 
BEGIN
	SET TRANSACTION ISOLATION LEVEL SNAPSHOT
	
	SET NOCOUNT ON;	
	
	SELECT 
			aea.Id AS Id,
			aea.IsAssigned AS IsAssigned,		
			aea.GalleryId AS GalleryId,		
			aea.ArtworkId AS ArtWorkId,
			ae.ArtfairId AS ArtFairId,
			aea.ArtfairEventId AS ArtFairEventId,			
			aea.GalleryName AS GalleryName, 
			aea.GalleryNameFa AS GalleryNameFa, 
			aea.BoothNumber AS BoothNumber,
			aea.IsShowProvenance AS IsShowProvenance,
			aea.Provenance AS Provenance,
			aea.ProvenanceFa AS ProvenanceFa,
			aea.IsDisplayInWebsite AS IsDisplayInWebsite	
	FROM 
		ArtFairEventArtwork AS aea
		INNER JOIN ArtFairEvent ae ON aea.ArtfairEventId = ae.Id 
	WHERE 
		aea.ArtworkId = @ArtWorkId 
		AND ae.ArtfairId = @ArtFairId
		AND aea.ArtfairEventId = @ArtFairEventId

END


