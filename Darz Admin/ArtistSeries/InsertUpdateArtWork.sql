ALTER PROCEDURE [dbo].[InsertUpdateArtWork]
	 @Id INT = 0,    
	 @Title NVARCHAR(max) = NULL,    
	 @TitleFa NVARCHAR(max) = NULL,    
	 @Series NVARCHAR(500) = NULL,    
	 @SeriesFa NVARCHAR(500) = NULL,    
	 @ArtistId INT,    
	 @SecondArtistId INT = NULL,    
	 @Category INT = 0,    
	 @CreationYear INT = 0,    
	 @CreationYearFa INT = 0,    
	 @Tag NVARCHAR(100) = NULL,    
	 @Medium NVARCHAR(MAX) = NULL,    
	 @MediumFa NVARCHAR(MAX) = NULL,    
	 @Description NVARCHAR(900) = NULL,    
	 @DescriptionFa NVARCHAR(900) = NULL,    
	 @Height VARCHAR(50) = NULL,    
	 @Width VARCHAR(50) = NULL,    
	 @Depth VARCHAR(50) = NULL,    
	 @Length VARCHAR(50) = NULL,
	 @SizeUnit INT = 1,	-- CM
	 @LastStatusDescription NVARCHAR(900) = NULL,    
	 @LastStatusDescriptionFa NVARCHAR(900) = NULL,    
	 @Source NVARCHAR(max) = NULL,    
	 @SourceFa NVARCHAR(max) = NULL,    
	 @Edition NVARCHAR(500) = NULL,    
	 @Picture NVARCHAR(500) = NULL,    
	 @ImageHeight int = null,    
	 @ImageWidth int = null,    
	 @IsFeatured BIT = 0,    
	 @Rank TINYINT = 0,    
	 @LifeLogId INT = NULL,    
	 @VerificationStatus TINYINT = NULL,    
	 @IsAuctionRecord BIT = NULL,    
	 @IsMobileImage BIT = NULL,    
	 @Comment NVARCHAR(900) = NULL,    
	 @Collaboration nvarchar(max) = null,    
	 @CollaborationFa nvarchar(max) = null,    
	 @CollaborationIds nvarchar(max) = null,    
	 @Censorship BIT = NULL,   
	 @ModifiedDate DATETIME,    
	 @LinkedPriceRecordId INT = NULL,
	 @IsCollaborationDisplayOnWebsite BIT = 0,
	 @rowguid UNIQUEIDENTIFIER,    
	 @StatementType TINYINT = 0,  
	 @IsDuplicate bit = NULL,
	 @ArtistSeriesId INT = 0,
	 @returnId INT = 0   
AS    
BEGIN    
	 IF (@SecondArtistId = 0)    
	 BEGIN    
		 SET @SecondArtistId = NULL    
	 END    
    
	IF @CollaborationIds is not null    
	SET @Collaboration =		
	STUFF((select     
	',' + (CASE WHEN A.FirstName is null  and A.LastName is null THEN LTRIM(RTRIM(a.Nickname))   ELSE  LTRIM(RTRIM(a.FirstName)) +' '+ LTRIM(RTRIM(a.LastName))  END )      
	from dbo.split(@CollaborationIds,',') as ga    
	inner join Artist as a on a.Id = ga.Value    
	FOR XML PATH('')), 1, 1, '' )    
    
	SET @CollaborationFa =     
	STUFF((select     
	',' +(CASE WHEN A.FirstNameFa is null  and A.LastNameFa is null THEN LTRIM(RTRIM(a.NicknameFa))   ELSE  LTRIM(RTRIM(a.FirstNameFa)) +' '+ LTRIM(RTRIM(a.LastNameFa))  END )       
	from dbo.split(@CollaborationIds,',') as ga    
	inner join Artist as a on a.Id = ga.Value    
	FOR XML PATH('')), 1, 1, '' )    
     
	IF @StatementType = 1
	BEGIN
		INSERT INTO ArtWork(Title, TitleFa, ArtistId, SecondArtistId, Category, CreationYear, CreationYearFa, Medium,
							 MediumFa, Description, DescriptionFa, Height, Width, Depth, Length, SizeUnit, LastStatusDescription,
							 LastStatusDescriptionFa, Source, SourceFa, Edition, Picture, ImageHeight, ImageWidth, Rank,
							 LifeLogId, VerificationStatus, IsFeatured, IsAuctionRecord, IsMobileImage, Comment, Series,
							 SeriesFa, Collaboration, CollaborationFa, CollaborationIds, Censorship, ModifiedDate, rowguid,
							 LinkedPriceRecordId, IsCollaborationDisplayOnWebsite, IsDuplicate)
		VALUES
		(@Title, @TitleFa, @ArtistId, @SecondArtistId, @Category, @CreationYear, @CreationYearFa, @Medium, @MediumFa,
		 @Description, @DescriptionFa, @Height, @Width, @Depth, @Length, @SizeUnit, @LastStatusDescription, @LastStatusDescriptionFa,
		 @Source, @SourceFa, @Edition, @Picture, @ImageHeight, @ImageWidth, @Rank, @LifeLogId, @VerificationStatus,
		 @IsFeatured, @IsAuctionRecord, @IsMobileImage, @Comment, @Series, @SeriesFa, @Collaboration, @CollaborationFa,
		 @CollaborationIds, @Censorship, @ModifiedDate, @rowguid, @LinkedPriceRecordId, @IsCollaborationDisplayOnWebsite,@IsDuplicate);

		SET @returnId = SCOPE_IDENTITY();

		DECLARE @ArtWorkId INT;
		SET @ArtWorkId = SCOPE_IDENTITY();

		IF @ArtistSeriesId > 0
		BEGIN
			INSERT INTO ArtworkSeries(ArtistSeriesId, ArtworkId, ArtistId, CreatedDate)
			VALUES(@ArtistSeriesId, @ArtWorkId, @ArtistId, GETDATE())
		END

		-- HIDE TAGs FOR TEMPORARY FROM ADD/EDIT ARTWORK - 18Nov2019
		--IF @Tag IS NOT NULL    
		--BEGIN    
		--    INSERT INTO ArtWorkTag    
		--    SELECT @ArtWorkId,    
		--           fn.value    
		--    FROM   dbo.Split(@Tag, ',') AS fn    
		--END    

		RETURN @returnId;
	END;


	IF @StatementType = 2
	BEGIN
		IF (@IsMobileImage = 1)
		BEGIN
			UPDATE
				ArtWork
			SET
				[IsMobileImage] = 0
			WHERE
				ArtistId = @ArtistId;
		END;

		IF NOT EXISTS (SELECT 1 FROM ArtWork aw WHERE aw.Id = @id AND aw.LifeLogId = @LifeLogId)
		BEGIN
			UPDATE
				al
			SET
				al.ArtworkPicture = NULL
			FROM
				ArtistLifeLog al
				INNER JOIN ArtWork aw ON aw.LifeLogId = al.Id
			WHERE
				aw.ArtistId = @ArtistId
				AND aw.Id = @id;
		END;

		
		IF EXISTS (SELECT 1 FROM ArtworkSeries aw WHERE aw.ArtworkId = @Id)
		BEGIN
			UPDATE ArtworkSeries
			SET ArtistSeriesId = @ArtistSeriesId,
			ArtistId= @ArtistId
			WHERE ArtworkId = @Id
		END
		ELSE
		BEGIN
			IF @ArtistSeriesId > 0
			BEGIN
				INSERT INTO ArtworkSeries(ArtistSeriesId, ArtworkId, ArtistId, CreatedDate)
				VALUES(@ArtistSeriesId, @Id, @ArtistId, GETDATE())
			END	
		END

		UPDATE
			ArtWork
		SET
			Title = @Title,
			TitleFa = @TitleFa,
			ArtistId = @ArtistId,
			SecondArtistId = @SecondArtistId,
			Category = @Category,
			CreationYear = @CreationYear,
			CreationYearFa = @CreationYearFa,
			Medium = @Medium,
			MediumFa = @MediumFa,
			Description = @Description,
			DescriptionFa = @DescriptionFa,
			Height = @Height,
			Width = @Width,
			Depth = @Depth,
			Length = @Length,
			SizeUnit = @SizeUnit,
			LifeLogId = @LifeLogId,
			VerificationStatus = @VerificationStatus,
			LastStatusDescription = @LastStatusDescription,
			LastStatusDescriptionFa = @LastStatusDescriptionFa,
			Source = @Source,
			SourceFa = @SourceFa,
			Edition = @Edition,
			Picture = @Picture,
			ImageHeight = @ImageHeight,
			ImageWidth = @ImageWidth,
			Rank = @Rank,
			IsFeatured = @IsFeatured,
			IsAuctionRecord = @IsAuctionRecord,
			IsMobileImage = @IsMobileImage,
			Comment = @Comment,
			Series = @Series,
			SeriesFa = @SeriesFa,
			Collaboration = @Collaboration,
			CollaborationFa = @CollaborationFa,
			CollaborationIds = @CollaborationIds,
			Censorship = @Censorship,
			ModifiedDate = @ModifiedDate,
			LinkedPriceRecordId = @LinkedPriceRecordId,
			IsCollaborationDisplayOnWebsite = @IsCollaborationDisplayOnWebsite,
			IsDuplicate = @IsDuplicate
		WHERE
			Id = @id;
    
		SET @returnId = @id    
       
		 
		-- START - HIDE TAGs FOR TEMPORARY FROM ADD/EDIT ARTWORK - 18Nov2019
		--DELETE art    
		--FROM   ArtWorkTag art    
		--	LEFT JOIN (    
		--				SELECT CAST(fn.value AS INT) AS id    
		--				FROM   dbo.Split(ISNULL(@Tag, ''), ',') AS fn    
		--				WHERE  fn.Value > 0    
		--			) AS t    
		--			ON  t.id = art.TagId    
		--WHERE  t.Id IS NULL    
		--	AND art.ArtworkId = @Id    
         
		--INSERT INTO ArtWorkTag    
		--SELECT @Id,    
		--	t.id    
		--FROM   ArtWorkTag art    
		--	RIGHT JOIN (    
		--				SELECT CAST(fn.value AS INT) AS id    
		--				FROM   dbo.Split(ISNULL(@Tag, ''), ',') AS fn    
		--				WHERE  fn.Value > 0    
		--			) AS t    
		--			ON  t.id = art.TagId    
		--			AND art.ArtworkId = @Id    
		--WHERE  art.TagId IS NULL   
		-- END - HIDE TAGs FOR TEMPORARY FROM ADD/EDIT ARTWORK - 18Nov2019 
	END    

    RETURN @returnId    
END 