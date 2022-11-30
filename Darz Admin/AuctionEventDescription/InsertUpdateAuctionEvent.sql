ALTER PROCEDURE [dbo].[InsertUpdateAuctionEvent]
    @id INT = 0,
    @AuctionHouse INT = 0,
    @Title NVARCHAR(250) = NULL,
    @TitleFa NVARCHAR(250) = NULL,
    @SaleNumber INT = 0,
    @Description NVARCHAR(900) = NULL,
    @DescriptionFa NVARCHAR(900) = NULL,
    @LocationSameAsParent BIT,
    @Location NVARCHAR(200) = NULL,
    @PosterImageUri NVARCHAR(256) = NULL,
    @ActualDate DATETIME = NULL,
    @PreviewDate DATETIME = NULL,
    @ActualDateFa NVARCHAR(250) = NULL,
    @PreviewDateFa NVARCHAR(250) = NULL,
    @EventHour NVARCHAR(50) = NULL,
    @PreviewHour NVARCHAR(50) = NULL,
    @StartTime TIME(7) = NULL,
    @FinishTime TIME(7) = NULL,
    @HighEstimate BIGINT = 0,
    @LowEstimate BIGINT = 0,
    @NumbersOfIranArtWork NVARCHAR(500) = NULL,
    @PercentageOfArtWork NVARCHAR(500) = NULL,
    @MostExpArtWork NVARCHAR(500) = NULL,
    @OverAllSale NVARCHAR(500) = NULL,
    @PercSoldByValue INT = 0,
    @PercSoldByLots INT = 0,
    @Latitude DECIMAL(12, 9),
    @Longitude DECIMAL(12, 9),
    @ImageHeight INT = NULL,
    @ImageWidth INT = NULL,
    @Comments NVARCHAR(MAX) = NULL,
    @HomePage BIT = NULL,
    @ColumnOrder INT = NULL,
    @ModifiedDate DATETIME = NULL,
    @rowguid UNIQUEIDENTIFIER,
    @StatementType TINYINT = 0,
    @returnId INT = 0,
    @UserId UNIQUEIDENTIFIER = NULL,
    @Url NVARCHAR(MAX) = NULL,
	@IsDisplayEventDescription BIT = 0
AS
BEGIN
    SET NOCOUNT ON;

    IF @StatementType = 1
    --BEGIN    
    --IF exists (Select * from AuctionEvent where Title = @Title or TitleFa = @TitleFa)    
    --BEGIN    
    --set @returnId = 0;    
    -- return @returnId;    
    --END    
    --ELSE    
    BEGIN
        INSERT INTO [dbo].[AuctionEvent] ([AuctionHouse], [Title], [TitleFa], [SaleNumber], [Description],
        [DescriptionFa], [LocationSameAsParent], [Location], [PosterImageUri], [ActualDate], [PreviewDate],
        [ActualDateFa], [PreviewDateFa], [HighEstimate], [LowEstimate], [NumbersOfIranArtWork], [PercentageOfArtWork],
        [MostExpArtWork], [OverAllSale], [PercSoldByValue], [PercSoldByLots], [Latitude], [Longitude], [ImageHeight],
        [ImageWidth], [Comments], [EventHour], [PreviewHour], [HomePage], [ColumnOrder], [StartTime], [FinishTime],
        [ModifiedDate], [rowguid], [Url], [IsDisplayEventDescription])
        VALUES (
            @AuctionHouse, @Title, @TitleFa, @SaleNumber, @Description, @DescriptionFa, @LocationSameAsParent,
            @Location, @PosterImageUri, @ActualDate, @PreviewDate, --,@ActualDateFa    
            --      ,@PreviewDateFa    
            CASE
                WHEN CHARINDEX('-1', @ActualDateFa) > 0 THEN
                    NULL
                ELSE
                    @ActualDateFa
            END, CASE
                     WHEN CHARINDEX('-1', @PreviewDateFa) > 0 THEN
                         NULL
                     ELSE
                         @PreviewDateFa
                 END, @HighEstimate, @LowEstimate, @NumbersOfIranArtWork, @PercentageOfArtWork, @MostExpArtWork,
            @OverAllSale, @PercSoldByValue, @PercSoldByLots, @Latitude, @Longitude, @ImageHeight, @ImageWidth,
            @Comments, @EventHour, @PreviewHour, @HomePage, @ColumnOrder, @StartTime, @FinishTime, @ModifiedDate,
            @rowguid, @Url, @IsDisplayEventDescription
        );

        SET @returnId = SCOPE_IDENTITY();

        INSERT INTO BackOfficeActivityLog (UserId, TitleId, Title, PageName, StatementType, ModifiedDate, rowguid)
        VALUES (@UserId, @returnId, @Title, 'AuctionHouse Event', @StatementType, GETDATE(), @rowguid);

        RETURN @returnId;
    END;

    IF @StatementType = 2
    BEGIN
        UPDATE
            [dbo].[AuctionEvent]
        SET
            [AuctionHouse] = @AuctionHouse,
            [Title] = @Title,
            [TitleFa] = @TitleFa,
            [SaleNumber] = @SaleNumber,
            [Description] = @Description,
            [DescriptionFa] = @DescriptionFa,
            [LocationSameAsParent] = @LocationSameAsParent,
            [Location] = @Location,
            [PosterImageUri] = @PosterImageUri,
            [ActualDate] = @ActualDate,
            [PreviewDate] = @PreviewDate,
            [ActualDateFa] = (CASE WHEN CHARINDEX('-1', @ActualDateFa) > 0 THEN NULL ELSE @ActualDateFa END),
            [PreviewDateFa] = (CASE WHEN CHARINDEX('-1', @PreviewDateFa) > 0 THEN NULL ELSE @PreviewDateFa END),
            [HighEstimate] = @HighEstimate,
            [LowEstimate] = @LowEstimate,
            [NumbersOfIranArtWork] = @NumbersOfIranArtWork,
            [PercentageOfArtWork] = @PercentageOfArtWork,
            [MostExpArtWork] = @MostExpArtWork,
            [OverAllSale] = @OverAllSale,
            [PercSoldByValue] = @PercSoldByValue,
            [PercSoldByLots] = @PercSoldByLots,
            [Latitude] = @Latitude,
            [Longitude] = @Longitude,
            [ImageHeight] = @ImageHeight,
            [ImageWidth] = @ImageWidth,
            [Comments] = @Comments,
            [EventHour] = @EventHour,
            [PreviewHour] = @PreviewHour,
            [HomePage] = @HomePage,
            [ColumnOrder] = @ColumnOrder,
            [StartTime] = @StartTime,
            [FinishTime] = @FinishTime,
            [ModifiedDate] = @ModifiedDate,
            [rowguid] = @rowguid,
            [Url] = @Url,
			[IsDisplayEventDescription] = @IsDisplayEventDescription
        WHERE
            Id = @id;
    END;
END;
