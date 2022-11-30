ALTER PROCEDURE [dbo].[proc_GetAllGalleriesById] 
	@Name NVARCHAR(900) = NULL
AS
BEGIN
    SET TRANSACTION ISOLATION LEVEL SNAPSHOT;

    SET NOCOUNT ON;

    SELECT
        g.Id,
        g.[Name],
        g.NameFa,
        g.Logo,
        g.Description AS GalleryDescription,
        g.DescriptionFa AS GalleryDescriptionFa,
        g.BlackDescription1,
        g.BlackDescription1Fa,
        g.BlackDescription2,
        g.BlackDescription2Fa,
        g.Neighbourhood,
        g.NeighbourhoodFa,
        g.LogoImageHeight,
        g.LogoImageWidth,
        g.[Image],
        g.ImageHeight,
        g.ImageWidth,
        g.[Address],
        g.AddressFa,
        g.Phone,
        g.SecondPhoneNumber,
        g.Website,
        g.Latitude,
        g.Longitude,
        g.CountryId,
        g.WorkingHour,
        g.OpenTime,
        g.CloseTime,
        g.Facebook,
        g.Twitter,
        g.Instagram,
		g.IsCityCodeAdded,
		g.DayOffText,
		g.DayOffTextFa,
		g.IsDayOffTextDisplayInWebsite,
        ge.Id AS GalleryEventId,
        ge.Title,
        ge.TitleFa,
        ge.FromDate,
        ge.ToDate,
        ge.FromDateFa,
        ge.ToDateFa,
        ge.Description,
        ge.DescriptionFa,
        ge.PosterImageUri,
        ge.ImageHeight AS PosterImageHeight,
        ge.ImageWidth AS PosterImageWidth,
        ge.IsSolo,
        ge.IsOtherExhibition,
        ge.OtherExhibitionText,
        ge.OtherExhibitionTextFa,
        LTRIM(RTRIM(a.FirstName)) AS FirstName,
        LTRIM(RTRIM(a.LastName)) AS LastName,
        LTRIM(RTRIM(a.Nickname)) AS Nickname,
        c.CityCode,
        co.CountryCode,
        --LTRIM(RTRIM(a.FirstName)) +' '+ LTRIM(RTRIM(a.LastName)) as ArtistName,           
        --LTRIM(RTRIM(a.FirstNameFa)) +' '+ LTRIM(RTRIM(a.LastNameFa)) as ArtistNameFa,           
        (CASE
             WHEN ge.IsSolo = 0 THEN
                 'Group Exhibition'
             WHEN (FirstName IS NULL AND LastName IS NULL AND Nickname IS NOT NULL) THEN
                 LTRIM(RTRIM(Nickname))
             ELSE
                 LTRIM(RTRIM(FirstName)) + ' ' + LTRIM(RTRIM(LastName))
         END
        ) AS ArtistName,
        (CASE
             WHEN ge.IsSolo = 0 THEN
                 'Group Exhibition'
             WHEN (FirstNameFa IS NULL AND FirstNameFa IS NULL AND NicknameFa IS NOT NULL) THEN
                 LTRIM(RTRIM(NicknameFa))
             ELSE
                 LTRIM(RTRIM(FirstNameFa)) + ' ' + LTRIM(RTRIM(LastNameFa))
         END
        ) AS ArtistNameFa,
        [dbo].[fn_EventStatus](ge.FromDate, ge.ToDate) AS EventStatus,
        (CASE
             WHEN CAST(GETDATE() AS DATE)
                  BETWEEN ge.FromDate AND ge.ToDate THEN
                 1
             WHEN ge.ToDate > CAST(GETDATE() AS DATE) THEN
                 2
             WHEN ge.FromDate < CAST(GETDATE() AS DATE) THEN
                 3
             ELSE
                 0
         END
        ) AS CurrentEvent,
        g.OpenTimeFriday,
        g.CloseTimeFriday
    INTO
        #tempGalleryEvents
    FROM
        Gallery AS g WITH (NOLOCK)
        LEFT JOIN City c WITH (NOLOCK) ON c.Id = g.CityId
        LEFT JOIN Country co WITH (NOLOCK) ON co.Id = g.CountryId
        LEFT JOIN GalleryEvent AS ge WITH (NOLOCK) ON g.Id = ge.GalleryId
                                                      AND ge.VerificationStatus = 2 -- Added On 21Nov2019
        LEFT JOIN GalleryEventArtist AS gea WITH (NOLOCK) ON gea.GalleryEvent = ge.Id
                                                             AND ge.IsSolo = 1
        LEFT JOIN Artist AS a WITH (NOLOCK) ON a.Id = gea.ArtistId
    WHERE
        (CHARINDEX('-', @Name) > 0 AND g.Name LIKE REPLACE(@Name, '-', '_') OR g.Name = @Name);

	-- GET GALLERY DETAILs FROM GALLERY EVENT
	SELECT * FROM #tempGalleryEvents;
	
	-- CURRENT GALLERY EVENT COUNT
	SELECT COUNT(*) AS Current_GalleryEventCount FROM #tempGalleryEvents WHERE CurrentEvent = 1;
	-- UPCOMING GALLERY EVENT COUNT
	SELECT COUNT(*) AS Upcoming_GalleryEventCount FROM #tempGalleryEvents WHERE CurrentEvent = 2;
	-- PAST GALLERY EVENT COUNT
	SELECT COUNT(*) AS Past_GalleryEventCount FROM #tempGalleryEvents WHERE CurrentEvent = 3;

    SELECT
        feeds.Picture,
        feeds.FeedImageHeight,
        feeds.FeedImageWidth,
        feeds.[URL]
    FROM
        GalleryFeeds feeds WITH (NOLOCK)
        INNER JOIN Gallery g WITH (NOLOCK) ON g.Id = feeds.GalleryId
    WHERE
        (CHARINDEX('-', @Name) > 0 AND g.Name LIKE REPLACE(@Name, '-', '_') OR g.Name = @Name)
    ORDER BY
        feeds.ModifiedDate DESC;

    DROP TABLE #tempGalleryEvents;
END;