ALTER PROCEDURE [dbo].[InsertOrUpdateGallery]
    @Id INT = 0,
    @Name NVARCHAR(50) = NULL,
    @NameFa NVARCHAR(50) = NULL,
    @Logo NVARCHAR(MAX) = NULL,
    @Image NVARCHAR(MAX) = NULL,
    @Address NVARCHAR(MAX) = NULL,
    @AddressFa NVARCHAR(MAX) = NULL,
    @Area NVARCHAR(120) = NULL,
    @Phone NVARCHAR(150) = NULL,
    @SecondPhoneNumber NVARCHAR(150) = NULL,
    @WebSite NVARCHAR(50) = NULL,
    @Email NVARCHAR(50) = NULL,
    @WorkingHour NVARCHAR(50) = NULL,
    @OpenTime TIME(7) = NULL,
    @CloseTime TIME(7) = NULL,
    @CountryId INT = 0,
    @CityId INT = 0,
    @Rank TINYINT = 0,
    @Description NVARCHAR(900) = NULL,
    @DescriptionFa NVARCHAR(900) = NULL,
    @Neighbourhood NVARCHAR(900) = NULL,
    @NeighbourhoodFa NVARCHAR(900) = NULL,
    @ResidentArtist NVARCHAR(MAX) = NULL,
    @Latitude DECIMAL(12, 9),
    @Longitude DECIMAL(12, 9),
    @ImageHeight INT = NULL,
    @ImageWidth INT = NULL,
    @LogoImageHeight INT = NULL,
    @LogoImageWidth INT = NULL,
    @EstablishedYear INT = NULL,
    @History NVARCHAR(500) = NULL,
    @Facebook NVARCHAR(MAX) = NULL,
    @Twitter NVARCHAR(MAX) = NULL,
    @Instagram NVARCHAR(MAX) = NULL,
    @BlackDescription1 NVARCHAR(MAX) = NULL,
    @BlackDescription1Fa NVARCHAR(MAX) = NULL,
    @BlackDescription2 NVARCHAR(MAX) = NULL,
    @BlackDescription2Fa NVARCHAR(MAX) = NULL,
	@EndTime DATETIME = NULL,
    @EndTimeHour TIME = NULL,
    @AdminNotes NVARCHAR(MAX) = NULL,
	@Rate INT = NULL,
    @ModifiedDate DATETIME,
    @rowguid UNIQUEIDENTIFIER,
    @StatementType TINYINT = 0,
    @returnId INT = 0,
    @UserId UNIQUEIDENTIFIER = NULL,
	@OpenTimeFriday TIME(7) = NULL,
    @CloseTimeFriday TIME(7) = NULL,
	@VerifiedEmail NVARCHAR(MAX) = NULL,
    @IsWebsiteAccess BIT = NULL,
	@IsCityCodeAdded BIT = NULL,
	@DayOffText NVARCHAR(MAX) = NULL, 
	@DayOffTextFa NVARCHAR(MAX) = NULL, 
	@IsDayOffTextDisplayInWebsite BIT = 0
AS
BEGIN
    IF @CityId = 0
        SET @CityId = NULL;

	IF @CountryId = 0
        SET @CountryId = NULL;

    IF @StatementType = 1
    BEGIN
        INSERT INTO [dbo].[Gallery] ([Name], [NameFa], [Logo], [Image], [Address], [AddressFa], [Area], [Phone],
                                     [SecondPhoneNumber], [Website], [Email], [WorkingHour], [CountryId], [CityId],
                                     [Rank], [Description], [DescriptionFa], [Neighbourhood], [NeighbourhoodFa],
                                     [Latitude], [Longitude], [ImageHeight], [ImageWidth], [LogoImageHeight],
                                     [LogoImageWidth], [EstablishedYear], [History], [OpenTime], [CloseTime],
                                     [Facebook], [Twitter], [Instagram], [BlackDescription1], [BlackDescription1Fa],
                                     [BlackDescription2], [BlackDescription2Fa], [ModifiedDate], [rowguid], EndTime, EndTimeHour, AdminNotes,
									 OpenTimeFriday, CloseTimeFriday, VerifiedEmail, IsWebsiteAccess, IsCityCodeAdded, DayOffText, DayOffTextFa, IsDayOffTextDisplayInWebsite)
							VALUES
							(@Name, @NameFa, @Logo, @Image, @Address, @AddressFa, @Area, @Phone, @SecondPhoneNumber, @WebSite, @Email,
							 @WorkingHour, @CountryId, @CityId, @Rank, @Description, @DescriptionFa, @Neighbourhood, @NeighbourhoodFa,
							 @Latitude, @Longitude, @ImageHeight, @ImageWidth, @LogoImageHeight, @LogoImageWidth, @EstablishedYear,
							 @History, @OpenTime, @CloseTime, @Facebook, @Twitter, @Instagram, @BlackDescription1, @BlackDescription1Fa,
							 @BlackDescription2, @BlackDescription2Fa, @ModifiedDate, @rowguid, @EndTime, @EndTimeHour, @AdminNotes,
							 @OpenTimeFriday, @CloseTimeFriday, @VerifiedEmail, @IsWebsiteAccess, @IsCityCodeAdded, @DayOffText, @DayOffTextFa, @IsDayOffTextDisplayInWebsite);

		SET @returnId = SCOPE_IDENTITY();

        INSERT INTO BackOfficeActivityLog (UserId, TitleId, Title, PageName, StatementType, ModifiedDate, rowguid)
        VALUES (@UserId, @returnId, @Name, 'Gallery', @StatementType, GETDATE(), @rowguid);

        IF @ResidentArtist IS NOT NULL
        BEGIN
				INSERT INTO GalleryArtist
				SELECT
					@returnId,
					fn.Value,
					@ModifiedDate,
					@rowguid
				FROM
					dbo.Split(@ResidentArtist, ',') AS fn;
        END;

    END;
    IF @StatementType = 2
    BEGIN
			UPDATE
				[dbo].[Gallery]
			SET
				[Name] = @Name,
				[NameFa] = @NameFa,
				[Logo] = @Logo,
				[Image] = @Image,
				[Address] = @Address,
				[AddressFa] = @AddressFa,
				[Area] = @Area,
				[Phone] = @Phone,
				[SecondPhoneNumber] = @SecondPhoneNumber,
				[Website] = @WebSite,
				[Email] = @Email,
				[WorkingHour] = @WorkingHour,
				[CountryId] = @CountryId,
				[CityId] = @CityId,
				[Rank] = @Rank,
				[Description] = @Description,
				[DescriptionFa] = @DescriptionFa,
				[Neighbourhood] = @Neighbourhood,
				[NeighbourhoodFa] = @NeighbourhoodFa,
				[Latitude] = @Latitude,
				[Longitude] = @Longitude,
				[ImageHeight] = @ImageHeight,
				[ImageWidth] = @ImageWidth,
				[LogoImageHeight] = @LogoImageHeight,
				[LogoImageWidth] = @LogoImageWidth,
				[EstablishedYear] = @EstablishedYear,
				[History] = @History,
				[OpenTime] = @OpenTime,
				[CloseTime] = @CloseTime,
				[Facebook] = @Facebook,
				[Instagram] = @Instagram,
				[Twitter] = @Twitter,
				-- [BlackDescription1] = @BlackDescription1,
				-- [BlackDescription1Fa] = @BlackDescription1Fa,
				-- [BlackDescription2] = @BlackDescription2,
				-- [BlackDescription2Fa] = @BlackDescription2Fa,
				-- EndTime = @EndTime, 
				-- EndTimeHour = @EndTimeHour, 
				-- AdminNotes = @AdminNotes,
				Rate = @Rate,
				[ModifiedDate] = @ModifiedDate,
				[rowguid] = @rowguid,
				OpenTimeFriday = @OpenTimeFriday,
				CloseTimeFriday = @CloseTimeFriday,
				VerifiedEmail = @VerifiedEmail, 
				IsWebsiteAccess = @IsWebsiteAccess,
				IsCityCodeAdded = @IsCityCodeAdded,
				DayOffText = @DayOffText,
				DayOffTextFa = @DayOffTextFa,
				IsDayOffTextDisplayInWebsite = @IsDayOffTextDisplayInWebsite
			WHERE
				Id = @Id;

			DELETE
				ga
			FROM
				GalleryArtist ga
				LEFT JOIN (SELECT CAST(fn.Value AS INT) AS id FROM dbo.Split(ISNULL(@ResidentArtist, ''), ',') AS fn WHERE fn.Value > 0) AS t ON t.id = ga.ArtistId
			WHERE
				t.id IS NULL
				AND ga.GalleryId = @Id;

			INSERT INTO GalleryArtist
			SELECT
				@Id,
				t.id,
				@ModifiedDate,
				@rowguid
			FROM
				GalleryArtist ga
				RIGHT JOIN (SELECT CAST(fn.Value AS INT) AS id FROM dbo.Split(ISNULL(@ResidentArtist, ''), ',') AS fn WHERE fn.Value > 0) AS t ON t.id = ga.ArtistId
																																				  AND ga.GalleryId = @Id
			WHERE
				ga.ArtistId IS NULL;
    END;

	RETURN @returnId;
END;
