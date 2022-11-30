ALTER PROCEDURE [dbo].[proc_GetAllAuctionEventArtworkDataById] 
	@auctionEventId INT = 0,
	@UserId uniqueidentifier = null
AS
BEGIN
    SET TRANSACTION ISOLATION LEVEL SNAPSHOT;
    /* Get Auction details by auctionId*/
    SELECT
        --AW.ID,        
        AE.Id AS AuctionEventId,
        AE.ActualDate AS AuctionDate,
        AE.ActualDateFa AS AuctionDateFa,
        AE.PreviewDate,
        AE.PreviewDateFa,
        AE.EventHour,
        AE.PreviewHour,
        AE.Title AS EventTitle,
        AE.TitleFa AS EventTitleFa,
        AE.PosterImageUri,
        AE.[Description] AS EventDescription,
        AE.[DescriptionFa] AS EventDescriptionFa,
        AE.ImageHeight AS PosterImageHeight,
        AE.ImageWidth AS PosterImageWidth,
        AE.NumbersOfIranArtWork,
        AE.PercentageOfArtWork,
        AE.MostExpArtWork,
        AE.OverAllSale,
        AE.PercSoldByValue,
        AE.PercSoldByLots,
		AE.IsDisplayEventDescription,
        AE.[Location] AS [Address],
        AH.IsOnline,
        AH.AddressFa,
        AH.OpenTime,
        AE.StartTime,
        AE.FinishTime,
		AE.[Url],
        --AEA.HighEstimate,        
        --AEA.LowEstimate,          
        --AEA.Currency,        
        AH.[Description],
        AH.[DescriptionFa],
        AH.Logo,
        AH.LogoImageHeight,
        AH.LogoImageWidth,
        --ah.[Address],        
        AH.Latitude,
        AH.Longitude,
        AH.[Name] AS AuctionHouseTitle,
        AH.[NameFa] AS AuctionHouseTitleFa,
        AH.Phone,
        AH.Website,
        C.[Name] AS CityName,
        C.[Namefa] AS CityNameFa,
        C.CityCode,
        co.Name AS CountryName,
        co.Namefa AS CountryNameFa,
        co.CountryCode
    FROM
        AuctionEvent AS AE WITH(NOLOCK)
        INNER JOIN AuctionHouse AS AH WITH(NOLOCK) ON AE.AuctionHouse = AH.Id
        LEFT JOIN City AS C WITH(NOLOCK) ON C.Id = AH.CityId
        LEFT JOIN Country AS co WITH(NOLOCK) ON co.Id = C.CountryId
    --left join AuctionEventArtwork AEA on AEA.AuctionEventId = AE.Id        
    --left join ArtWork AW on AEA.ArtWorkId = Aw.Id        
    WHERE
        AE.Id = @auctionEventId;

    /* Get Auction Artwork data by artistId*/
    SELECT
        ar.Id,
        ae.Id AS AuctionEventId,
        ar.Title AS ArtworkTitle,
        ar.TitleFa AS ArtworkTitleFa,
        ar.Medium,
        ar.MediumFa,
        ar.ArtistId,
        CASE
            WHEN (ar.CreationYear <> 0 AND ar.CreationYear <> -1) THEN
                ar.CreationYear
            ELSE
                NULL
        END AS CreationYear,
        CASE
            WHEN (ar.CreationYearFa <> 0 AND ar.CreationYearFa <> -1 AND ar.CreationYearFa <> -622) THEN
                ar.CreationYearFa
            ELSE
                NULL
        END AS CreationYearFa,
        --ar.Height,        
        --ar.Width,        
        aer.LowEstimate,
        aer.HighEstimate,
        aer.HammerPrice,
        aer.PremiumPrice,
        aer.Currency,
        aer.IsSold,
        aer.NoFinalPrice,
        aer.LotNumber,
		aer.StartingBid,
		ar.Height, 
		ar.Width, 
		ar.Depth,
		ar.Length,
		ar.SizeUnit,
        --dbo.fn_ArtworkSize(ar.Height, ar.Width, ar.Depth) AS Size,
        ar.Picture AS ArtworkImage,
        ar.ImageHeight,
        ar.ImageWidth,
        ae.ActualDate AS AuctionDate,
        ah.OpenTime,
        LTRIM(RTRIM(a.FirstName)) AS FirstName,
        LTRIM(RTRIM(a.LastName)) AS LastName,
        LTRIM(RTRIM(a.FirstNameFa)) AS FirstNameFa,
        LTRIM(RTRIM(a.LastNameFa)) AS LastNameFa,
        LTRIM(RTRIM(a.Nickname)) AS NickName,
        LTRIM(RTRIM(a.NicknameFa)) AS NickNameFa,
        (CASE
             WHEN (FirstName IS NULL AND LastName IS NULL AND Nickname IS NOT NULL) THEN
                 LTRIM(RTRIM(Nickname))
             ELSE
                 LTRIM(RTRIM(FirstName)) + ' ' + LTRIM(RTRIM(LastName))
         END
  ) AS ArtistName,
        (CASE
           WHEN (FirstNameFa IS NULL AND FirstNameFa IS NULL AND NicknameFa IS NOT NULL) THEN
      LTRIM(RTRIM(NicknameFa))
         ELSE
                 LTRIM(RTRIM(FirstNameFa)) + ' ' + LTRIM(RTRIM(LastNameFa))
         END
        ) AS ArtistNameFa,
		a.VerificationStatus AS Artist_VerificationStatus,		
		f.Id AS FavouriteId
    FROM
        vw_Artwork AS ar WITH(NOLOCK)
        INNER JOIN AuctionEventArtwork AS aer WITH(NOLOCK) ON aer.ArtworkId = ar.Id
        INNER JOIN AuctionEvent ae WITH(NOLOCK) ON ae.Id = aer.AuctionEventId
        INNER JOIN AuctionHouse ah WITH(NOLOCK) ON ah.Id = ae.AuctionHouse
        INNER JOIN Artist AS a WITH(NOLOCK) ON a.Id = ar.ArtistId
		LEFT JOIN Favourites f WITH(NOLOCK) ON aer.ArtworkId = f.MainId AND f.UserId = @UserId AND f.PageId = 2	-- 2 IS FOR ARTWORKs
    WHERE
        ar.VerificationStatus = 2
        AND ae.Id = @auctionEventId

    /* Get Previous Auction details from today */
    ;
    WITH cte
    AS (SELECT Id AS eventId, AuctionHouse, ActualDate FROM AuctionEvent WHERE Id = @auctionEventId)
    SELECT TOP 1
		ah.[Name] AS AuctionHouseTitle,
		ah.OpenTime,
		ae.Id,		
		ae.AuctionHouse,
		ae.ActualDate AS AuctionDate,
		ae.ActualDateFa AS AuctionDateFa,
		ae.PreviewDate,
		ae.PreviewDateFa,		
		ae.Title AS EventTitle,		       
		ae.OverAllSale,		
		ar.Title AS ArtWorkTitle,
		ar.TitleFa AS ArtWorkTitleFa,
		ar.CreationYear,
		ar.CreationYearFa,
		ar.Medium,
		ar.MediumFa,
		ar.Picture AS ArtworkImage,
		ar.Height, 
		ar.Width, 
		ar.Depth,
		ar.Length,
		ar.SizeUnit,
		aer.IsHighlight,
		aer.NoFinalPrice,
		aer.IsSold,
		aer.HighEstimate,
		aer.LowEstimate,
		--aer.Currency, 		
		aer.HammerPrice,
		aer.PremiumPrice,
		aer.LotNumber,		
		aer.Currency,
		-- dbo.fn_ArtworkSize(ar.Height, ar.Width, ar.Depth) AS Size,
        LTRIM(RTRIM(a.FirstName)) AS FirstName,
        LTRIM(RTRIM(a.LastName)) AS LastName,
        LTRIM(RTRIM(a.FirstNameFa)) AS FirstNameFa,
        LTRIM(RTRIM(a.LastNameFa)) AS LastNameFa,
        LTRIM(RTRIM(a.Nickname)) AS NickName,
        LTRIM(RTRIM(a.NicknameFa)) AS NickNameFa,
        (CASE
             WHEN (a.FirstName IS NULL AND a.LastName IS NULL AND a.Nickname IS NOT NULL) THEN
                 LTRIM(RTRIM(a.Nickname))
             ELSE
                 LTRIM(RTRIM(a.FirstName)) + ' ' + LTRIM(RTRIM(a.LastName))
         END
        ) AS ArtistName,
        (CASE
            WHEN (a.FirstNameFa IS NULL AND a.FirstNameFa IS NULL AND a.NicknameFa IS NOT NULL) THEN
				LTRIM(RTRIM(a.NicknameFa))
			ELSE
                LTRIM(RTRIM(a.FirstNameFa)) + ' ' + LTRIM(RTRIM(a.LastNameFa))
         END
        ) AS ArtistNameFa
    FROM
        AuctionEvent AS ae WITH(NOLOCK)
        INNER JOIN AuctionEventArtwork aer WITH(NOLOCK) ON ae.Id = aer.AuctionEventId
        INNER JOIN vw_Artwork ar WITH(NOLOCK) ON ar.Id = aer.ArtworkId
        INNER JOIN AuctionHouse ah WITH(NOLOCK) ON ah.Id = ae.AuctionHouse
        INNER JOIN cte AS c WITH(NOLOCK) ON c.AuctionHouse = ae.AuctionHouse
                                AND ae.ActualDate < c.ActualDate
		INNER JOIN Artist AS a WITH(NOLOCK) ON a.Id = ar.ArtistId
    WHERE
		--aer.IsHighlight = 1  and 
		ae.VerificationStatus = 2
		AND ah.VerificationStatus = 2
		AND ar.VerificationStatus = 2
		AND c.eventId <> ae.Id
		AND (
				ISNULL(aer.IsSold, 0) = 1 
				OR (ISNULL(aer.IsSold, 0) = 1 AND aer.PremiumPrice > 0 AND aer.PremiumPrice > aer.HighEstimate)
				OR (ISNULL(aer.IsSold, 0) = 1 AND aer.HammerPrice > 0 AND aer.HammerPrice > aer.HighEstimate)				
			)
    ORDER BY
           ae.ActualDate DESC, 
		   aer.PremiumPrice DESC, aer.HammerPrice DESC;
END
