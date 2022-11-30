ALTER PROCEDURE [dbo].[Artwork_AssignUnAssignGallery]
    @Id INT = 0,
    @GalleryId INT,
    @ArtWorkId INT,
    @IsAssigned BIT,
    @ModifiedDate DATETIME,
    @rowguid UNIQUEIDENTIFIER,
	@IsShowProvenance BIT = NULL,
	@Provenance NVARCHAR(MAX) = NULL,
	@ProvenanceFa NVARCHAR(MAX) = NULL,
	@IsDisplayInWebsite BIT = 0
AS
BEGIN

	SET TRANSACTION ISOLATION LEVEL SNAPSHOT
	SET NOCOUNT ON;

    IF (@Id > 0)
    BEGIN
			UPDATE
				GalleryAssignArtworks
			SET
				IsAssigned = @IsAssigned,
				GalleryId = @GalleryId,
				ArtWorkId = @ArtWorkId,
				ModifiedDate = @ModifiedDate,
				IsShowProvenance = @IsShowProvenance,
				Provenance = @Provenance,
				ProvenanceFa = @ProvenanceFa,
				IsDisplayInWebsite = @IsDisplayInWebsite
			WHERE
				Id = @Id;
    END;
    ELSE
    BEGIN
			INSERT INTO GalleryAssignArtworks (GalleryId, ArtWorkId, IsAssigned, ModifiedDate, rowguid, IsShowProvenance, Provenance, ProvenanceFa, IsDisplayInWebsite)
				SELECT @GalleryId, @ArtWorkId, @IsAssigned, @ModifiedDate, @rowguid, @IsShowProvenance, @Provenance, @ProvenanceFa, @IsDisplayInWebsite;
    END;
END;
