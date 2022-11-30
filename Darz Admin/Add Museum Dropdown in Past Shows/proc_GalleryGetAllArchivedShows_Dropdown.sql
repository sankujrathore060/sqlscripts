ALTER PROCEDURE [dbo].[proc_GalleryGetAllArchivedShows_Dropdown]
	@ArtistId int = 0,    
	@GalleryId int = 0,
	@MuseumId int = 0,    
	@Season varchar(max) = '',
	@CityId int = 0,
	@SeasonFa varchar(max) = ''
AS
BEGIN

    SELECT 
		g.*
	INTO #tmpShows FROM 
	(
		SELECT
			g.*,
			0 AS IsMuseum
		FROM
			dbo.vw_GalleryShows g
		UNION ALL
		SELECT
			m.*,
			1 AS IsMuseum
		FROM
			dbo.vw_MuseumShows m
	) g
    WHERE
        g.GalleryEventVerificationStatus = 2
		AND g.GalleryVerificationStatus = 2		
        AND g.ToDate < CAST(GETDATE() AS DATE)
		AND (@GalleryId = 0 OR g.GalleryId = @GalleryId)
		AND (@MuseumId = 0 OR g.GalleryId = @MuseumId)
		AND (@ArtistId = 0 OR (g.ArtistId = @ArtistId AND g.VerificationStatus = 2))
		AND (@CityId = 0 OR g.CityId = @CityId)
		AND (@Season = '' OR @Season = '0' OR g.EventFromDate_MMYYYY = @Season)
		AND (@SeasonFa = '' OR @SeasonFa = '0' OR g.EventFromDate_MMYYYY_Fa = @SeasonFa)

	SELECT * FROM Artist WITH(NOLOCK) WHERE Id in (SELECT ArtistId FROM #tmpShows WHERE ISNULL(ArtistId, 0) > 0);

	SELECT Id, [Name], [NameFa] FROM Gallery WITH(NOLOCK) WHERE Id in (SELECT GalleryId FROM #tmpShows WHERE IsMuseum = 0);
	
	SELECT Id, [Name], [NameFa] FROM Museum WITH(NOLOCK) WHERE Id in (SELECT GalleryId FROM #tmpShows WHERE IsMuseum = 1);

	SELECT 
		EventFromDate_MMYYYY as [Text], 
		EventFromDate_MMYYYY as [Value] 
	FROM 
		#tmpShows 
	WHERE
		ISNULL(EventFromDate_MMYYYY, '') <> ''
	GROUP BY 
		EventFromDate_MMYYYY
	ORDER BY 
		CAST(('01' + '-' + EventFromDate_MMYYYY) AS DATE) DESC;

	SELECT * FROM City WITH(NOLOCK) WHERE Id in (SELECT CityId FROM #tmpShows);

	SELECT 
		EventFromDate_MMYYYY_Fa as [Text], 
		EventFromDate_MMYYYY_Fa as [Value] 
	FROM 
		#tmpShows 
	WHERE
		ISNULL(EventFromDate_MMYYYY_Fa, '') <> ''
	GROUP BY 
		EventFromDate_MMYYYY_Fa
	ORDER BY 
		CAST(('01' + '-' + EventFromDate_MMYYYY_Fa) AS DATE) DESC;
END;
