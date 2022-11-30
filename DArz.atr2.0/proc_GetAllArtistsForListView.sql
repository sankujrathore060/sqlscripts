CREATE PROCEDURE [dbo].[proc_GetAllArtistsForListView]
    @UserId UNIQUEIDENTIFIER = NULL,
    @alphabet VARCHAR(5) = NULL,
    @professionId INT = 0,
	@PageArtistIDs varchar(max) = null,
	@Sort varchar(max) = null
AS
BEGIN
    SET TRANSACTION ISOLATION LEVEL SNAPSHOT;

    SELECT
        Title,
        COUNT(1) AS cnt
    INTO
        #logtable
    FROM
        ApplicationUserLogActivity WITH(NOLOCK)
    WHERE
        PageName = 'Overview'
    GROUP BY
        Title;

	SELECT
        ArtistId,
        COUNT(ArtistId) AS cnt
    INTO
        #artworkTable
    FROM
        vw_Artwork
    WHERE
        VerificationStatus = 2
    GROUP BY
        ArtistId;

	SELECT
        ArtistId,
        COUNT(ArtistId) AS cnt
    INTO
        #lifeLogTable_verified
    FROM
        ArtistLifeLog WITH(NOLOCK)
    WHERE
        VerificationStatus = 2
    GROUP BY
        ArtistId;

    SELECT
        RANK() OVER (PARTITION BY IsFeaturedImageURL ORDER BY HideImageSet ASC, ModifiedDate DESC) AS RowNumber,
        *
    INTO
        #Results
    FROM
        (
            SELECT
                ROW_NUMBER() OVER (PARTITION BY a.Id ORDER BY a.FeaturedImageUrl DESC) AS row,
                a.Id,
                LTRIM(RTRIM(a.FirstName)) AS FirstName,
                LTRIM(RTRIM(a.LastName)) AS LastName,
                a.FirstNameFa,
                a.LastNameFa,
                a.Nickname,
                a.NicknameFa,
                CASE
                    WHEN (a.BornYear <> 0 AND a.BornYear <> -1) THEN
                        a.BornYear
                    ELSE
                        NULL
                END AS BornYear,
                CASE
                    WHEN (a.BornYearFa <> 0 AND a.BornYearFa <> -1) THEN
                        a.BornYearFa
                    ELSE
                        NULL
                END AS BornYearFa,
                a.DieYear,
                a.DieYearFa,
                ISNULL(a.FeaturedImageUrl, '') AS FeaturedImageUrl,
                ISNULL(a.FeaturedImageUrlFa, '') AS FeaturedImageUrlFa,
                ISNULL(a.MobileFeaturedImageUrl, '') AS MobileFeaturedImageUrl,
                a.ImageHeight,
                a.ImageWidth,
                a.HideImageSet,
                ap.ProfessionId,
                f.Id AS FavouriteId,
                --(CASE WHEN arp.Id is null 
                --THEN 0 ELSE 1 END) as ProfessionStatus, 
                a.ModifiedDate,
                --(CASE
                --     WHEN a.VerificationStatus = 2 THEN
                --         1
                --     WHEN a.VerificationStatus = 3 THEN
                --         2
                --     WHEN a.VerificationStatus = 1 THEN
                --         3
                --     ELSE
                --         4
                -- END
                --) VerificationStatus,
				a.VerificationStatus,
                CASE
                    WHEN FeaturedImageUrl IS NULL THEN
                        1
                    ELSE
                        0
                END AS IsFeaturedImageURL,
				dbo.Artist_GetLastActivityDate(a.Id) as LastEventDate,
				dbo.Artist_GetLastModifiedDate(a.Id) as LastModifiedDate,
				aw.cnt as VerifiedArtwork,
				lv.cnt as Verifiedlogs
            FROM
                Artist a WITH(NOLOCK)
                LEFT JOIN ArtistProfession AS ap WITH(NOLOCK) ON a.Id = ap.ArtistId
                LEFT JOIN Favourites f WITH(NOLOCK) ON a.Id = f.MainId
                                          AND f.UserId = @UserId
				LEFT JOIN #artworkTable aw ON a.Id = aw.ArtistId
				LEFT JOIN #lifeLogTable_verified lv ON lv.ArtistId = a.Id
            WHERE
                VerificationStatus = 2
                AND a.FeaturedImageUrl IS NOT NULL
                AND
					-- (@professionId = 0 OR ap.ProfessionId = @professionId)
					(
						(@professionId = 0)
						OR
						(@professionId > 0 AND ap.ProfessionId = @professionId)
						OR 
						(@professionId = -1) -- AND ap.ProfessionId NOT IN (1014, 14, 6, 1034, 1013))
					)
        ) AS tbl
    WHERE
        (tbl.row = 1 OR Id IS NULL);

	-- REMOVE RECORDs WHICH ARE TOP CATEGORY WHEN SELECTED OTHER
	IF(@professionId = -1)
	BEGIN
			SELECT 
				a.Id as ArtistId
			INTO #temp_top_category_artist
			FROM 
				Artist a WITH(NOLOCK)	
				LEFT JOIN ArtistProfession AS ap WITH(NOLOCK) ON a.Id = ap.ArtistId
			WHERE ap.ProfessionId IN (1014, 14, 6, 1034, 1013)
				AND a.VerificationStatus = 2
                AND a.FeaturedImageUrl IS NOT NULL
			GROUP BY a.Id

			-- select count(*) from #Results
			-- select count(*) from #temp_top_category_artist

			DELETE FROM #Results WHERE Id IN (SELECT ArtistId FROM #temp_top_category_artist)

			DROP TABLE #temp_top_category_artist
	END

	-- SELECT Id, Count(*) FROM #Results GROUP BY Id HAVING Count(*) > 1;

	IF(ISNULL(@PageArtistIDs, '') <> '')
	BEGIN
			-- REMOVE RECORDs THAT ON PAGE
			DELETE FROM #Results WHERE Id in (SELECT VALUE FROM Split(@PageArtistIDs, ','))
	END		

    DECLARE @RecordCount INT;
    SELECT @RecordCount = COUNT(*) FROM #Results;

	IF(@Sort = 'abc')
	BEGIN
			SELECT
				r.*
			FROM
				#Results AS r
			WHERE
				ISNULL(r.LastName, '') <> ''
			ORDER BY
				r.LastName ASC,
				NEWID() ASC,
				r.VerificationStatus ASC,	
				r.IsFeaturedImageURL DESC
	END
	ELSE IF(@Sort = 'recentlyAdded')
	BEGIN
			SELECT
				r.*
			FROM
				#Results AS r
			ORDER BY
				r.LastModifiedDate DESC,
				NEWID() ASC,
				r.VerificationStatus ASC,	
				r.IsFeaturedImageURL DESC
	END	
	ELSE IF(@Sort = 'recentlyActive')
	BEGIN
			SELECT
				r.*
			FROM
				#Results AS r
			ORDER BY	
				r.LastEventDate DESC,
				NEWID() ASC,
				r.LastModifiedDate DESC,
				r.VerificationStatus ASC,	
				r.IsFeaturedImageURL DESC
	END  
	ELSE IF(@Sort = 'mostPopular')
	BEGIN
			SELECT
				r.*,
				ISNULL(t.cnt, 0) AS MostPopularCount
			FROM
				#Results AS r
				LEFT JOIN #logtable t ON (t.Title LIKE '%' + FirstName + '_' + REPLACE(LastName, '-', '') OR t.Title LIKE '%' + Nickname)
			WHERE
				ISNULL(t.cnt, 0) > 0
			ORDER BY			
				MostPopularCount DESC,			
				NEWID() ASC,
				r.LastModifiedDate DESC,
				r.VerificationStatus ASC,	
				r.IsFeaturedImageURL DESC
	END
	ELSE
	BEGIN
			SELECT
				r.*
			FROM
				#Results AS r
			ORDER BY
				NEWID() ASC,				
				r.VerificationStatus ASC,	
				r.IsFeaturedImageURL DESC
	END 
END;
