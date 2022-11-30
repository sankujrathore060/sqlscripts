CREATE PROCEDURE [dbo].[ArtworkFromMarket_GetAllArtwork]
    @UserId UNIQUEIDENTIFIER = NULL,
    @artistId INT = 0,
    @artworkId INT = 0,
    @alphabet VARCHAR(5) = NULL,
    @PageIndex INT = 1,
    @categoryId INT = 0,
    @year VARCHAR(50) = '0',
    @PageSize INT = 20
AS
BEGIN
    
    SET TRANSACTION ISOLATION LEVEL SNAPSHOT;
	SET NOCOUNT ON;
	
	;WITH cte
    AS (
		--SELECT ROW_NUMBER() OVER  
		--(  
		--     -- Condition: When Creation Year is null show them last in list  
		--		ORDER BY  IIF(aw.CreationYear IS NULL or aw.CreationYear = 0 or aw.CreationYear = -1,1, 0) asc, aw.ModifiedDate DESC  
		--)AS RowNumber,  
		SELECT
			ROW_NUMBER() OVER (PARTITION BY
									aw.ArtistId
								ORDER BY
									IIF(aw.CreationYear IS NULL OR aw.CreationYear = 0 OR aw.CreationYear = -1, 1, 0) ASC,
									aw.Id ASC,
									aw.ModifiedDate DESC
								) AS RowNumber,
			aw.Id,
			aw.Title,
			aw.TitleFa,
			aw.Collaboration,
			aw.CollaborationFa,
			aw.IsCollaborationDisplayOnWebsite,
			aw.IsAuctionRecord,
			aw.Series,
			aw.SeriesFa,
			CASE
				WHEN (aw.CreationYear <> 0 AND aw.CreationYear <> -1) THEN
					aw.CreationYear
				ELSE
					NULL
			END AS CreationYear,
			CASE
				WHEN (aw.CreationYearFa <> 0 AND aw.CreationYearFa <> -1 AND aw.CreationYearFa <> -622) THEN
					aw.CreationYearFa
				ELSE
					NULL
			END AS CreationYearFa,
			aw.Picture,
			aw.Height,
			aw.Width,
			aw.Depth,
			aw.Length,
			aw.SizeUnit,
			aw.ImageWidth,
			aw.ImageHeight,
			aw.Medium,
			aw.MediumFa,           
			aw.rowguid,
			aw.ArtistId,
			aw.ModifiedDate,
			aw.LastStatusDescription,
			aw.LastStatusDescriptionFa,
			aw.Category,
			cat.Name AS CategoryName,
			cat.Namefa AS CategoryNameFa,
			f.Id AS FavouriteId,
			(CASE
				WHEN aw.VerificationStatus = 2 THEN
					1
				WHEN aw.VerificationStatus = 3 THEN
					2
				WHEN aw.VerificationStatus = 1 THEN
					3
				ELSE
					4
			END
			) AS VerificationStatus,
			LTRIM(RTRIM(a.Nickname)) AS NickName,
			LTRIM(RTRIM(a.FirstName)) AS FirstName,
			LTRIM(RTRIM(a.LastName)) AS LastName,
			dbo.Artist_GetName(a.FirstName, a.LastName, a.Nickname, a.IsNickNameBefore, 0) as ArtistName,
			dbo.Artist_GetName(a.FirstNameFa, a.LastNameFa, a.NicknameFa, a.IsNickNameBefore, 0) as ArtistNameFa,
			a.VerificationStatus AS Artist_VerificationStatus,
			gaa.GalleryId AS GalleryId,
			aw.ArtworkEdition,
			aw.ArtworkEditionFa
       FROM
           vw_ArtworkFromMarket AS aw WITH (NOLOCK)
           LEFT JOIN Artist AS a WITH (NOLOCK) ON aw.ArtistId = a.Id
           LEFT JOIN Favourites f WITH (NOLOCK) ON aw.Id = f.MainId
                                                   AND f.UserId = @UserId
           LEFT JOIN Category cat WITH (NOLOCK) ON cat.Id = aw.Category
		   LEFT JOIN dbo.GalleryAssignArtworks gaa WITH(NOLOCK) ON gaa.ArtWorkId = aw.Id	
       WHERE
           (@categoryId = 0 OR aw.Category = @categoryId)
           AND (@artistId = 0 OR aw.ArtistId = @artistId)
           AND
             (
                @year = '0'
                OR aw.CreationYear
				BETWEEN CONVERT(INT, (SUBSTRING(@year, 1, 4))) AND CONVERT(INT, SUBSTRING(@year, 6, 9))
             )
           AND aw.VerificationStatus = 2
           AND a.VerificationStatus = 2
	),
    cte1
    AS (
		SELECT
            *
        FROM
            cte
        ORDER BY
            NEWID() ASC,
            RowNumber ASC OFFSET ((@PageIndex - 1) * @PageSize) ROWS FETCH NEXT @PageSize ROWS ONLY
		),
		cte2
	AS (SELECT * FROM cte WHERE cte.Id = @artworkId)
	SELECT
        *
    INTO #results
    FROM cte1
    UNION
    (SELECT * FROM cte2);

    SELECT
        *
    FROM
        #results;
	
	--DROP TABLE #ArtworkResults;
END;