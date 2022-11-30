ALTER PROCEDURE [dbo].[Artwork_MuseumAndMuseumEventByArtWorkId] 
	@ArtWorkId INT
AS
BEGIN
	SET TRANSACTION ISOLATION LEVEL SNAPSHOT
	SET NOCOUNT ON;

	CREATE TABLE #temp
	(
		IsAssigned BIT,
		-- GALLERY
		MuseumId INT,
		IsShowProvenance BIT,
		IsMuseumCollection BIT,
		Provenance NVARCHAR(MAX),
		ProvenanceFa NVARCHAR(MAX),
		IsDisplayInWebsite BIT,
		-- GALLERY EVENT	
		MuseumEventId INT,
		Price int,
		Currency char(3),
		IsSold bit
	)

	-- GET MUSEUM, EVENT DATA	
	INSERT INTO #temp(MuseumEventId, MuseumId, Price, Currency, IsSold)
	SELECT 
		mea.MuseumEventId, 
		me.MuseumId, 
		mea.Price, 
		mea.Currency, 
		mea.IsSold
	FROM 
		dbo.MuseumEventArtworks mea WITH(NOLOCK) 
		INNER JOIN dbo.MuseumEvents me WITH(NOLOCK) ON mea.MuseumEventId = me.Id 
	WHERE 
		mea.ArtworkId = @ArtWorkId		
		AND mea.IsAssigned = 1;
	
	-- SET MUSEUM RECORDs
	IF EXISTS(SELECT * FROM #temp)
	BEGIN
			-- UPDATE MUSEUM RECORD
			UPDATE #temp
			SET 
				MuseumId = mea.MuseumId,
				IsShowProvenance = mea.IsShowProvenance,
				Provenance = mea.Provenance,
				ProvenanceFa = mea.ProvenanceFa,
				IsDisplayInWebsite = mea.IsDisplayInWebsite,
				IsMuseumCollection = mea.IsMuseumCollection
			FROM
				MuseumAssignArtworks mea WITH(NOLOCK)
			WHERE
				mea.ArtworkId = @ArtWorkId	
				AND mea.MuseumId = #temp.MuseumId
				AND mea.IsAssigned = 1;
				
			-- INSERT MUSEUM DATA WHOSE NOT IN ABOVE RECORDs
			INSERT INTO #temp(MuseumId, IsShowProvenance, Provenance, ProvenanceFa, IsDisplayInWebsite, IsMuseumCollection)
			SELECT
				mea.MuseumId,
				mea.IsShowProvenance,
				mea.Provenance,
				mea.ProvenanceFa,
				mea.IsDisplayInWebsite,
				mea.IsMuseumCollection
			FROM
				MuseumAssignArtworks mea WITH(NOLOCK)
			WHERE
				mea.ArtworkId = @ArtWorkId
				AND mea.IsAssigned = 1
				AND mea.MuseumId NOT IN (SELECT MuseumId FROM #temp);
	END
	-- IF NOT EXISTS MUSEUM EVENT RECORDS
	ELSE
	BEGIN
			-- GET MUSEUM DATA	
			INSERT INTO #temp(MuseumId, IsShowProvenance, Provenance, ProvenanceFa, IsDisplayInWebsite, IsMuseumCollection)
			SELECT
				mea.MuseumId,
				mea.IsShowProvenance,
				mea.Provenance,
				mea.ProvenanceFa,
				mea.IsDisplayInWebsite,
				mea.IsMuseumCollection
			FROM
				MuseumAssignArtworks mea WITH(NOLOCK)
			WHERE
				mea.ArtworkId = @ArtWorkId
				AND mea.IsAssigned = 1
	END;

	SELECT * FROM #temp ORDER BY MuseumId;

	DROP TABLE #temp;
END;