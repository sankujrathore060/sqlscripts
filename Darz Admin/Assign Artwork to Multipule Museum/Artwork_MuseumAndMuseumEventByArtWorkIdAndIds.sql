ALTER PROCEDURE [dbo].[Artwork_MuseumAndMuseumEventByArtWorkIdAndIds]	
	@ArtWorkId INT,
	@MuseumEventId INT,
	@MuseumId INT
AS
BEGIN
	SET TRANSACTION ISOLATION LEVEL SNAPSHOT
	SET NOCOUNT ON;

	DECLARE @IsAssigned BIT,
			@Id INT,
			-- Museum
			-- @MuseumId INT,
			@IsShowProvenance BIT = NULL,
			@Provenance NVARCHAR(MAX) = NULL,
			@ProvenanceFa NVARCHAR(MAX) = NULL,
			@IsMuseumCollection BIT = 0,
			@IsDisplayInWebsite BIT = 0,
			-- MUSEUM EVENT	
			-- @MuseumEventId INT,
			@Price int,
			@Currency char(3),
			@IsSold bit

	-- GET MUSEUM EVENT DATA	
	SELECT TOP 1
		@MuseumEventId = mea.MuseumEventId, 
		@MuseumId = me.MuseumId, 
		@Price = mea.Price, 
		@Currency = mea.Currency, 
		@IsSold = mea.IsSold
	FROM 
		dbo.MuseumEventArtworks mea WITH(NOLOCK) 
		INNER JOIN dbo.MuseumEvents me WITH(NOLOCK) ON mea.MuseumEventId = me.MuseumId 
	WHERE 
		mea.ArtworkId = @ArtWorkId
		AND mea.MuseumEventId = @MuseumEventId
		AND mea.IsAssigned = 1;
	
	-- GET MUSEUM DATA
	SELECT TOP 1
		@Id = mea.Id,
		@MuseumId = mea.MuseumId,
		@IsShowProvenance = mea.IsShowProvenance,
		@Provenance = mea.Provenance,
		@ProvenanceFa = mea.ProvenanceFa,
		@IsDisplayInWebsite = mea.IsDisplayInWebsite,
		@IsMuseumCollection = mea.IsMuseumCollection
	FROM 
		dbo.MuseumAssignArtworks mea  WITH(NOLOCK)
	WHERE 
		mea.ArtworkId = @ArtWorkId
		AND mea.MuseumId = @MuseumId
		AND mea.IsAssigned = 1;

	SELECT CASE WHEN @MuseumEventId > 0 OR @MuseumId > 0 THEN 1 ELSE 0 END AS IsAssigned,			 
			-- Museum
			
			@Id as Id,
			@MuseumId as MuseumId,
			@IsShowProvenance as IsShowProvenance,
			@Provenance as Provenance,
			@ProvenanceFa as ProvenanceFa,
			@IsDisplayInWebsite as IsDisplayInWebsite,
			@IsMuseumCollection as IsMuseumCollection,
			-- Museum EVENT	
			@MuseumEventId as MuseumEventId,
			@Price as Price,
			@Currency as Currency,
			@IsSold as IsSold
END