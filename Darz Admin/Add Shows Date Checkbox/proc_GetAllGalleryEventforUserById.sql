ALTER PROCEDURE [dbo].[proc_GetAllGalleryEventforUserById] 
	@galleryEventId INT = 0
	--@latitude varchar(50),          
	--@longitude varchar(50)          
AS
BEGIN
    SET TRANSACTION ISOLATION LEVEL SNAPSHOT;

	DECLARE @IsParellelOpening BIT = 0;
    DECLARE @date DATE = CAST(GETDATE() AS DATE);

    --Get Gallery Event Details by Id         
    SELECT
        ge.Id,
		ge.GalleryId,
        ge.Title,
        ge.TitleFa,
        ge.[Description],
        ge.DescriptionFa,
        ge.[Statement],
        ge.StatementFa,
        ge.PosterImageUri,
        ge.ImageHeight AS PosterImageHeight,
        ge.ImageWidth AS PosterImageWidth,
        ge.FromDate,
        ge.FromDateFa,
        ge.ToDateFa,
        ge.ToDate,
        ge.IsSolo,
        ge.Curator,
        ge.CuratorFa,
		ge.IsOtherExhibition,
		ge.OtherExhibitionText,
		ge.OtherExhibitionTextFa,
		ge.VerificationStatus AS VerificationStatus,
		ge.Body,
		ge.BodyFa,
		ge.IsBodyDisplayInWebsite,
        ge.IsCommingSoonDisplayInWebsite,
		g.OpenTime,
        g.CloseTime,
        g.[Name] AS GalleryName,
        g.NameFa AS GalleryNameFa,
        g.[Address],
        g.AddressFa,
        g.Phone,
		g.IsCityCodeAdded,
        g.SecondPhoneNumber,
        g.Website,
        g.Logo,
        g.LogoImageWidth,
        g.LogoImageHeight,
        --g.Latitude,
        --g.Longitude,
		CASE WHEN ISNULL(ge.Latitude, 0) = 0 THEN g.Latitude ELSE ge.Latitude END AS Latitude,
		CASE WHEN ISNULL(ge.Longitude, 0) = 0 THEN g.Longitude ELSE ge.Longitude END AS Longitude,
        g.Neighbourhood,
        g.NeighbourhoodFa,
        c.CityCode,
		c.Name as CityName,
		c.NameFa as CityNameFa,
        co.CountryCode,
		co.Name as CountryName,
		co.NameFa as CountryNameFa,
        a.VerificationStatus as Artist_VerificationStatus,	
		a.Id AS ArtistId,	
        LTRIM(RTRIM(FirstName)) AS FirstName,
        LTRIM(RTRIM(LastName)) AS LastName,
        LTRIM(RTRIM(Nickname)) AS NickName,
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
        (CASE
             WHEN ge.IsSolo = 0 THEN
                 STUFF(
                     (
                         SELECT
                             ','
                             + (CASE
                                    WHEN a.FirstName IS NULL
                                         AND a.LastName IS NULL THEN
                                        LTRIM(RTRIM(a.Nickname)) + '-' + CAST(a.VerificationStatus AS NVARCHAR(1))
                                    ELSE
                                        LTRIM(RTRIM(a.FirstName)) + '+' + LTRIM(RTRIM(a.LastName)) + '-'
                                        + CAST(a.VerificationStatus AS NVARCHAR(1))
                                END
                               )
                         FROM
                             GalleryEventArtist AS ga WITH(NOLOCK)
                             INNER JOIN Artist AS a WITH(NOLOCK) ON a.Id = ga.ArtistId
                         WHERE
                             ga.GalleryEvent = ge.Id
     FOR XML PATH('')
                     ),
                     1,
  1,
                     ''
                      )
         END
        ) AS OtherArtistName,
 (CASE
             WHEN ge.IsSolo = 0 THEN
                 STUFF(
     (
   SELECT
                  ','
                             + (CASE
                                    WHEN a.FirstNameFa IS NULL
                                         AND a.LastNameFa IS NULL THEN
  LTRIM(RTRIM(a.NicknameFa)) + '-' + CAST(a.VerificationStatus AS NVARCHAR(1))
                                    ELSE
                                        LTRIM(RTRIM(a.FirstNameFa)) + '+' + LTRIM(RTRIM(a.LastNameFa)) + '-'
                                        + CAST(a.VerificationStatus AS NVARCHAR(1))
                                END
                               )
                         FROM
                             GalleryEventArtist AS ga WITH(NOLOCK)
                             INNER JOIN Artist AS a WITH(NOLOCK) ON a.Id = ga.ArtistId
                         WHERE
                             ga.GalleryEvent = ge.Id
                         FOR XML PATH('')
                     ),
                     1,
                     1,
                     ''
                      )
         END
        ) AS OtherArtistNameFa,
        [dbo].[fn_EventStatus](ge.FromDate, ge.ToDate) AS EventStatus,
		 CASE WHEN ge.ToDate < CAST(GETDATE() AS DATE) THEN
                1
            ELSE
                0
        END AS IsPastShow
    FROM
        GalleryEvent AS ge WITH(NOLOCK)
        INNER JOIN Gallery AS g WITH(NOLOCK) ON g.Id = ge.GalleryId
        LEFT JOIN GalleryEventArtist AS gea WITH(NOLOCK) ON gea.GalleryEvent = ge.Id
                                               AND ge.IsSolo = 1
        LEFT JOIN City AS c WITH(NOLOCK) ON c.Id = g.CityId
        LEFT JOIN Country AS co WITH(NOLOCK) ON co.Id = g.CountryId
        LEFT JOIN Artist AS a WITH(NOLOCK) ON a.Id = gea.ArtistId
    WHERE
        ge.Id = @galleryEventId; -- and ge.ToDate > cast (GETDATE() as DATE)          
    --and  ge.PosterImageUri is not null          

    --Get Artwork of Artist Data          
    SELECT
        --a.FirstName +' '+ a.LastName as ArtistName,          
        --a.FirstNameFa +' '+ a.LastNameFa as ArtistNameFa,          
        (CASE
             WHEN a.FirstName IS NULL
                  AND a.LastName IS NULL THEN
                 a.Nickname
             ELSE
                 LTRIM(RTRIM(a.FirstName)) + ' ' + LTRIM(RTRIM(a.LastName))
         END
        ) AS ArtistName,
        (CASE
             WHEN a.FirstNameFa IS NULL
                  AND a.LastNameFa IS NULL THEN
                 a.NicknameFa
             ELSE
                 LTRIM(RTRIM(a.FirstNameFa)) + ' ' + LTRIM(RTRIM(a.LastNameFa))
         END
        ) AS ArtistNameFa,
        LTRIM(RTRIM(a.FirstName)) AS FirstName,
        LTRIM(RTRIM(a.LastName)) AS LastName,
        LTRIM(RTRIM(a.Nickname)) AS NickName,
        -- dbo.fn_ArtworkSize(ar.Height, ar.Width, ar.Depth) AS Size,
		ar.Height, 
		ar.Width, 
		ar.Depth,
		ar.[Length],
		ar.SizeUnit, 
        ar.ArtistId,
        ar.Medium,
        ar.MediumFa,
        a.BornYear,
        a.DieYear,
        a.BornYearFa,
        a.DieYearFa,
        a.Id AS ArtistId,
        ar.Id AS ArtworkId,
        ar.Title,
        ar.TitleFa,
        ar.CreationYear,
        ar.CreationYearFa,
		ar.Category,
        ar.Picture,
        ar.ImageHeight,
        ar.ImageWidth,
		ar.Collaboration,
		ar.CollaborationFa,
		ar.LastStatusDescription,   
		ar.LastStatusDescriptionFa, 
		a.VerificationStatus AS Artist_VerificationStatus
    FROM
        GalleryEventArtwork AS ga WITH(NOLOCK)
        INNER JOIN vw_Artwork AS ar WITH(NOLOCK) ON ar.Id = ga.ArtworkId
        INNER JOIN Artist AS a WITH(NOLOCK) ON a.Id = ar.ArtistId
    WHERE
        ga.GalleryEventId = @galleryEventId
		AND ar.Picture IS NOT NULL
		AND ISNULL(ga.IsAssigned, 0) = 1;

    --select
    -- a.FirstName +' '+ a.LastName as ArtistName,          
    -- a.BornYear,          
    -- a.DieYear,          
    -- a.Id as ArtistId           
    -- from GalleryEventArtist as ga          
    -- inner join Artist as a on a.Id = ga.ArtistId   
    -- where ga.GalleryEvent = @galleryEventId          

    --SELECT *  into #Results          
    --FROM   (select GalleryEvent.Id,Latitude,longitude from Gallery inner join GalleryEvent on Gallery.Id = GalleryEvent.GalleryId           
    --where GalleryEvent.Id = @galleryEventId ) as tbl          

    --SELECT *  from #Results      
    --Get Nearby Gallery Event Data    
	
    IF NOT EXISTS
    (
		SELECT
			1
         FROM
             GalleryEvent r WITH(NOLOCK)
         WHERE
			VerificationStatus = 2
            AND ((@date >= r.FromDate AND @date <= r.ToDate) OR r.FromDate < @date)
            AND r.Id = @galleryEventId
     )
    BEGIN
        SET @IsParellelOpening = 1;

    -- COMMETED ON 01Apr2019 - TO DISPLAY CORRECT PARELLEL OPENINGs
    --IF NOT EXISTS(SELECT 1 FROM GalleryEvent ge    
    --			WHERE ge.FromDate > @date  and ge.Id <> @galleryEventId and ge.GalleryId IN (SELECT GalleryId FROM GalleryEvent WHERE Id = @galleryEventId))    
    --BEGIN    
    --	SET @IsParellelOpening = 1
    --END    
    END;

	-- NEAR BY GALLEY SHOWs
    SELECT
        ge.Id,
        ge.Title,
        ge.TitleFa,
        ge.FromDate,
        ge.ToDate,
        ge.FromDateFa,
        ge.ToDateFa,
        ge.PosterImageUri,
        ge.IsSolo,
        ge.ImageHeight AS PosterImageHeight,
        ge.ImageWidth AS PosterImageWidth,
		ge.IsOtherExhibition,
		ge.OtherExhibitionText,
		ge.OtherExhibitionTextFa,
        a.Id AS ArtistId,
        LTRIM(RTRIM(FirstName)) AS FirstName,
        LTRIM(RTRIM(LastName)) AS LastName,
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
        g.OpenTime,
        g.CloseTime,
        g.Name AS GalleryName,
        g.NameFa AS GalleryNameFa,
        --g.Latitude AS NearbyLatitude,
        --g.Longitude AS NearbyLongitude,
		CASE WHEN ISNULL(ge.Latitude, 0) = 0 THEN g.Latitude ELSE ge.Latitude END AS NearbyLatitude,
		CASE WHEN ISNULL(ge.Longitude, 0) = 0 THEN g.Longitude ELSE ge.Longitude END AS NearbyLongitude,
        g.[Address],
        g.AddressFa,
        @IsParellelOpening AS IsParellelOpening,
        CASE
            WHEN ((@date >= r.FromDate AND @date <= r.ToDate)) THEN
                0
            ELSE
                1
        END AS IsCurrent,
        r.Latitude,
        r.Longitude
    FROM
        GalleryEvent AS ge WITH(NOLOCK)
        LEFT JOIN GalleryEventArtist AS gea WITH(NOLOCK) ON gea.GalleryEvent = ge.Id
                                               AND ge.IsSolo = 1
        LEFT JOIN Artist AS a WITH(NOLOCK) ON gea.ArtistId = a.Id
        INNER JOIN Gallery AS g WITH(NOLOCK) ON g.Id = ge.GalleryId,
		(SELECT
			   --Gallery.Latitude,
			   --Gallery.Longitude,
				CASE WHEN ISNULL(GalleryEvent.Latitude, 0) = 0 THEN Gallery.Latitude ELSE GalleryEvent.Latitude END AS Latitude,
				CASE WHEN ISNULL(GalleryEvent.Longitude, 0) = 0 THEN Gallery.Longitude ELSE GalleryEvent.Longitude END AS Longitude,
				GalleryEvent.FromDate,
				GalleryEvent.ToDate,
				Gallery.Id AS GId
        FROM
               Gallery WITH(NOLOCK)
               LEFT JOIN GalleryEvent WITH(NOLOCK) ON Gallery.Id = GalleryEvent.GalleryId
           WHERE
				GalleryEvent.Id = @galleryEventId
       ) r
    WHERE
		ge.VerificationStatus = 2
        --ge.FromDate >= GetDate() and ge.FromDate < GETDATE() + 7          
		AND ge.Id <> @galleryEventId
        AND
          (
       ((@date BETWEEN r.FromDate AND r.ToDate OR r.FromDate = @date)
               AND
				(
                     @date >= ge.FromDate
                     AND @date <= ge.ToDate
                     AND ge.GalleryId <> r.GId
                     AND
						(
							((g.Latitude BETWEEN r.Latitude - (4 / 111.045) AND r.Latitude + (4 / 111.045))
							AND (g.Longitude BETWEEN r.Longitude - (4 / (111.045 * COS(RADIANS(r.Longitude)))) AND r.Longitude + (4 / (111.045 * COS(RADIANS(r.Latitude))))))
							OR
							((ge.Latitude BETWEEN r.Latitude - (4 / 111.045) AND r.Latitude + (4 / 111.045))
							AND (ge.Longitude BETWEEN r.Longitude - (4 / (111.045 * COS(RADIANS(r.Longitude)))) AND r.Longitude + (4 / (111.045 * COS(RADIANS(r.Latitude))))))
						)
                 )
              )
              OR (
              (
                  (
                      @IsParellelOpening = 1
                      AND (ge.FromDate > @date)
                      AND
                        (
                            ge.FromDate = r.FromDate
                            AND ge.GalleryId <> r.GId
                            AND 
							(
								((g.Latitude BETWEEN r.Latitude - (4 / 111.045) AND r.Latitude + (4 / 111.045))
								AND (g.Longitude BETWEEN r.Longitude - (4 / (111.045 * COS(RADIANS(r.Longitude)))) AND r.Longitude + (4 / (111.045 * COS(RADIANS(r.Latitude))))))
								OR
								((ge.Latitude BETWEEN r.Latitude - (4 / 111.045) AND r.Latitude + (4 / 111.045))
								AND (ge.Longitude BETWEEN r.Longitude - (4 / (111.045 * COS(RADIANS(r.Longitude)))) AND r.Longitude + (4 / (111.045 * COS(RADIANS(r.Latitude))))))
							)
                        )
                  )
                  OR
                   (
                       @IsParellelOpening = 0
                       AND ge.FromDate <= @date
                       AND ge.ToDate >= @date
                       AND (ge.Id IN ( SELECT Id FROM GalleryEvent WHERE GalleryId = r.GId AND @date >= FromDate AND @date <= ToDate ))
                   )
              )
                 )
          )
        AND ge.PosterImageUri IS NOT NULL
    ORDER BY
        ToDate;
END;