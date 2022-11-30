CREATE PROCEDURE [dbo].[ArtistLongBio_InsertUpdate]
    @Id INT = 0,  
    @ArtistId INT = 0,
	@Body NVARCHAR(MAX) = '',
	@BodyFa NVARCHAR(MAX) = '',
	@Quote NVARCHAR(MAX) = '',
	@QuoteFa NVARCHAR(MAX) = '',
	@VerificationStatus INT = NULL,
	@CheckingType INT = NULL,
	@CoverImage NVARCHAR(MAX) = '',
	@CoverImageWidth INT = 0,
	@CoverImageHeight INT = 0,
	@CreatedDate DATETIME,
	@ModifiedDate DATETIME,
	@CommaSeparatedTagIds NVARCHAR(MAX) = '',
	@StatementType INT = 1,
	@returnId INT = 0
AS
BEGIN
    IF @StatementType = 1
    BEGIN
			INSERT INTO ArtistLongBio(ArtistId, Body, BodyFa, Quote,
									   QuoteFa, VerificationStatus, CheckingType,
									   CoverImage, CoverImageWidth, CoverImageHeight, CreatedDate, ModifiedDate)
			VALUES(@ArtistId, @Body, @BodyFa, @Quote,
									   @QuoteFa, @VerificationStatus, @CheckingType,
									   @CoverImage, @CoverImageWidth, @CoverImageHeight, @CreatedDate, @ModifiedDate)

			SET @returnId = SCOPE_IDENTITY();
			
			IF ISNULL(@CommaSeparatedTagIds,'') <> ''
			BEGIN
				INSERT INTO ArtistLongBioMagazineTags(ArtistLongBioId, MagazineTagId, CreatedDate, ArtistId)
				SELECT
					@returnId,
					fn.Value,
					@CreatedDate,
					@ArtistId
				FROM
					dbo.Split(@CommaSeparatedTagIds, ',') AS fn;
			END		

			RETURN @returnId;
    END;

    IF @StatementType = 2
    BEGIN
        UPDATE
            ArtistLongBio
        SET
            ArtistId = @ArtistId, Body = @Body, BodyFa = @BodyFa, Quote = @Quote,
			QuoteFa = @QuoteFa, VerificationStatus = @VerificationStatus, CheckingType = @CheckingType,
			CoverImage = @CoverImage, CoverImageWidth = @CoverImageWidth,
			CoverImageHeight = @CoverImageHeight, CreatedDate = @CreatedDate, 
			ModifiedDate = @ModifiedDate
        WHERE
            ArtistLongBioId = @Id;


		DELETE
            mst
        FROM
            ArtistLongBioMagazineTags mst
            LEFT JOIN (SELECT CAST(fn.Value AS INT) AS id FROM dbo.Split(ISNULL(@CommaSeparatedTagIds, ''), ',') AS fn WHERE fn.Value > 0) AS t ON t.id = mst.MagazineTagId
        WHERE
            t.id IS NULL
            AND mst.ArtistLongBioId = @Id;
						
        INSERT INTO ArtistLongBioMagazineTags(ArtistLongBioId, MagazineTagId, CreatedDate, ArtistId)
        SELECT
            @Id,
			t.id,
			@CreatedDate,
			@ArtistId
        FROM
			ArtistLongBioMagazineTags mst
            RIGHT JOIN (SELECT CAST(fn.Value AS INT) AS id FROM dbo.Split(ISNULL(@CommaSeparatedTagIds, ''), ',') AS fn WHERE fn.Value > 0) AS t ON t.id = mst.MagazineTagId
                                                                     AND mst.ArtistLongBioId = @id
        WHERE
            mst.MagazineTagId IS NULL;
				
    END;
END;
