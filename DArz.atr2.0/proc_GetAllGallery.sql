-- proc_GetAllGallery @type = 'all', 
ALTER PROCEDURE [dbo].[proc_GetAllGallery]
    @PageIndex INT = 1,
    @alphabet VARCHAR(5) = '',
    @PageSize INT = 30,
	@type NVARCHAR(50) = '',
	@galleryIds NVARCHAR(MAX) = ''
AS
BEGIN
    SET TRANSACTION ISOLATION LEVEL SNAPSHOT;
	SET NOCOUNT ON;

	SELECT 
		g.Id as GalleryId
	INTO #tempGallery
	FROM 
		Gallery g
	WHERE
		g.[Name] IS NOT NULL
		AND g.VerificationStatus = 2	-- ADDED On 21Nov2019
		AND (ISNULL(@type, '') = '' OR ISNULL(@type, '') = 'all'
				OR (ISNULL(@type, '') <> '' AND ISNULL(@type, '') = 'tehran' AND g.CountryId = 1 AND g.CityId = 15)
				OR (ISNULL(@type, '') <> '' AND ISNULL(@type, '') = 'abroad' AND g.CountryId <> 1)
				OR (ISNULL(@type, '') <> '' AND ISNULL(@type, '') = 'other' AND g.CountryId = 1 AND g.CityId <> 15)
			)
		AND g.Id NOT IN (SELECT VALUE FROM Split(@galleryIds, ','));

    ;WITH cte
    AS (SELECT
            ROW_NUMBER() OVER (PARTITION BY tbl.id ORDER BY EventStatusId ASC) AS RowNumber,
            *
        FROM
            (
                SELECT
                    g.Id AS id,
                    g.[Name],
                    g.NameFa,
                    g.Logo,
                    g.[Address],
                    g.AddressFa,
                    g.Phone,
                    g.SecondPhoneNumber,
                    g.Website,
                    g.LogoImageHeight,
                    g.LogoImageWidth,
                    g.ModifiedDate,
                    g.Neighbourhood,
                    g.NeighbourhoodFa,
                    GE.Title,
                    GE.TitleFa,
                    GE.FromDate,
                    GE.IsSolo,
                    (CASE
                         WHEN GE.IsSolo = 0 THEN
                             'Group Exhibition'
                         WHEN (FirstName IS NULL AND LastName IS NULL AND Nickname IS NOT NULL) THEN
                             LTRIM(RTRIM(Nickname))
                         ELSE
                             LTRIM(RTRIM(FirstName)) + ' ' + LTRIM(RTRIM(LastName))
                     END
                    ) AS ArtistName,
                    (CASE
                         WHEN GE.IsSolo = 0 THEN
                             'Group Exhibition'
                         WHEN (FirstNameFa IS NULL AND FirstNameFa IS NULL AND NicknameFa IS NOT NULL) THEN
                             LTRIM(RTRIM(NicknameFa))
                         ELSE
                             LTRIM(RTRIM(FirstNameFa)) + ' ' + LTRIM(RTRIM(LastNameFa))
                     END
                    ) AS ArtistNameFa,
                    c.CityCode,
                    co.CountryCode,
                    c.Name AS CityName,
                    c.Namefa AS CityNameFa,                    
                    [dbo].[fn_EventStatus](GE.FromDate, GE.ToDate) AS EventStatus,                    
                    (CASE
                         WHEN CAST(GETDATE() AS DATE)
                              BETWEEN GE.FromDate AND GE.ToDate THEN
                             1
                         WHEN GE.ToDate < CAST(GETDATE() AS DATE) THEN
                             3
                         WHEN GE.FromDate > CAST(GETDATE() AS DATE) THEN
                             2
                         ELSE
                             3
                     END
                    ) AS EventStatusId,
					ISNULL(g.Rate, 0) AS Rate,
					CASE WHEN ISNULL(g.Rate, 0) = 9 OR ISNULL(g.Rate, 0) = 7 THEN 1
						WHEN ISNULL(g.Rate, 0) = 5 OR ISNULL(g.Rate, 0) = 3 
							OR (SELECT COUNT(1) FROM dbo.GalleryEvent ge2 WITH(NOLOCK) WHERE ge2.VerificationStatus = 2 AND ge2.GalleryId = g.Id 
									AND CAST(GETDATE() AS DATE) BETWEEN GE.FromDate AND GE.ToDate) >= 1
							THEN 2
						ELSE 3 END SortRate
                FROM
                    Gallery g
					INNER JOIN #tempGallery tg ON tg.GalleryId = g.Id
                    LEFT JOIN GalleryEvent GE ON GE.GalleryId = g.Id AND GE.VerificationStatus = 2
                    LEFT JOIN GalleryEventArtist AS gea ON gea.GalleryEvent = GE.Id
                                                           AND GE.IsSolo = 1														   
                                                           AND (CAST(GETDATE() AS DATE) BETWEEN GE.FromDate AND GE.ToDate OR GE.FromDate > CAST(GETDATE() AS DATE))
                    LEFT JOIN Artist AS a ON a.Id = gea.ArtistId
                                             AND GE.IsSolo = 1
                                             AND (CAST(GETDATE() AS DATE) BETWEEN GE.FromDate AND GE.ToDate OR GE.FromDate > CAST(GETDATE() AS DATE))
                    LEFT JOIN City c ON c.Id = g.CityId
                    LEFT JOIN Country co ON co.Id = g.CountryId                
            ) AS tbl 
		)	
		SELECT
			*
		FROM
			cte
		WHERE
			(RowNumber = 1 OR id IS NULL)
		ORDER BY
			EventStatusId ASC,
			SortRate ASC
			--ModifiedDate DESC,
			OFFSET (@PageIndex - 1) * @PageSize ROWS FETCH NEXT @PageSize ROWS ONLY;
END;