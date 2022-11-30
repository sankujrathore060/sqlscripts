ALTER PROCEDURE [dbo].[proc_GalleryGetAllArchivedShows]
    @PageIndex INT = 1,
    @PageSize INT = 20,
	@ArtistId int = 0,    
	@GalleryId int = 0,    
	@Season varchar(max) = '',
	@CityId int = 0,
	@SeasonFa varchar(max) = '',
	@sPageShowIDs VARCHAR(MAX) = '',
	@sPageMuseumShowIDs VARCHAR(MAX) = '',
	@MuseumId int = 0
AS
BEGIN
    DECLARE @TCount INT = 0;    
	
	SELECT 
		g.*
	INTO #tmpShows FROM 
	(
		SELECT
			g.*,
			0 AS IsMuseum
		FROM
			dbo.vw_GalleryShows g
		WHERE
			g.Id NOT IN (SELECT Value FROM dbo.Split(@sPageShowIDs, ','))
		UNION ALL
		SELECT
			m.*,
			1 AS IsMuseum
		FROM
			dbo.vw_MuseumShows m
		WHERE
			m.Id NOT IN (SELECT Value FROM dbo.Split(@sPageMuseumShowIDs, ','))
	) g
    WHERE
        g.GalleryEventVerificationStatus = 2
		AND g.GalleryVerificationStatus = 2		
        AND g.ToDate < CAST(GETDATE() AS DATE)
		AND (@GalleryId = 0 OR (g.GalleryId = @GalleryId  AND IsMuseum = 0))
		AND (@MuseumId = 0 OR (g.GalleryId = @MuseumId AND IsMuseum = 1))
		AND (@ArtistId = 0 OR (g.ArtistId = @ArtistId AND g.VerificationStatus = 2))
		AND (@CityId = 0 OR g.CityId = @CityId)
		AND (@Season = '' OR @Season = '0' OR g.EventFromDate_MMYYYY = @Season)
		AND (@SeasonFa = '' OR @SeasonFa = '0' OR g.EventFromDate_MMYYYY_Fa = @SeasonFa)

	SELECT @TCount = COUNT(*) FROM #tmpShows;
	SELECT 
		*,
		@TCount AS TotalRecord
	FROM 
		#tmpShows
    ORDER BY
        ToDate DESC,
        FromDate OFFSET ((@PageIndex - 1) * @PageSize) ROWS FETCH NEXT @PageSize ROWS ONLY;
END;