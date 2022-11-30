ALTER PROCEDURE [dbo].[Artwork_GalleryAndGalleryEventByArtWorkId] 
	@ArtWorkId INT
AS
BEGIN
	SET TRANSACTION ISOLATION LEVEL SNAPSHOT
	SET NOCOUNT ON;

	CREATE TABLE #temp
	(
		IsAssigned BIT,
		-- GALLERY
		GalleryId INT,
		IsShowProvenance BIT,
		Provenance NVARCHAR(MAX),
		ProvenanceFa NVARCHAR(MAX),
		IsDisplayInWebsite BIT,
		-- GALLERY EVENT	
		GalleryEventId INT,
		Price int,
		Currency char(3),
		IsSold bit,
		WallNumber int
	)

	-- GET GALLERY EVENT DATA	
	INSERT INTO #temp(GalleryEventId, GalleryId, Price, Currency, IsSold, WallNumber)
	SELECT 
		gea.GalleryEventId, 
		ge.GalleryId, 
		gea.Price, 
		gea.Currency, 
		gea.IsSold, 
		gea.WallNumber
	FROM 
		dbo.GalleryEventArtwork gea WITH(NOLOCK) 
		INNER JOIN dbo.GalleryEvent ge WITH(NOLOCK) ON gea.GalleryEventId = ge.Id 
	WHERE 
		gea.ArtworkId = @ArtWorkId		
		AND gea.IsAssigned = 1;
	
	-- SET GALLERY RECORDs
	IF EXISTS(SELECT * FROM #temp)
	BEGIN
			-- UPDATE GALLERY RECORD
			UPDATE #temp
			SET 
				GalleryId = gea.GalleryId,
				IsShowProvenance = gea.IsShowProvenance,
				Provenance = gea.Provenance,
				ProvenanceFa = gea.ProvenanceFa,
				IsDisplayInWebsite = gea.IsDisplayInWebsite
			FROM
				GalleryAssignArtworks gea WITH(NOLOCK)
			WHERE
				gea.ArtworkId = @ArtWorkId	
				AND gea.GalleryId = #temp.GalleryId
				AND gea.IsAssigned = 1;
				
			-- INSERT GALLERY DATA WHOSE NOT IN ABOVE RECORDs
			INSERT INTO #temp(GalleryId, IsShowProvenance, Provenance, ProvenanceFa, IsDisplayInWebsite)
			SELECT
				gea.GalleryId,
				gea.IsShowProvenance,
				gea.Provenance,
				gea.ProvenanceFa,
				gea.IsDisplayInWebsite
			FROM
				GalleryAssignArtworks gea WITH(NOLOCK)
			WHERE
				gea.ArtworkId = @ArtWorkId
				AND gea.IsAssigned = 1
				AND gea.GalleryId NOT IN (SELECT GalleryId FROM #temp);
	END
	-- IF NOT EXISTS GALLERY EVENT RECORDS
	ELSE
	BEGIN
			-- GET GALLERY DATA	
			INSERT INTO #temp(GalleryId, IsShowProvenance, Provenance, ProvenanceFa, IsDisplayInWebsite)
			SELECT
				gea.GalleryId,
				gea.IsShowProvenance,
				gea.Provenance,
				gea.ProvenanceFa,
				gea.IsDisplayInWebsite
			FROM
				GalleryAssignArtworks gea WITH(NOLOCK)
			WHERE
				gea.ArtworkId = @ArtWorkId
				AND gea.IsAssigned = 1;
	END;

	SELECT * FROM #temp ORDER BY GalleryId;

	DROP TABLE #temp;
END;