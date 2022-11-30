ALTER PROCEDURE [dbo].[InsertOrUpdateGalleryEvent]
    @Id INT = 0,
    @GalleryId INT = NULL,
    @ArtistId INT = NULL,
    @Title NVARCHAR(MAX) = NULL,
    @TitleFa NVARCHAR(MAX) = NULL,
    @Curator NVARCHAR(60) = NULL,
    @CuratorFa NVARCHAR(60) = NULL,
    @Description NVARCHAR(MAX) = NULL,
    @DescriptionFa NVARCHAR(MAX) = NULL,
    @PosterImageUri NVARCHAR(256) = NULL,
	@Mobile_PosterImageUri NVARCHAR(256) = NULL,
    @FromDate DATE = NULL,
    @ToDate DATE = NULL,
    @FromDateFa NVARCHAR(10) = NULL,
    @ToDateFa NVARCHAR(10) = NULL,
    @IsSolo BIT = NULL,
    @MainArtistId INT = NULL,
    @OtherArtist NVARCHAR(MAX) = NULL,
    @ImageHeight INT = NULL,
    @ImageWidth INT = NULL,
	@Mobile_PosterImageHeight INT = NULL,
	@Mobile_PosterImageWidth INT = NULL,
    @Comments NVARCHAR(MAX) = NULL,
    @IsFeatured BIT = NULL,
    @IsArtTour BIT = NULL,
    @HomePage BIT = NULL,
    @ColumnOrder INT = NULL,
    @Statement NVARCHAR(MAX) = NULL,
    @StatementFa NVARCHAR(MAX) = NULL,
    @ModifiedDate DATETIME,
    @rowguid UNIQUEIDENTIFIER,
    @StatementType TINYINT = 0,
    @returnId INT = 0,
    @UserId UNIQUEIDENTIFIER = NULL,
	@IsOtherExhibition BIT = NULL,
	@OtherExhibitionText NVARCHAR(MAX) = NULL,
	@OtherExhibitionTextFa NVARCHAR(MAX) = NULL, 
	@CountryId INT = NULL,
	@CityId INT = NULL,
	@Latitude decimal(12,9) = NULL,
	@Longitude decimal(12,9) = NULL,
	@BookId INT = NULL,
	@IsPremiumShow BIT = NULL,
	@PremiumShowWallNumberLimit INT = NULL,
	@Collaboration nvarchar(max) = null,    
	@CollaborationFa nvarchar(max) = null,    
	@CollaborationIds nvarchar(max) = null,    
	@GallerySpaceId int = null,
	@GallerySpaceAddress nvarchar(max) = null,
	@Body NVARCHAR(MAX) = NULL,
	@BodyFa NVARCHAR(MAX) = NULL,
	@IsBodyDisplayInWebsite BIT = 0
AS
BEGIN

    DECLARE @NextFridayDate DATETIME;
    SET DATEFIRST 6;
    SELECT
        @NextFridayDate = DATEADD(d, 7 - DATEPART(dw, GETDATE()), GETDATE());
    IF (CAST(@FromDate AS DATE) = CAST(@NextFridayDate AS DATE))
    BEGIN
        SET @IsArtTour = 1;
    END;

    IF (@MainArtistId = 0)
    BEGIN
        SET @MainArtistId = NULL;
    END;
		IF @CollaborationIds is not null    
	SET @Collaboration =		
	STUFF((select     
	',' + (CASE WHEN g.[Name] is null THEN ''  ELSE  LTRIM(RTRIM(g.[Name]))  END )      
	from dbo.split(@CollaborationIds,',') as ga    
	inner join Gallery as g on g.Id = ga.Value    
	FOR XML PATH('')), 1, 1, '' )    
    
	SET @CollaborationFa =     
	STUFF((select     
	',' +(CASE WHEN g.[NameFa] is null THEN ''  ELSE  LTRIM(RTRIM(g.[NameFa]))  END )      
	from dbo.split(@CollaborationIds,',') as ga    
	inner join Gallery as g on g.Id = ga.Value    
	FOR XML PATH('')), 1, 1, '' )    

    IF @StatementType = 1
    BEGIN
        INSERT INTO [dbo].[GalleryEvent] ([GalleryId], [Title], [TitleFa], [Curator], [CuratorFa], [Description],
                                          [DescriptionFa], [PosterImageUri], [FromDate], [ToDate], [FromDateFa],
                                          [ToDateFa], [IsSolo], [MainArtistId], [ImageHeight], [ImageWidth],
                                          [Comments], [IsFeatured], [IsArtTour], [HomePage], [ColumnOrder],
                                          [Statement], [StatementFa], [ModifiedDate], [rowguid], IsOtherExhibition, 
										  OtherExhibitionText, OtherExhibitionTextFa, CountryId, CityId, Latitude, Longitude,
										  BookId, Mobile_PosterImageUri, Mobile_PosterImageHeight, Mobile_PosterImageWidth,
										  IsPremiumShow,Collaboration,CollaborationFa,CollaborationIds,GallerySpaceId,GallerySpaceAddress,
										  PremiumShowWallNumberLimit, Body, BodyFa, IsBodyDisplayInWebsite)
        VALUES
        (@GalleryId, @Title, @TitleFa, @Curator, @CuratorFa, @Description, @DescriptionFa, @PosterImageUri, @FromDate,
         @ToDate, --,@FromDateFa
         --,@ToDateFa
         CASE
             WHEN CHARINDEX('-1', @FromDateFa) > 0 THEN
                 NULL
             ELSE
                 @FromDateFa
         END, CASE
    WHEN CHARINDEX('-1', @ToDateFa) > 0 THEN
                      NULL
                ELSE
                      @ToDateFa
              END, @IsSolo, @MainArtistId, @ImageHeight, @ImageWidth, @Comments, @IsFeatured, @IsArtTour, @HomePage,
         @ColumnOrder, @Statement, @StatementFa, @ModifiedDate, @rowguid, @IsOtherExhibition, @OtherExhibitionText, @OtherExhibitionTextFa, @CountryId, @CityId, @Latitude, @Longitude,
		 @BookId, @Mobile_PosterImageUri, @Mobile_PosterImageHeight, @Mobile_PosterImageWidth,
		 @IsPremiumShow,@Collaboration,@CollaborationFa,@CollaborationIds,@GallerySpaceId,@GallerySpaceAddress, @PremiumShowWallNumberLimit, @Body, @BodyFa, @IsBodyDisplayInWebsite);

        SET @returnId = SCOPE_IDENTITY();

        INSERT INTO BackOfficeActivityLog (UserId, TitleId, Title, PageName, StatementType, ModifiedDate, rowguid)
        VALUES
        (@UserId, @returnId, @Title, 'Gallery event', @StatementType, GETDATE(), @rowguid);


        IF @OtherArtist IS NOT NULL
        BEGIN
            INSERT INTO GalleryEventArtist
            SELECT
                @returnId,
                fn.Value,
				@ModifiedDate,
                @rowguid
            FROM
                dbo.Split(@OtherArtist, ',') AS fn;

        END;
    END;

    IF @StatementType = 2
    BEGIN
        UPDATE
            [dbo].[GalleryEvent]
        SET
            [GalleryId] = @GalleryId,
			[Title] = @Title,
            [TitleFa] = @TitleFa,
            [Curator] = @Curator,
            [CuratorFa] = @CuratorFa,
            [Description] = @Description,
            [DescriptionFa] = @DescriptionFa,
            [PosterImageUri] = @PosterImageUri,
			Mobile_PosterImageUri = @Mobile_PosterImageUri,
			Mobile_PosterImageHeight = @Mobile_PosterImageHeight,
			Mobile_PosterImageWidth = @Mobile_PosterImageWidth,
            [FromDate] = @FromDate,
            [ToDate] = @ToDate,
            [FromDateFa] = (CASE WHEN CHARINDEX('-1', @FromDateFa) > 0 THEN NULL ELSE @FromDateFa END),
            [ToDateFa] = (CASE WHEN CHARINDEX('-1', @ToDateFa) > 0 THEN NULL ELSE @ToDateFa END),
            [IsSolo] = @IsSolo,
            [MainArtistId] = @MainArtistId,
            [ImageHeight] = @ImageHeight,
            [ImageWidth] = @ImageWidth,
            [Comments] = @Comments,
            [IsFeatured] = @IsFeatured,
            [IsArtTour] = @IsArtTour,
            [HomePage] = @HomePage,
            [ColumnOrder] = @ColumnOrder,
            [Statement] = @Statement,
            [StatementFa] = @StatementFa,
            [ModifiedDate] = @ModifiedDate,
            [rowguid] = @rowguid,
			IsOtherExhibition = @IsOtherExhibition, 
			OtherExhibitionText = @OtherExhibitionText, 
			OtherExhibitionTextFa = @OtherExhibitionTextFa,
			CountryId = @CountryId, 
			CityId = @CityId, 
			Latitude = @Latitude, 
			Longitude = @Longitude,
			BookId = @BookId,
			IsPremiumShow = @IsPremiumShow,
			PremiumShowWallNumberLimit = @PremiumShowWallNumberLimit,
			Collaboration = @Collaboration,
			CollaborationFa = @CollaborationFa,
			CollaborationIds = @CollaborationIds,
			GallerySpaceId = @GallerySpaceId,
			GallerySpaceAddress = @GallerySpaceAddress,
			Body = @Body,
			BodyFa = @BodyFa,
			IsBodyDisplayInWebsite = @IsBodyDisplayInWebsite
        WHERE
            Id = @Id;

        DELETE
            gea
        FROM
            GalleryEventArtist gea
            LEFT JOIN (SELECT CAST(fn.Value AS INT) AS id FROM dbo.Split(ISNULL(@OtherArtist, ''), ',') AS fn WHERE fn.Value > 0) AS t ON t.id = gea.ArtistId
        WHERE
            t.id IS NULL
            AND gea.GalleryEvent = @Id;
						
        INSERT INTO GalleryEventArtist
        SELECT
            @Id,
            t.id,
            @ModifiedDate,
            @rowguid
        FROM
            GalleryEventArtist gea
            RIGHT JOIN (SELECT CAST(fn.Value AS INT) AS id FROM dbo.Split(ISNULL(@OtherArtist, ''), ',') AS fn WHERE fn.Value > 0) AS t ON t.id = gea.ArtistId
                                                                     AND gea.GalleryEvent = @Id
        WHERE
            gea.ArtistId IS NULL;

    END;
    RETURN @returnId;
END;
