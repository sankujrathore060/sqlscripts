CREATE PROCEDURE [dbo].[Artwork_MuseumAndMuseumEventAssignUnAssign]    			
    @ArtWorkId INT,
    @IsAssigned BIT,
	@ModifiedDate DATETIME,    
    -- Museum
	@MuseumId INT,
	@IsShowProvenance BIT = NULL,
	@IsMuseumCollection BIT = 0,
	@Provenance NVARCHAR(MAX) = NULL,
	@ProvenanceFa NVARCHAR(MAX) = NULL,
	@IsDisplayInWebsite BIT = 0,
	-- Museum EVENT	
	@MuseumEventId INT,
	@Price int,
	@Currency char(3),
	@IsSold bit
AS
BEGIN
	SET TRANSACTION ISOLATION LEVEL SNAPSHOT
	SET NOCOUNT ON;

	----------- Museum ASSING ------------------------------------------------------------------

	DECLARE @MuseumAssignArtworks_Id INT;

	-- SELECT Museum ASSIGN ARTWORKS RECORD
	SELECT TOP 1 
		@MuseumAssignArtworks_Id = Id 
	FROM 
		MuseumAssignArtworks WITH(NOLOCK) 
	WHERE 
		MuseumId = @MuseumId AND ArtWorkId = @ArtWorkId;
	
	-- IF RECORDS AND UN-ASSIGN THEN WE NEED TO DELETE THAT RECORD
	IF (@MuseumAssignArtworks_Id > 0 AND @IsAssigned = 0)
    BEGIN
			DELETE FROM MuseumAssignArtworks WHERE Id = @MuseumAssignArtworks_Id;
    END
	-- UPDATE RECORD WITH DETAIL
    ELSE IF (@MuseumAssignArtworks_Id > 0)
    BEGIN
			UPDATE
				MuseumAssignArtworks
			SET
				IsAssigned = @IsAssigned,
				IsShowProvenance = @IsShowProvenance,
				Provenance = @Provenance,
				ProvenanceFa = @ProvenanceFa,
				IsDisplayInWebsite = @IsDisplayInWebsite,
				ModifiedDate = @ModifiedDate,
				IsMuseumCollection = @IsMuseumCollection
			WHERE
				Id = @MuseumAssignArtworks_Id;
    END
	-- INSERT NEW RECORD
    ELSE
    BEGIN
			INSERT INTO MuseumAssignArtworks(MuseumId, ArtWorkId, IsAssigned, ModifiedDate, 
								rowguid, IsShowProvenance, Provenance, ProvenanceFa, IsDisplayInWebsite,
								IsMuseumCollection)
				SELECT @MuseumId, @ArtWorkId, @IsAssigned, @ModifiedDate, 
								NEWID(), @IsShowProvenance, @Provenance, @ProvenanceFa, @IsDisplayInWebsite,
								@IsMuseumCollection;
    END;

	----------- Museum EVENT ASSING ------------------------------------------------------------------

	DECLARE @MuseumEventArtwork_Id INT;

	-- SELECT Museum EVENT ARTWORK RECORD
	SELECT TOP 1 
		@MuseumEventArtwork_Id = Id 
	FROM 
		MuseumEventArtworks WITH(NOLOCK) 
	WHERE 
		MuseumEventId = @MuseumEventId AND ArtworkId = @ArtWorkId;

	-- IF RECORDS AND UN-ASSIGN THEN WE NEED TO DELETE THAT RECORD
	IF (@MuseumEventArtwork_Id> 0 AND @IsAssigned = 0)
    BEGIN
			DELETE FROM [dbo].[MuseumEventArtworks] WHERE Id = @MuseumEventArtwork_Id;
    END
	-- UPDATE RECORD WITH DETAIL
    ELSE IF (@MuseumEventArtwork_Id > 0)
    BEGIN
			UPDATE 
				[dbo].[MuseumEventArtworks]
			SET 
				[Price] = @Price
				,[Currency] = @Currency
				,[IsSold] = @IsSold
				,[IsAssigned] = @IsAssigned,
				[ModifiedDate] = @ModifiedDate				
			WHERE 
				Id = @MuseumEventArtwork_Id;
    END
	-- INSERT NEW RECORD
    ELSE
    BEGIN
			INSERT INTO [dbo].[MuseumEventArtworks]([MuseumEventId], [ArtworkId], [Price], [Currency], [IsSold], [IsAssigned],
								[ModifiedDate],[rowguid])
						VALUES(@MuseumEventId, @ArtworkId, @Price, @Currency, @IsSold, @IsAssigned,
								@ModifiedDate, NEWID());
    END;

	---------------------------------------------------------------------------------------------------
END;