ALTER VIEW [dbo].[vw_MuseumShows]
AS
SELECT
    me.Id,
    me.Title,
    me.TitleFa,
    me.FromDate AS EventFromDate,
	FORMAT(me.FromDate, 'MM') + '-' + FORMAT(me.FromDate, 'yyyy') AS EventFromDate_MMYYYY,	
    me.ToDate AS EventToDate,
	CASE WHEN ISNULL(me.FromDateFa, '') = '' THEN ''
	ELSE 
		(
			(SELECT RIGHT('0' + RTRIM([value]), 2)  FROM dbo.Split(me.FromDateFa, '/') ORDER BY Id OFFSET 1 ROWS FETCH NEXT 1 ROWS ONLY)
			+ '-' + 
			(SELECT TOP 1 [value] FROM dbo.Split(me.FromDateFa, '/'))
		)
	END AS EventFromDate_MMYYYY_Fa,
    me.FromDateFa AS EventFromDateFa,
    me.ToDateFa AS EventToDateFa,
    me.FromDate,
    me.ToDate,
    me.PosterImageUri,
    me.IsSolo,
    me.PosterImageHeight,
    me.PosterImageWidth,
	me.Mobile_PosterImageUri,
	me.Mobile_PosterImageHeight,
	me.Mobile_PosterImageWidth,
    me.IsFeatured,
    me.IsArtTour,
	me.IsOtherExhibition,
	me.OtherExhibitionText,
	me.OtherExhibitionTextFa,
	me.VerificationStatus AS MuseumEventVerificationStatus,
	m.VerificationStatus AS MuseumVerificationStatus,
	(CASE 
	WHEN me.IsSolo = 0 THEN	 
	STUFF((select '|'+ cast(ArtistId AS NVARCHAR)  from MuseumEventArtists where MuseumEventId = me.Id  FOR XML PATH('')), 1, 1, '')
	END) AS ArtistIds,
    a.Id AS ArtistId,
    a.VerificationStatus,
    LTRIM(RTRIM(a.Nickname)) AS NickName,
    LTRIM(RTRIM(a.NicknameFa)) AS NickNameFa,
    (CASE
         WHEN me.IsSolo = 0 THEN
             'Group Exhibition'
         WHEN (FirstName IS NULL AND LastName IS NULL AND Nickname IS NOT NULL) THEN
             LTRIM(RTRIM(Nickname))
         ELSE
             LTRIM(RTRIM(FirstName)) + ' ' + LTRIM(RTRIM(LastName))
     END
    ) AS ArtistName,
    (CASE
         WHEN me.IsSolo = 0 THEN
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
    [dbo].[fn_EventStatus](me.FromDate, me.ToDate) AS EventStatus,

    --  (CASE WHEN cast (GETDATE() as DATE) BETWEEN GE.FromDate and GE.ToDate                   
    --  THEN 2                    
    --when cast (ge.ToDate as date) = cast (GETDATE() as DATE)                   
    --then 2                   
    -- when ge.FromDate > cast (GETDATE() as DATE)                
    --then 1                          
    -- ELSE 3 END) as EventStatusId,                       
    m.WorkingHour,
    m.OpenTime,
    m.CloseTime,
	m.Id as GalleryId,
    m.Name AS GalleryName,
    m.NameFa AS GalleryNameFa,
	0 as GalleryEventRate,
    m.[Address],
    m.AddressFa,
    --m.Latitude,
    --m.Longitude,
	CASE WHEN ISNULL(me.Latitude, 0) = 0 THEN m.Latitude ELSE me.Latitude END AS Latitude,
	CASE WHEN ISNULL(me.Longitude, 0) = 0 THEN m.Longitude ELSE me.Longitude END AS Longitude,
	0 AS Rate,
	3 AS SortRate,
    -- c.CountryId,
    CASE WHEN ISNULL(me.CountryId, 0) = 0 THEN c.CountryId ELSE me.CountryId END CountryId,
	--c.Id AS CityId,
	--c.Name AS CityName,
	--c.Namefa AS CityNameFa
	CASE WHEN ISNULL(me.CityId, 0) = 0 THEN c.Id ELSE me.CityId END CityId,
	CASE WHEN ISNULL(me.CityId, 0) = 0 THEN c.Name ELSE meCity.Name END CityName,
	CASE WHEN ISNULL(me.CityId, 0) = 0 THEN c.Namefa ELSE meCity.Namefa END CityNameFa,
	CASE WHEN me.FromDate IS NOT NULL THEN
		ABS(DATEDIFF(d, CAST(me.FromDate AS DATE), GETDATE()))
	ELSE
		0
	END AS DaysDiffFromToday
FROM
    MuseumEvents AS me WITH(NOLOCK)
    INNER JOIN Museum AS m WITH(NOLOCK) ON m.Id = me.MuseumId
    LEFT JOIN MuseumEventArtists mea WITH(NOLOCK) ON mea.MuseumEventId = me.Id
                                        AND me.IsSolo = 1
    LEFT JOIN Artist AS a WITH(NOLOCK) ON mea.ArtistId = a.Id
    LEFT JOIN City AS c WITH(NOLOCK) ON c.Id = m.CityId
	LEFT JOIN City AS meCity WITH(NOLOCK) ON meCity.Id = me.CityId;