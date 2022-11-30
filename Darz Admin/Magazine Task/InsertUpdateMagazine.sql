ALTER PROCEDURE [dbo].[InsertUpdateMagazine]
    @id INT = 0,    
    @Name NVARCHAR(50),
    @NameFa NVARCHAR(50) = NULL,    
    @ModifiedDate DATETIME,
    @rowguid UNIQUEIDENTIFIER,
    @StatementType TINYINT = 0,
    @returnId INT = 0,
	@Author NVARCHAR(50) = NULL,
	@Authorfa NVARCHAR(50) = NULL,
	@VerificationStatus SMALLINT = 0,
	@CheckingType INT = 0,
	@MagazineDate DATETIME = '',
	@Body NVARCHAR(MAX) = '',
	@BodyFa NVARCHAR(MAX) = '',
	@MagazineCoverImageUri NVARCHAR(256) = '',
	@ReadingTime NVARCHAR(50) = '',
	@ReadingTimeFa NVARCHAR(50) = '',
	@ImageHeight INT = 0,
	@ImageWidth INT = 0,
	@Category INT = 0,
	@SubCategory INT =0,
	@CommaSeparatedTagIds NVARCHAR(MAX) = '',
	@MagazineDateFa NVARCHAR(50) = ''
AS
BEGIN
    IF @StatementType = 1
    BEGIN
			INSERT INTO Magazines(Name, Namefa, ModifiedDate, rowguid,
								 Author, Authorfa, VerificationStatus,
								 CheckingType, MagazineDate, Body, BodyFa,
								 MagazineCoverImageUri, ReadingTime, ReadingTimeFa,
								 ImageHeight, ImageWidth, Category, SubCategory, MagazineDateFa)
			VALUES(@Name, @NameFa, @ModifiedDate, @rowguid,
								@Author, @Authorfa, @VerificationStatus, @CheckingType, @MagazineDate,
								@Body, @BodyFa,
								@MagazineCoverImageUri, @ReadingTime, @ReadingTimeFa,
								@ImageHeight, @ImageWidth, @Category, @SubCategory, @MagazineDateFa);

			SET @returnId = SCOPE_IDENTITY();
			
			IF ISNULL(@CommaSeparatedTagIds,'') <> ''
			BEGIN
				INSERT INTO MagazineSelectedTags(MagazineId, MagazineTagId, CreatedDate)
				SELECT
					@returnId,
					fn.Value,
					GETDATE()
				FROM
					dbo.Split(@CommaSeparatedTagIds, ',') AS fn;
			END		

			RETURN @returnId;
    END;

    IF @StatementType = 2
    BEGIN
        UPDATE
            dbo.Magazines
        SET
            Name = @Name,
            Namefa = @NameFa,
            ModifiedDate = @ModifiedDate,
            rowguid = @rowguid,
		    Author = @Author,
			Authorfa = @Authorfa,
			VerificationStatus = @VerificationStatus,
			CheckingType = @CheckingType,
			MagazineDate = @MagazineDate, 
			Body = @Body, 
			BodyFa = @BodyFa,
	        MagazineCoverImageUri = @MagazineCoverImageUri,
			ReadingTime = @ReadingTime,
			ReadingTimeFa = @ReadingTimeFa,
			ImageHeight = @ImageHeight,
			ImageWidth = @ImageWidth,			
			Category = @Category,
			SubCategory = @SubCategory,
			MagazineDateFa = @MagazineDateFa
        WHERE
            Id = @id;


		DELETE
            mst
        FROM
            MagazineSelectedTags mst
            LEFT JOIN (SELECT CAST(fn.Value AS INT) AS id FROM dbo.Split(ISNULL(@CommaSeparatedTagIds, ''), ',') AS fn WHERE fn.Value > 0) AS t ON t.id = mst.MagazineTagId
        WHERE
            t.id IS NULL
            AND mst.MagazineId = @id;
						
        INSERT INTO MagazineSelectedTags
        SELECT
            @id,
			t.id,
			GETDATE()
        FROM
            MagazineSelectedTags mst
            RIGHT JOIN (SELECT CAST(fn.Value AS INT) AS id FROM dbo.Split(ISNULL(@CommaSeparatedTagIds, ''), ',') AS fn WHERE fn.Value > 0) AS t ON t.id = mst.MagazineTagId
                                                                     AND mst.MagazineId = @Id
        WHERE
            mst.MagazineTagId IS NULL;
				
    END;
END;