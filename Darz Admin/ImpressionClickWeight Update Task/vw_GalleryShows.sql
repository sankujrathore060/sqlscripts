ALTER VIEW [dbo].[vw_GalleryShows]
AS
SELECT
    ge.Id,
    ge.Title,
    ge.TitleFa,
    ge.FromDate AS EventFromDate,
	FORMAT(ge.FromDate, 'MM') + '-' + FORMAT(ge.FromDate, 'yyyy') AS EventFromDate_MMYYYY,	
    ge.ToDate AS EventToDate,
	CASE WHEN ISNULL(ge.FromDateFa, '') = '' THEN ''
	ELSE 
		(
			(SELECT RIGHT('0' + RTRIM([value]), 2)  FROM dbo.Split(ge.FromDateFa, '/') ORDER BY Id OFFSET 1 ROWS FETCH NEXT 1 ROWS ONLY)
			+ '-' + 
			(SELECT TOP 1 [value] FROM dbo.Split(ge.FromDateFa, '/'))
		)
	END AS EventFromDate_MMYYYY_Fa,
    ge.FromDateFa AS EventFromDateFa,
    ge.ToDateFa AS EventToDateFa,
    ge.FromDate,
    ge.ToDate,
    ge.PosterImageUri,
    ge.IsSolo,
    ge.ImageHeight AS PosterImageHeight,
    ge.ImageWidth AS PosterImageWidth,
	ge.Mobile_PosterImageUri,
	ge.Mobile_PosterImageHeight,
	ge.Mobile_PosterImageWidth,
    ge.IsFeatured,
    ge.IsArtTour,
	ge.IsOtherExhibition,
	ge.OtherExhibitionText,
	ge.OtherExhibitionTextFa,
	ge.VerificationStatus AS GalleryEventVerificationStatus,
	g.VerificationStatus AS GalleryVerificationStatus,
	(CASE 
	WHEN ge.IsSolo = 0 THEN	 
	STUFF((select '|'+ cast(ArtistId AS NVARCHAR)  from GalleryEventArtist where GalleryEvent = ge.Id  FOR XML PATH('')), 1, 1, '')
	END) AS ArtistIds,
    a.Id AS ArtistId,
    a.VerificationStatus,
    LTRIM(RTRIM(a.Nickname)) AS NickName,
    LTRIM(RTRIM(a.NicknameFa)) AS NickNameFa,
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
    LTRIM(RTRIM(a.FirstName)) AS FirstName,
    LTRIM(RTRIM(a.LastName)) AS LastName,
    a.FirstNameFa,
    a.LastNameFa,
    [dbo].[fn_EventStatus](ge.FromDate, ge.ToDate) AS EventStatus,
    g.WorkingHour,
    g.OpenTime,
    g.CloseTime,
	g.Id as GalleryId,
    g.Name AS GalleryName,
    g.NameFa AS GalleryNameFa,
	ISNULL(ger.GalleryRate, 0) as GalleryEventRate,
    g.[Address],
    g.AddressFa,
    --g.Latitude,
    --g.Longitude,
	CASE WHEN ISNULL(ge.Latitude, 0) = 0 THEN g.Latitude ELSE ge.Latitude END AS Latitude,
	CASE WHEN ISNULL(ge.Longitude, 0) = 0 THEN g.Longitude ELSE ge.Longitude END AS Longitude,
	ISNULL(g.Rate, 0) AS Rate,
	CASE WHEN ISNULL(g.Rate, 0) = 9 OR ISNULL(g.Rate, 0) = 7 THEN 1
		WHEN ISNULL(g.Rate, 0) = 5 OR ISNULL(g.Rate, 0) <= 1 THEN 2
		ELSE 3 END SortRate,
	-- c.CountryId,
    CASE WHEN ISNULL(ge.CountryId, 0) = 0 THEN c.CountryId ELSE ge.CountryId END CountryId,
	--c.Id AS CityId,
	--c.Name AS CityName,
	--c.Namefa AS CityNameFa
	CASE WHEN ISNULL(ge.CityId, 0) = 0 THEN c.Id ELSE ge.CityId END CityId,
	CASE WHEN ISNULL(ge.CityId, 0) = 0 THEN c.Name ELSE geCity.Name END CityName,
	CASE WHEN ISNULL(ge.CityId, 0) = 0 THEN c.Namefa ELSE geCity.Namefa END CityNameFa,
	CASE WHEN ge.FromDate IS NOT NULL THEN
		ABS(DATEDIFF(d, CAST(ge.FromDate AS DATE), GETDATE()))
	ELSE
		0
	END AS DaysDiffFromToday
FROM
    GalleryEvent AS ge WITH(NOLOCK)
    INNER JOIN Gallery AS g WITH(NOLOCK) ON g.Id = ge.GalleryId
    LEFT JOIN GalleryEventArtist gea WITH(NOLOCK) ON gea.GalleryEvent = ge.Id
                                        AND ge.IsSolo = 1
    LEFT JOIN Artist AS a WITH(NOLOCK) ON gea.ArtistId = a.Id
    LEFT JOIN City AS c WITH(NOLOCK) ON c.Id = g.CityId
	LEFT JOIN City AS geCity WITH(NOLOCK) ON geCity.Id = ge.CityId
	LEFT JOIN GalleryEventRating AS ger WITH(NOLOCK) ON ger.GalleryEventId = ge.Id;

