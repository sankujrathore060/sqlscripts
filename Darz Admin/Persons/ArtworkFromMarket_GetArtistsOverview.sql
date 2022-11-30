CREATE PROCEDURE [dbo].[ArtworkFromMarket_GetArtistsOverview]
    @nickname NVARCHAR(250) = NULL,
    @firstName NVARCHAR(500) = NULL,
    @lastName NVARCHAR(500) = NULL
AS
BEGIN
    SET TRANSACTION ISOLATION LEVEL SNAPSHOT;
    DECLARE @persianYear INT = 621;
    SELECT
        a.Id AS ArtistId,
        a.HideImageSet,
        al.Id,
        al.OrderInSeries,
        al.YearFrom,
        al.YearTo,
        (CASE WHEN (al.YearFromFa IS NULL OR al.YearFromFa = 0) THEN YearFrom - @persianYear ELSE al.YearFromFa END) AS YearFromFa,
        (CASE WHEN (al.YearToFa IS NULL OR al.YearToFa = 0) THEN YearTo - @persianYear ELSE al.YearToFa END) AS YearToFa,
        al.[Text],
        al.[TextFa],
        al.[Priority],
        al.[Priority2],
        al.ShowInHomePage,
        al.ShowInMobileHomePage,
        al.Note,
        al.[Source],
        al.[SourceFa],
        al.ArtistLifeLogTypeId,
        al.VerificationStatus,
        (CASE WHEN arp.Id IS NULL THEN 0 ELSE 1 END) AS ProfessionStatus,
		FirstName, LastName, Nickname,
        (CASE
             WHEN (FirstName IS NULL AND LastName IS NULL AND Nickname IS NOT NULL ) THEN
                 LTRIM(RTRIM(Nickname))
			 
             WHEN (FirstName IS NOT NULL AND LastName IS NOT NULL AND Nickname IS NOT NULL AND (IsNickNameBefore IS NOT NULL AND IsNickNameBefore > 0)) THEN
                 LTRIM(RTRIM(Nickname)) + ' (' + LTRIM(RTRIM(FirstName)) + ' ' + LTRIM(RTRIM(LastName)) + ')'
				  
             WHEN (FirstName IS NOT NULL AND LastName IS NOT NULL AND Nickname IS NOT NULL AND (IsNickNameBefore IS NULL OR IsNickNameBefore = 0)) THEN
                 LTRIM(RTRIM(FirstName)) + ' ' + LTRIM(RTRIM(LastName)) + ' (' + LTRIM(RTRIM(Nickname)) + ')'
             ELSE
                 LTRIM(RTRIM(FirstName)) + ' ' + LTRIM(RTRIM(LastName))
         END
        ) AS ArtistName,
		FirstNameFa, LastNameFa, NicknameFa,
        (CASE
             WHEN (FirstNameFa IS NULL AND FirstNameFa IS NULL AND NicknameFa IS NOT NULL) THEN
                 LTRIM(RTRIM(NicknameFa))

			 WHEN (FirstNameFa IS NOT NULL AND LastNameFa IS NOT NULL AND NicknameFa IS NOT NULL AND (IsNickNameBefore IS NOT NULL AND IsNickNameBefore > 0)) THEN
                  LTRIM(RTRIM(NicknameFa)) + ' (' + LTRIM(RTRIM(FirstNameFa)) + ' ' + LTRIM(RTRIM(LastNameFa)) +')' 
             WHEN (FirstNameFa IS NOT NULL AND LastNameFa IS NOT NULL AND NicknameFa IS NOT NULL AND (IsNickNameBefore IS NULL OR IsNickNameBefore = 0)) THEN
                 LTRIM(RTRIM(FirstNameFa)) + ' ' + LTRIM(RTRIM(LastNameFa)) + ' (' + LTRIM(RTRIM(NicknameFa)) + ')'
             ELSE
                 LTRIM(RTRIM(FirstNameFa)) + ' ' + LTRIM(RTRIM(LastNameFa))
         END
        ) AS ArtistNameFa,

        --LTRIM(RTRIM(FirstName)) +' '+ LTRIM(RTRIM(LastName)) as ArtistName,  
        --LTRIM(RTRIM(FirstNameFa)) +' '+ LTRIM(RTRIM(LastNameFA)) as ArtistNameFa,  
        ISNULL(a.FeaturedImageUrl, '') AS FeaturedImageUrl,
        ISNULL(a.FeaturedImageUrlFa, '') AS FeaturedImageUrlFa,
        a.ImageHeight,
        a.ImageWidth,
		a.Gender,
        --al.ArtworkPicture,  
        aw.Picture AS ArtworkPicture,
        aw.CreationYear,
        aw.CreationYearFa,
        aw.Title,
        aw.TitleFa,
        alt.IsActive,
        SUBSTRING(CONVERT(VARCHAR(10), al.YearFrom), 1, 3) + '0' AS [year],
        (CASE
             WHEN (al.YearFromFa IS NULL OR al.YearFromFa = 0) THEN
                 YearFrom - @persianYear
             ELSE
                 SUBSTRING(CONVERT(VARCHAR(10), al.YearFromFa), 1, 3) + '0'
         END
        ) AS [yearFa]
    INTO
        #temp
    FROM
        ArtistLifeLog AS al WITH(NOLOCK)
        INNER JOIN Artist AS a WITH(NOLOCK) ON al.ArtistId = a.Id
        INNER JOIN ArtistLifeLogType AS alt WITH(NOLOCK) ON alt.Id = al.ArtistLifeLogTypeId
        LEFT JOIN vw_ArtworkFromMarket aw WITH(NOLOCK) ON aw.LifeLogId = al.Id
        LEFT JOIN ArtistProfession AS arp WITH(NOLOCK) ON a.Id = arp.ArtistId
                                             AND arp.ProfessionId = 3
    WHERE
        al.VerificationStatus = 2
        AND
          (
              ((@firstName IS NOT NULL AND @lastName IS NOT NULL)
               AND REPLACE(a.FirstName, ' ', '') = @firstName
               AND REPLACE(a.LastName, ' ', '') = @lastName
               AND (al.ShowInHomePage = 1 OR al.ShowInMobileHomePage = 1)
              )
              OR
               ((@nickname IS NOT NULL AND @firstName IS NULL AND @lastName IS NULL)
                AND REPLACE(a.Nickname, ' ', '') = @nickname
  AND (al.ShowInHomePage = 1 OR al.ShowInMobileHomePage = 1)
       )
          )
    ORDER BY
        YearFrom ASC,
        OrderInSeries ASC;

    IF ((SELECT COUNT(*) FROM [#temp]) > 0)
    BEGIN
        SELECT
            *
        FROM
            #temp
        WHERE
            IsActive = 1
        ORDER BY
            YearFrom ASC,
            ISNULL(OrderInSeries, 99999);
    END;
    ELSE
    BEGIN
        SELECT 
			--FirstName, LastName, Nickname,
			--(CASE
			--	WHEN (FirstName IS NULL AND LastName IS NULL AND Nickname IS NOT NULL) THEN
			--		LTRIM(RTRIM(Nickname))
			--	WHEN (FirstName IS NOT NULL AND LastName IS NOT NULL AND Nickname IS NOT NULL) THEN
			--		LTRIM(RTRIM(FirstName)) + ' ' + LTRIM(RTRIM(LastName)) + ' (' + LTRIM(RTRIM(Nickname)) + ')'
			--	ELSE
			--		LTRIM(RTRIM(FirstName)) + ' ' + LTRIM(RTRIM(LastName))
			--END
			--) AS ArtistName,
			--FirstNameFa, LastNameFa, NicknameFa,
			--(CASE
			--	WHEN (FirstNameFa IS NULL AND FirstNameFa IS NULL AND NicknameFa IS NOT NULL) THEN
			--		LTRIM(RTRIM(NicknameFa))
			--	WHEN (FirstName IS NOT NULL AND LastName IS NOT NULL AND Nickname IS NOT NULL) THEN
			--		LTRIM(RTRIM(FirstNameFa)) + ' ' + LTRIM(RTRIM(LastNameFa)) + ' (' + LTRIM(RTRIM(NicknameFa))
			--		+ ')'
			--	ELSE
			--		LTRIM(RTRIM(FirstNameFa)) + ' ' + LTRIM(RTRIM(LastNameFa))
			--END
			--) AS ArtistNameFa,
			FirstName, LastName, Nickname,
        (CASE
             WHEN (FirstName IS NULL AND LastName IS NULL AND Nickname IS NOT NULL ) THEN
                 LTRIM(RTRIM(Nickname))
			 
             WHEN (FirstName IS NOT NULL AND LastName IS NOT NULL AND Nickname IS NOT NULL AND (IsNickNameBefore IS NOT NULL AND IsNickNameBefore > 0)) THEN
                 LTRIM(RTRIM(Nickname)) + ' (' + LTRIM(RTRIM(FirstName)) + ' ' + LTRIM(RTRIM(LastName)) + ')'
				  
             WHEN (FirstName IS NOT NULL AND LastName IS NOT NULL AND Nickname IS NOT NULL AND (IsNickNameBefore IS NULL OR IsNickNameBefore = 0)) THEN
                 LTRIM(RTRIM(FirstName)) + ' ' + LTRIM(RTRIM(LastName)) + ' (' + LTRIM(RTRIM(Nickname)) + ')'
             ELSE
                 LTRIM(RTRIM(FirstName)) + ' ' + LTRIM(RTRIM(LastName))
         END
        ) AS ArtistName,
		FirstNameFa, LastNameFa, NicknameFa,
        (CASE
             WHEN (FirstNameFa IS NULL AND FirstNameFa IS NULL AND NicknameFa IS NOT NULL) THEN
                 LTRIM(RTRIM(NicknameFa))

			 WHEN (FirstNameFa IS NOT NULL AND LastNameFa IS NOT NULL AND NicknameFa IS NOT NULL AND (IsNickNameBefore IS NOT NULL AND IsNickNameBefore > 0)) THEN
                  LTRIM(RTRIM(NicknameFa)) + ' (' + LTRIM(RTRIM(FirstNameFa)) + ' ' + LTRIM(RTRIM(LastNameFa)) +')'

             WHEN (FirstNameFa IS NOT NULL AND LastNameFa IS NOT NULL AND NicknameFa IS NOT NULL AND (IsNickNameBefore IS NULL OR IsNickNameBefore = 0)) THEN
                 LTRIM(RTRIM(FirstNameFa)) + ' ' + LTRIM(RTRIM(LastNameFa)) + ' (' + LTRIM(RTRIM(NicknameFa)) + ')'
             ELSE
                 LTRIM(RTRIM(FirstNameFa)) + ' ' + LTRIM(RTRIM(LastNameFa))
         END
        ) AS ArtistNameFa,			
			Id AS ArtistId,
			VerificationStatus,
			Gender
        FROM
            Artist WITH(NOLOCK)
        WHERE
            ((@firstName IS NOT NULL AND @lastName IS NOT NULL)
            AND   REPLACE(FirstName, ' ', '') = @firstName
            AND   REPLACE(LastName, ' ', '') = @lastName
            )
            OR ((@nickname IS NOT NULL AND @firstName IS NULL AND @lastName IS NULL) AND REPLACE(Nickname, ' ', '') = @nickname);
    END;
    DROP TABLE #temp;
END;