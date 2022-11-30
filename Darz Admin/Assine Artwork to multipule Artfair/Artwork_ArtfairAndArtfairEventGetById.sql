ALTER PROCEDURE  [dbo].[Artwork_ArtfairAndArtfairEventGetById]		
	@ArtWorkId INT = 0
AS 
BEGIN
	SET TRANSACTION ISOLATION LEVEL SNAPSHOT
	
	SET NOCOUNT ON;

	CREATE TABLE #temp
	(
		IsAssigned BIT,		
		GalleryId INT,		
		ArtWorkId INT,
		ArtFairId INT,
		ArtFairEventId INT,
			
		GalleryName NVARCHAR(MAX), 
		GalleryNameFa NVARCHAR(MAX), 
		BoothNumber NVARCHAR(MAX),
		IsShowProvenance BIT,
		Provenance NVARCHAR(MAX),
		ProvenanceFa NVARCHAR(MAX),
		IsDisplayInWebsite BIT		
	)
	
	INSERT INTO #temp (
			IsAssigned,		
			GalleryId,		
			ArtWorkId,
			ArtFairId,
			ArtFairEventId,			
			GalleryName, 
			GalleryNameFa, 
			BoothNumber,
			IsShowProvenance,
			Provenance,
			ProvenanceFa,
			IsDisplayInWebsite		
		)
	SELECT 
			aea.IsAssigned,		
			aea.GalleryId,		
			aea.ArtworkId,
			ae.ArtfairId,
			aea.ArtfairEventId,			
			aea.GalleryName, 
			aea.GalleryNameFa, 
			aea.BoothNumber,
			aea.IsShowProvenance,
			aea.Provenance,
			aea.ProvenanceFa,
			aea.IsDisplayInWebsite	
	FROM 
		ArtFairEventArtwork AS aea
		INNER JOIN ArtFairEvent ae ON aea.ArtfairEventId = ae.Id 
	WHERE 
		ArtworkId = @ArtWorkId

	SELECT * FROM #temp ORDER BY ArtfairId DESC 

	DROP TABLE #temp;
END
