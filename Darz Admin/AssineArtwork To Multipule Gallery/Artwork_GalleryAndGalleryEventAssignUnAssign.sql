ALTER PROCEDURE [dbo].[Artwork_GalleryAndGalleryEventAssignUnAssign]    			
    @ArtWorkId INT,
    @IsAssigned BIT,
	@ModifiedDate DATETIME,    
    -- GALLERY
	@GalleryId INT,
	@IsShowProvenance BIT = NULL,
	@Provenance NVARCHAR(MAX) = NULL,
	@ProvenanceFa NVARCHAR(MAX) = NULL,
	@IsDisplayInWebsite BIT = 0,
	-- GALLERY EVENT	
	@GalleryEventId INT,
	@Price int,
	@Currency char(3),
	@IsSold bit,
	@WallNumber int = NULL	
AS
BEGIN
	SET TRANSACTION ISOLATION LEVEL SNAPSHOT
	SET NOCOUNT ON;

	----------- GALLERY ASSING ------------------------------------------------------------------

	DECLARE @GalleryAssignArtworks_Id INT;

	-- SELECT GALLERY ASSIGN ARTWORKS RECORD
	SELECT TOP 1 
		@GalleryAssignArtworks_Id = Id 
	FROM 
		GalleryAssignArtworks WITH(NOLOCK) 
	WHERE 
		GalleryId = @GalleryId AND ArtWorkId = @ArtWorkId;
	
	-- IF RECORDS AND UN-ASSIGN THEN WE NEED TO DELETE THAT RECORD
	IF (@GalleryAssignArtworks_Id > 0 AND @IsAssigned = 0)
    BEGIN
			DELETE FROM GalleryAssignArtworks WHERE Id = @GalleryAssignArtworks_Id;
    END
	-- UPDATE RECORD WITH DETAIL
    ELSE IF (@GalleryAssignArtworks_Id > 0)
    BEGIN
			UPDATE
				GalleryAssignArtworks
			SET
				IsAssigned = @IsAssigned,
				IsShowProvenance = @IsShowProvenance,
				Provenance = @Provenance,
				ProvenanceFa = @ProvenanceFa,
				IsDisplayInWebsite = @IsDisplayInWebsite,
				ModifiedDate = @ModifiedDate
			WHERE
				Id = @GalleryAssignArtworks_Id;
    END
	-- INSERT NEW RECORD
    ELSE
    BEGIN
			INSERT INTO GalleryAssignArtworks(GalleryId, ArtWorkId, IsAssigned, ModifiedDate, 
								rowguid, IsShowProvenance, Provenance, ProvenanceFa, IsDisplayInWebsite)
				SELECT @GalleryId, @ArtWorkId, @IsAssigned, @ModifiedDate, 
								NEWID(), @IsShowProvenance, @Provenance, @ProvenanceFa, @IsDisplayInWebsite;
    END;

	----------- GALLERY EVENT ASSING ------------------------------------------------------------------

	DECLARE @GalleryEventArtwork_Id INT;

	-- SELECT GALLERY EVENT ARTWORK RECORD
	SELECT TOP 1 
		@GalleryEventArtwork_Id = Id 
	FROM 
		GalleryEventArtwork WITH(NOLOCK) 
	WHERE 
		GalleryEventId = @GalleryEventId AND ArtworkId = @ArtWorkId;

	-- IF RECORDS AND UN-ASSIGN THEN WE NEED TO DELETE THAT RECORD
	IF (@GalleryEventArtwork_Id > 0 AND @IsAssigned = 0)
    BEGIN
			DELETE FROM [dbo].[GalleryEventArtwork] WHERE Id = @GalleryEventArtwork_Id;
    END
	-- UPDATE RECORD WITH DETAIL
    ELSE IF (@GalleryEventArtwork_Id > 0)
    BEGIN
			UPDATE 
				[dbo].[GalleryEventArtwork]
			SET 
				[Price] = @Price
				,[Currency] = @Currency
				,[IsSold] = @IsSold
				,[IsAssigned] = @IsAssigned,
				WallNumber = @WallNumber,
				[ModifiedDate] = @ModifiedDate				
			WHERE 
				Id = @GalleryEventArtwork_Id;
    END
	-- INSERT NEW RECORD
    ELSE
    BEGIN
			INSERT INTO [dbo].[GalleryEventArtwork]([GalleryEventId], [ArtworkId], [Price], [Currency], [IsSold], [IsAssigned],
								[ModifiedDate],[rowguid], WallNumber)
						VALUES(@GalleryEventId, @ArtworkId, @Price, @Currency, @IsSold, @IsAssigned,
								@ModifiedDate, NEWID(), @WallNumber);
    END;

	---------------------------------------------------------------------------------------------------
END;