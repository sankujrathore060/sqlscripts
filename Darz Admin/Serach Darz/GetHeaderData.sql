ALTER PROCEDURE [dbo].[GetHeaderData]
AS
BEGIN
    SET TRANSACTION ISOLATION LEVEL SNAPSHOT;

    SELECT
        Id,
        LTRIM(RTRIM(FirstName)) + ' ' + LTRIM(RTRIM(LastName)) AS [Name],
        LTRIM(RTRIM(FirstNameFa)) + ' ' + LTRIM(RTRIM(LastNameFa)) AS [NameFa],
        FirstName,
        LastName,
        Nickname,
		FirstNameFa,
        LastNameFa,
        NicknameFa,
        NULL AS Picture,
        1 AS PartId,		-- ARTIST DATA,
		NULL AS [dbUrlName]
    FROM
        Artist WITH(NOLOCK)
    WHERE
        dbo.[ArtistInProgressCheck](Id) = 1
		AND VerificationStatus <> 3
    UNION ALL
    SELECT
        Id,
        LTRIM(RTRIM(Nickname)) AS [Name],
        LTRIM(RTRIM(NicknameFa)) AS [NameFa],     
        FirstName,
        LastName,
        Nickname,
		FirstNameFa,
        LastNameFa,
        NicknameFa,
        NULL AS Picture,  
        1 AS PartId,		-- ARTIST DATA
		NULL AS [dbUrlName]
    FROM
        Artist WITH(NOLOCK)
    WHERE
        Nickname IS NOT NULL
        AND dbo.[ArtistInProgressCheck](Id) = 1
		AND VerificationStatus <> 3
    UNION ALL
    SELECT
        Id,
        [Name],
        [NameFa],
        NULL AS FirstName,
        NULL AS LastName,
        NULL AS NickName,
		NULL AS FirstNameFa,
        NULL AS LastNameFa,
        NULL AS NicknameFa,
        NULL AS Picture,   
        2 AS PartId,		-- GALLERY DATA
		NULL AS [dbUrlName]
    FROM
        Gallery WITH(NOLOCK)
    WHERE
        [Name] IS NOT NULL
		AND Id <> 448		-- WE DO NOT NEED TO SHOW THIS GALLERY IN SEARCH BOX - 08OCT2019
		AND VerificationStatus = 2
    UNION ALL
    SELECT
        ar.Id,
        Title,
        TitleFa,
        a.FirstName AS FirstName,
        a.LastName AS LastName,
        a.Nickname AS NickName,
		a.FirstNameFa AS FirstNameFa,
        a.LastNameFa AS LastNameFa,
        a.NicknameFa AS NicknameFa,
        ar.Picture,
        3 AS PartId,		-- ARTWORK DATA
		NULL AS [dbUrlName]
    FROM
        vw_Artwork ar
        JOIN Artist a WITH(NOLOCK) ON a.Id = ar.ArtistId
    WHERE
        Title IS NOT NULL
        AND Title <> 'Untitled'
        AND ar.VerificationStatus = 2
		AND a.VerificationStatus = 2
    UNION ALL
    SELECT
        ae.Id,
        ah.Name + '_' + dbo.fn_DateFormat(ActualDate) AS Title,
        ah.NameFa + '_' + dbo.fn_DateFaFormat(ActualDateFa) AS TitleFa,
        ae.Title AS FirstName,
        ae.TitleFa AS LastName,
        ah.Name AS NickName,
		NULL AS FirstNameFa,
        NULL AS LastNameFa,
        NULL AS NicknameFa,
        CONVERT(CHAR(10), ActualDate, 112) AS Picture,
        4 AS PartId,		-- AUCTION DATA
		ah.Name AS [dbUrlName]
    FROM
        AuctionHouse ah WITH(NOLOCK)
		INNER JOIN AuctionEvent ae WITH(NOLOCK) ON ae.AuctionHouse = ah.Id
        INNER JOIN AuctionEventArtwork AS aer WITH(NOLOCK) ON aer.AuctionEventId = ae.Id
        INNER JOIN ArtWork AS ar WITH(NOLOCK) ON ar.Id = aer.ArtworkId
    WHERE
        ae.Title IS NOT NULL
        AND ar.VerificationStatus = 2
		AND ah.VerificationStatus = 2
    GROUP BY
        ae.Id,
        ah.Name,
        ActualDate,
        ah.NameFa,
        ActualDateFa,
        ae.Title,
        ae.TitleFa    
	UNION ALL
    SELECT
        Id,
        [Name],
        [NameFa],
        NULL AS FirstName,
        NULL AS LastName,
        NULL AS NickName,
		NULL AS FirstNameFa,
        NULL AS LastNameFa,
        NULL AS NicknameFa,
        NULL AS Picture,   
        5 AS PartId,		-- MUSEUM DATA
		[Name] AS [dbUrlName]
    FROM
        dbo.Museum WITH(NOLOCK)
    WHERE
        [Name] IS NOT NULL		
		AND VerificationStatus = 2
	UNION ALL
    SELECT
        ae.Id,
        ae.Title + '_' + dbo.fn_DateFormat(ae.FromDate) AS Title,
        ae.TitleFa + '_' + dbo.fn_DateFaFormat(ae.FromDateFa) AS TitleFa,
        af.Name AS FirstName,
        af.NameFa AS LastName,
        af.Name AS NickName,
		NULL AS FirstNameFa,
        NULL AS LastNameFa,
        NULL AS NicknameFa,
        CONVERT(CHAR(10), ae.FromDate, 112) AS Picture,
    6 AS PartId,		-- ARTFAIR EVENT DATA
		af.Name AS [dbUrlName]
    FROM
        dbo.ArtFair af WITH(NOLOCK)
		INNER JOIN dbo.ArtFairEvent ae WITH(NOLOCK) ON ae.ArtfairId = af.Id
        -- LEFT JOIN dbo.ArtFairEventArtwork AS aer WITH(NOLOCK) ON aer.ArtfairEventId = ae.Id
        -- LEFT JOIN ArtWork AS ar WITH(NOLOCK) ON ar.Id = aer.ArtworkId
    WHERE
        ae.Title IS NOT NULL
        AND ae.VerificationStatus = 2
		AND af.VerificationStatus = 2
    GROUP BY
        ae.Id,
        af.Name,
        ae.FromDate,
        af.NameFa,
        ae.FromDateFa,
        ae.Title,
        ae.TitleFa
	UNION ALL
    SELECT
        be.Id,
        be.Title + '_' + dbo.fn_DateFormat(be.FromDate) AS Title,
        be.TitleFa + '_' + dbo.fn_DateFaFormat(be.FromDateFa) AS TitleFa,
        bi.Name AS FirstName,
        bi.NameFa AS LastName,
        bi.Name AS NickName,
		NULL AS FirstNameFa,
        NULL AS LastNameFa,
        NULL AS NicknameFa,
        CONVERT(CHAR(10), be.FromDate, 112) AS Picture,
        7 AS PartId,		-- BIENNALE EVENT DATA
		bi.Name AS [dbUrlName]
    FROM
        dbo.Biennale bi WITH(NOLOCK)
		INNER JOIN dbo.BiennaleEvent be WITH(NOLOCK) ON be.BiennaleId = bi.Id        
    WHERE
        be.Title IS NOT NULL
        AND be.VerificationStatus = 2
		AND bi.VerificationStatus = 2
    GROUP BY
        be.Id,
        bi.Name,
        be.FromDate,
        bi.NameFa,
        be.FromDateFa,
        be.Title,
        be.TitleFa
	UNION ALL
	SELECT 
		g.Id,
		g.Title AS Name,
		g.TitleFa AS NameFa,
        g.GalleryName AS FirstName,
        NULL AS LastName,
        NULL AS Nickname,
		NULL AS FirstNameFa,
        NULL AS LastNameFa,
        NULL AS NicknameFa,
        NULL AS Picture,
		8 AS PartId,		-- ARTIST DATA,
		g.Title AS [dbUrlName]
	FROM 
		vw_GalleryShows as g WITH(NOLOCK) 
	WHERE  
		g.GalleryEventVerificationStatus = 2 AND g.GalleryVerificationStatus = 2  
	UNION ALL
	SELECT 
		m.Id,
		m.Title AS Name,
		m.TitleFa AS NameFa,
        m.GalleryName AS FirstName,
        NULL AS LastName,
        NULL AS Nickname,
		NULL AS FirstNameFa,
        NULL AS LastNameFa,
        NULL AS NicknameFa,
        NULL AS Picture,	-- ARTIST DATA,
		m.GalleryName AS [dbUrlName],
		9 AS PartId
	FROM 
		vw_MuseumShows as m WITH(NOLOCK)
	WHERE  
		m.MuseumEventVerificationStatus = 2 AND m.MuseumVerificationStatus = 2
	ORDER BY
        Picture DESC;
END;

