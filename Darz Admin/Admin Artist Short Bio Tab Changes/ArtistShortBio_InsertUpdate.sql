CREATE PROCEDURE [dbo].[ArtistShortBio_InsertUpdate]
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
			INSERT INTO ArtistShortBio(ArtistId, Body, BodyFa, Quote,
									   QuoteFa, VerificationStatus, CheckingType,
									   CoverImage, CoverImageWidth, CoverImageHeight, CreatedDate, ModifiedDate)
			VALUES(@ArtistId, @Body, @BodyFa, @Quote,
									   @QuoteFa, @VerificationStatus, @CheckingType,
									   @CoverImage, @CoverImageWidth, @CoverImageHeight, @CreatedDate, @ModifiedDate)

			SET @returnId = SCOPE_IDENTITY();
			
			IF ISNULL(@CommaSeparatedTagIds,'') <> ''
			BEGIN
				INSERT INTO ArtistShortBioMagazineTags(ArtistShortBioId, MagazineTagId, CreatedDate, ArtistId)
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
            ArtistShortBio
        SET
            ArtistId = @ArtistId, Body = @Body, BodyFa = @BodyFa, Quote = @Quote,
			QuoteFa = @QuoteFa, VerificationStatus = @VerificationStatus, CheckingType = @CheckingType,
			CoverImage = @CoverImage, CoverImageWidth = @CoverImageWidth,
			CoverImageHeight = @CoverImageHeight, CreatedDate = @CreatedDate, 
			ModifiedDate = @ModifiedDate
        WHERE
            ArtistShortBioId = @Id;


		DELETE
            mst
        FROM
            ArtistShortBioMagazineTags mst
            LEFT JOIN (SELECT CAST(fn.Value AS INT) AS id FROM dbo.Split(ISNULL(@CommaSeparatedTagIds, ''), ',') AS fn WHERE fn.Value > 0) AS t ON t.id = mst.MagazineTagId
        WHERE
            t.id IS NULL
            AND mst.ArtistShortBioId = @Id;
						
        INSERT INTO ArtistShortBioMagazineTags(ArtistShortBioId, MagazineTagId, CreatedDate, ArtistId)
        SELECT
            @Id,
			t.id,
			@CreatedDate,
			@ArtistId
        FROM
            ArtistShortBioMagazineTags mst
            RIGHT JOIN (SELECT CAST(fn.Value AS INT) AS id FROM dbo.Split(ISNULL(@CommaSeparatedTagIds, ''), ',') AS fn WHERE fn.Value > 0) AS t ON t.id = mst.MagazineTagId
                                                                     AND mst.ArtistShortBioId = @id
        WHERE
            mst.MagazineTagId IS NULL;
				
    END;
END;
