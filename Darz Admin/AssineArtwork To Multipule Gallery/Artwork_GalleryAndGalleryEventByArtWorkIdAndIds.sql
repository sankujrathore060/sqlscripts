ALTER PROCEDURE [dbo].[Artwork_GalleryAndGalleryEventByArtWorkIdAndIds]	
	@ArtWorkId INT,
	@GalleryEventId INT,
	@GalleryId INT
AS
BEGIN
	SET TRANSACTION ISOLATION LEVEL SNAPSHOT
	SET NOCOUNT ON;

	DECLARE @IsAssigned BIT,
			@Id INT,
			-- GALLERY
			-- @GalleryId INT,
			@IsShowProvenance BIT = NULL,
			@Provenance NVARCHAR(MAX) = NULL,
			@ProvenanceFa NVARCHAR(MAX) = NULL,
			@IsDisplayInWebsite BIT = 0,
			-- GALLERY EVENT	
			-- @GalleryEventId INT,
			@Price int,
			@Currency char(3),
			@IsSold bit,
			@WallNumber int = NULL

	-- GET GALLERY EVENT DATA	
	SELECT TOP 1
		@GalleryEventId = gea.GalleryEventId, 
		@GalleryId = ge.GalleryId, 
		@Price = gea.Price, 
		@Currency = gea.Currency, 
		@IsSold = gea.IsSold, 
		@WallNumber = gea.WallNumber
	FROM 
		dbo.GalleryEventArtwork gea WITH(NOLOCK) 
		INNER JOIN dbo.GalleryEvent ge WITH(NOLOCK) ON gea.GalleryEventId = ge.GalleryId 
	WHERE 
		gea.ArtworkId = @ArtWorkId
		AND gea.GalleryEventId = @GalleryEventId
		AND gea.IsAssigned = 1;
	
	-- GET GALLERY DATA
	SELECT TOP 1
		@Id = gea.Id,
		@GalleryId = gea.GalleryId,
		@IsShowProvenance = gea.IsShowProvenance,
		@Provenance = gea.Provenance,
		@ProvenanceFa = gea.ProvenanceFa,
		@IsDisplayInWebsite = gea.IsDisplayInWebsite
	FROM 
		dbo.GalleryAssignArtworks gea WITH(NOLOCK)
	WHERE 
		gea.ArtworkId = @ArtWorkId
		AND gea.GalleryId = @GalleryId
		AND gea.IsAssigned = 1;

	SELECT CASE WHEN @GalleryEventId > 0 OR @GalleryId > 0 THEN 1 ELSE 0 END AS IsAssigned,			 
			@Id as Id,
			-- GALLERY
			@GalleryId as GalleryId,
			@IsShowProvenance as IsShowProvenance,
			@Provenance as Provenance,
			@ProvenanceFa as ProvenanceFa,
			@IsDisplayInWebsite as IsDisplayInWebsite,
			-- GALLERY EVENT	
			@GalleryEventId as GalleryEventId,
			@Price as Price,
			@Currency as Currency,
			@IsSold as IsSold,
			@WallNumber as WallNumber
END