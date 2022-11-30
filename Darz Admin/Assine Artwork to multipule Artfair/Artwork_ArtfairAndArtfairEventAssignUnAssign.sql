ALTER PROCEDURE [dbo].[Artwork_ArtfairAndArtfairEventAssignUnAssign]    			
    @GalleryId INT,
    @IsAssigned BIT = 0,
	@ModifiedDate DATETIME,    
	@ArtFairEventId INT,
	@BoothNumber NVARCHAR(MAX),
    -- Artfair Gallery
	-- Artfair Event Artwork
	@GalleryName NVARCHAR(MAX) = NULL,
	@GalleryNameFa NVARCHAR(MAX) = NULL,
	@Provenance NVARCHAR(MAX) = NULL,
	@ProvenanceFa NVARCHAR(MAX) = NULL,
	@IsShowProvenance BIT = 0,
	@ArtWorkId INT,
	@IsDisplayInWebsite BIT = 0
AS
BEGIN
	SET TRANSACTION ISOLATION LEVEL SNAPSHOT
	SET NOCOUNT ON;

	DECLARE @ArtfairEventArtwork_Id INT = 0;

	SELECT TOP 1 
		@ArtfairEventArtwork_Id = Id 
	FROM
			ArtfairEventArtwork WITH(NOLOCK)
	WHERE
		ArtFairEventId = @ArtFairEventId AND ArtworkId = @ArtWorkId
				
	IF (@ArtfairEventArtwork_Id > 0 AND @IsAssigned = 0) 
	BEGIN
		DELETE FROM ArtfairEventArtwork WHERE Id = @ArtfairEventArtwork_Id
	END
	IF (@GalleryName IS NOT NULL AND @GalleryId = 0)
	BEGIN
		IF(@ArtfairEventArtwork_Id>0 AND @IsAssigned = 1)
		BEGIN
			UPDATE	ArtfairEventArtwork
			SET
				GalleryName = @GalleryName,
				GalleryNameFa = @GalleryNameFa,
				GalleryId = @GalleryId,
				IsAssigned = @IsAssigned,
				IsDisplayInWebsite = @IsDisplayInWebsite,
				IsShowProvenance = @IsShowProvenance,
				Provenance = @Provenance,
				ProvenanceFa = @ProvenanceFa,
				ModifiedDate = @ModifiedDate,
				BoothNumber = BoothNumber
			WHERE
				Id = @ArtfairEventArtwork_Id
		END	
		ELSE IF(@IsAssigned = 1)
		BEGIN
			INSERT INTO ArtfairEventArtwork(ArtfairEventId, ArtworkId,
										GalleryName, GalleryNameFa, GalleryId, Provenance, ProvenanceFa,
										IsShowProvenance, BoothNumber, ModifiedDate, rowguid, IsAssigned,
										IsDisplayInWebsite)
							VALUES (@ArtfairEventId, @ArtWorkId,
										@GalleryName, @GalleryNameFa, @GalleryId, @Provenance, @ProvenanceFa,
										@IsShowProvenance, @BoothNumber, @ModifiedDate, NEWID(), @IsAssigned, @IsDisplayInWebsite)	
		END						
	END

	--------------------------------------------------------------------
	IF @GalleryId > 0
	BEGIN		
		----------------------------------------------------
		IF(@ArtfairEventArtwork_Id>0 AND @IsAssigned = 1)
		BEGIN
			UPDATE	ArtfairEventArtwork
			SET
				GalleryName = '',
				GalleryNameFa = '',
				GalleryId = @GalleryId,
				IsAssigned = @IsAssigned,
				IsDisplayInWebsite = @IsDisplayInWebsite,
				IsShowProvenance = @IsShowProvenance,
				Provenance = @Provenance,
				ProvenanceFa = @ProvenanceFa,
				ModifiedDate = @ModifiedDate,
				BoothNumber = BoothNumber
			WHERE
				Id = @ArtfairEventArtwork_Id
		END					
			
		ELSE IF(@IsAssigned = 1)
		BEGIN
			INSERT INTO ArtfairEventArtwork(ArtfairEventId, ArtworkId,
										GalleryName, GalleryNameFa, GalleryId, Provenance, ProvenanceFa,
										IsShowProvenance, BoothNumber, ModifiedDate, rowguid, IsAssigned,
										IsDisplayInWebsite)
							VALUES (@ArtfairEventId, @ArtWorkId,
										@GalleryName, @GalleryNameFa, @GalleryId, @Provenance, @ProvenanceFa,
										@IsShowProvenance, @BoothNumber, @ModifiedDate, NEWID(), @IsAssigned, @IsDisplayInWebsite)	
		END	

		DECLARE @ArtFairGalleryId INT = 0;
			
		-- CHECK ALREADY EXIST ARTFAIR GALLERY
		SELECT 
			@ArtFairGalleryId = Id
		FROM
			ArtFairGallery WITH(NOLOCK)
		WHERE 
			ArtFairEventId = @ArtFairEventId AND GalleryId = @GalleryId

		-- IF EXIT AND NOT ASSIGNED THEN DELETE IT.
		IF (@ArtFairGalleryId > 0 AND @IsAssigned = 0)
		BEGIN
			DELETE FROM ArtfairGalleryArtWork WHERE ArtFairGalleryId = @ArtFairGalleryId;
			DELETE FROM ArtFairGallery WHERE Id = @ArtFairGalleryId;
		END

		-- IF EXIT AND ASSIGNED THEN UPDATE IT.
		ELSE IF(@ArtFairGalleryId > 0)
		BEGIN
			UPDATE ArtFairGallery
			SET
				Booth = @BoothNumber,
				ModifiedDate = @ModifiedDate
			WHERE
				Id = @ArtFairGalleryId;
		END
		ELSE 
		-- OTHERWISE INSERT INTO ARTFAIRGALLERY TABLE.
		BEGIN
			INSERT INTO ArtFairGallery (ArtFairEventId, GalleryId, Booth, ModifiedDate, rowguid)
				VALUES (@ArtFairEventId, @GalleryId, @BoothNumber, @ModifiedDate, NEWID())
			SET @ArtFairGalleryId = @@IDENTITY;
		END		
			
		DECLARE @ArtistId INT = 0, @ArtfairGalleryArtWorkId INT = 0;
			
		-- GET THE ARTIST FOR ARTWORK
		SELECT 
			@ArtistId = ArtistId 
		FROM 
			ArtWork WITH(NOLOCK) 
		WHERE 
			Id = @ArtWorkId
			
		-- IF ARTIST EXIST
		IF(@ArtistId > 0 )
		BEGIN 
			-- SELECT ID IF RECORD EXIST
			SELECT 
				@ArtfairGalleryArtWorkId = Id  
			FROM 
				ArtfairGalleryArtWork WITH(NOLOCK)
			WHERE 
				ArtworkId = @ArtWorkId 
				AND ArtistId = @ArtistId 
				AND ArtFairGalleryId = @ArtFairGalleryId
				
			IF (@ArtfairGalleryArtWorkId > 0 AND @IsAssigned = 0)
			BEGIN
				-- IF RECORD EXIST AND NOT ASSIGN
				DELETE FROM ArtfairGalleryArtWork WHERE Id = @ArtfairGalleryArtWorkId;
			END
			ELSE IF (@ArtfairGalleryArtWorkId > 0) 
			BEGIN 
				-- IF RECORD EXIST AND ASSIGN THEN UPDATE ARTFAIR GALLERY ARTWORK 
				UPDATE ArtfairGalleryArtWork
					SET
						IsShowProvenance = @IsShowProvenance,
						Provenance = @Provenance,
						ProvenanceFa = @ProvenanceFa
					WHERE 
						ArtworkId = @ArtWorkId 
						AND ArtistId = @ArtistId 
						AND ArtFairGalleryId = @ArtFairGalleryId
			END	
			ELSE IF (@IsAssigned = 1)
			BEGIN
				-- INSERT ARTFAIR GALLERY ARTWORK
				INSERT INTO ArtfairGalleryArtWork (ArtistId, ArtFairGalleryId, ArtworkId,
											IsShowProvenance, Provenance, ProvenanceFa)
							VALUES (@ArtistId, @ArtFairGalleryId, @ArtWorkId,
											@IsShowProvenance, @Provenance, @ProvenanceFa)
			END	
		END

	END
END;