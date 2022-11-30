ALTER PROCEDURE [dbo].[InsertOrUpdateMuseum]
    @Id INT = 0,
    @Name NVARCHAR(50) = NULL,
    @NameFa NVARCHAR(50) = NULL,
    @Logo NVARCHAR(MAX) = NULL,
    @Image NVARCHAR(MAX) = NULL,
    @Address NVARCHAR(MAX) = NULL,
    @AddressFa NVARCHAR(MAX) = NULL,
    @Phone NVARCHAR(150) = NULL,
    @SecondPhoneNumber NVARCHAR(150) = NULL,
    @WebSite NVARCHAR(50) = NULL,
    @Email NVARCHAR(50) = NULL,
    @WorkingHour NVARCHAR(50) = NULL,
    @OpenTime TIME(7) = NULL,
    @CloseTime TIME(7) = NULL,
    @CountryId INT = 0,
    @CityId INT = 0,
    @Description NVARCHAR(MAX) = NULL,
    @DescriptionFa NVARCHAR(MAX) = NULL,
    @VisitorInformation NVARCHAR(MAX) = NULL,
    @VisitorInformationFa NVARCHAR(MAX) = NULL,
    @Programs NVARCHAR(MAX) = NULL,
    @ProgramsFa NVARCHAR(MAX) = NULL,
    @Introduction NVARCHAR(MAX) = NULL,
    @IntroductionFa NVARCHAR(MAX) = NULL,
    @IsPermanent BIT = 0,
    @Latitude DECIMAL(12, 9),
    @Longitude DECIMAL(12, 9),
    @ImageHeight INT = NULL,
    @ImageWidth INT = NULL,
    @LogoImageHeight INT = NULL,
    @LogoImageWidth INT = NULL,
    @EstablishedYear INT = NULL,
    @History NVARCHAR(500) = NULL,
    @ModifiedDate DATETIME,
    @rowguid UNIQUEIDENTIFIER,
    @StatementType TINYINT = 0,
    @returnId INT = 0,
    @UserId UNIQUEIDENTIFIER = NULL,
	@OpenTimeFriday TIME(7) = NULL,
    @CloseTimeFriday TIME(7) = NULL,
	@DayOffText NVARCHAR(MAX) = NULL,
	@DayOffTextFa NVARCHAR(MAX) = NULL,
	@IsDayOffTextDisplayInWebsite BIT = 0
AS
BEGIN
    IF @CityId = 0
        SET @CityId = NULL;

    IF @StatementType = 1
    BEGIN
        INSERT INTO [dbo].[Museum] ([Name], [NameFa], [Logo], [Image], [Address], [AddressFa], [Phone],
                                    [SecondPhoneNumber], [Website], [Email], [WorkingHour], [CountryId], [CityId],
                                    [Description], [DescriptionFa], [VisitorInformation], [VisitorInformationFa],
                                    [Introduction], [IntroductionFa], IsPermanent, [Latitude], [Longitude],
                                    [ImageHeight], [ImageWidth], [LogoImageHeight], [LogoImageWidth],
                                    [EstablishedYear], [History], [OpenTime], [CloseTime], [Programs], [ProgramsFa],
                                    [ModifiedDate], [rowguid], OpenTimeFriday, CloseTimeFriday,DayOffText,DayOffTextFa,IsDayOffTextDisplayInWebsite)
						VALUES
						(@Name, @NameFa, @Logo, @Image, @Address, @AddressFa, @Phone, @SecondPhoneNumber, @WebSite, @Email,
						 @WorkingHour, @CountryId, @CityId, @Description, @DescriptionFa, @VisitorInformation, @VisitorInformationFa,
						 @Introduction, @IntroductionFa, @IsPermanent, @Latitude, @Longitude, @ImageHeight, @ImageWidth,
						 @LogoImageHeight, @LogoImageWidth, @EstablishedYear, @History, @OpenTime, @CloseTime, @Programs, @ProgramsFa,
						 @ModifiedDate, @rowguid, @OpenTimeFriday, @CloseTimeFriday,@DayOffText,@DayOffTextFa,@IsDayOffTextDisplayInWebsite);

        SET @returnId = SCOPE_IDENTITY();
        RETURN @returnId;
    END;

    IF @StatementType = 2
    BEGIN
        UPDATE
            [dbo].[Museum]
        SET
            [Name] = @Name,
            [NameFa] = @NameFa,
            [Logo] = @Logo,
            [Image] = @Image,
            [Address] = @Address,
            [AddressFa] = @AddressFa,
            [Phone] = @Phone,
            [SecondPhoneNumber] = @SecondPhoneNumber,
            [Website] = @WebSite,
            [Email] = @Email,
            [WorkingHour] = @WorkingHour,
            [CountryId] = @CountryId,
            [CityId] = @CityId,
            [Description] = @Description,
            [DescriptionFa] = @DescriptionFa,
            [VisitorInformation] = @VisitorInformation,
            [VisitorInformationFa] = @VisitorInformationFa,
            [IsPermanent] = @IsPermanent,
            [Introduction] = @Introduction,
            [IntroductionFa] = @IntroductionFa,
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
            [Programs] = @Programs,
            [ProgramsFa] = @ProgramsFa,
            [ModifiedDate] = @ModifiedDate,
			OpenTimeFriday = @OpenTimeFriday, 
			CloseTimeFriday = @CloseTimeFriday,
			DayOffText = @DayOffText ,
			DayOffTextFa = @DayOffTextFa,
			IsDayOffTextDisplayInWebsite = @IsDayOffTextDisplayInWebsite
        WHERE
            Id = @Id;
    END;
END;