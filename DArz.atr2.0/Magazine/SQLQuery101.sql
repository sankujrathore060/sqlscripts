ALTER PROCEDURE [dbo].[Profile_CollectorArtworks] 
	@CollectorId INT = 0,	
    @ArtistId INT = 0,
	@PageIndex INT = 1,
    @PageSize INT = 20,
	@Sort varchar(max) = '0'
AS
BEGIN
    SET TRANSACTION ISOLATION LEVEL SNAPSHOT;
    SET NOCOUNT ON;

	-- GET ADD DATA HISTORY COLLECTOR ARTWORK BY USER
	;WITH cte AS 
	(
		SELECT
			dt.Id,
			CAST(REPLACE(REPLACE(dt.NewText, '<img src=', ''), '&', '&amp;') AS XML) AS xmlNewText
		FROM
			DataHistory dt WITH (NOLOCK)
		WHERE
			dt.PageId = 27
			AND dt.CollectorId = @CollectorId
			AND dt.IsAdd = 1
			AND ISNULL(dt.IsCompleted, 0) = 1
			AND ISNULL(dt.IsDeleted, 0) = 0
			AND ISNULL(dt.IsApproved, 0) = 0 
			AND ISNULL(dt.IsRejected, 0) = 0
	)

	SELECT
		d.*,
		(SELECT REPLACE(t.s.value('.', 'nvarchar(max)'), '&amp;', '&') FROM xmlNewText.nodes('//li[@name = "TextNew"]') AS t(s)) AS TextNew,
		(SELECT REPLACE(t.s.value('.', 'nvarchar(max)'), '&amp;', '&') FROM xmlNewText.nodes('//li[@name = "TitleNew"]') AS t(s)) AS TitleNew,
		(SELECT t.s.value('.', 'nvarchar(max)') FROM xmlNewText.nodes('//li[@name = "NewCategoryId"]') AS t(s)) AS NewCategoryId,
		(SELECT t.s.value('.', 'nvarchar(max)') FROM xmlNewText.nodes('//li[@name = "YearFromNew"]') AS t(s)) AS YearFromNew,
		(SELECT t.s.value('.', 'nvarchar(max)') FROM xmlNewText.nodes('//li[@name = "NewArtistLifeLogTypeId"]') AS t(s)) AS NewArtistLifeLogTypeId,
		(SELECT t.s.value('.', 'nvarchar(max)') FROM xmlNewText.nodes('//li[@name = "NewCity"]') AS t(s)) AS NewCity,
		(SELECT t.s.value('.', 'nvarchar(max)') FROM xmlNewText.nodes('//li[@name = "CreationYearNew"]') AS t(s)) AS CreationYearNew,
		(SELECT t.s.value('.', 'nvarchar(max)') FROM xmlNewText.nodes('//li[@name = "NewTitleFa"]') AS t(s)) AS NewTitleFa,
		(SELECT t.s.value('.', 'nvarchar(max)') FROM xmlNewText.nodes('//li[@name = "MediumNew"]') AS t(s)) AS MediumNew,
		(SELECT t.s.value('.', 'nvarchar(max)') FROM xmlNewText.nodes('//li[@name = "SizeNew"]') AS t(s)) AS SizeNew,
		(SELECT t.s.value('.', 'nvarchar(max)') FROM xmlNewText.nodes('//li[@name = "PictureNew"]') AS t(s)) AS PictureNew,
		(SELECT t.s.value('.', 'nvarchar(max)') FROM xmlNewText.nodes('//li[@name = "CommentNew"]') AS t(s)) AS CommentNew,		
		(SELECT t.s.value('.', 'nvarchar(max)') FROM xmlNewText.nodes('//li[@name = "SourceNew"]') AS t(s)) AS SourceNew,
		(SELECT t.s.value('.', 'nvarchar(max)') FROM xmlNewText.nodes('//li[@name = "NewToCity"]') AS t(s)) AS NewToCity,
		(SELECT t.s.value('.', 'nvarchar(max)') FROM xmlNewText.nodes('//li[@name = "NewDegree"]') AS t(s)) AS NewDegree,
		(SELECT t.s.value('.', 'nvarchar(max)') FROM xmlNewText.nodes('//li[@name = "NewUniversity"]') AS t(s)) AS NewUniversity,
		(SELECT t.s.value('.', 'nvarchar(max)') FROM xmlNewText.nodes('//li[@name = "NewGallery"]') AS t(s)) AS NewGallery,
		(SELECT t.s.value('.', 'nvarchar(max)') FROM xmlNewText.nodes('//li[@name = "NewTitle"]') AS t(s)) AS NewTitle,
		(SELECT t.s.value('.', 'nvarchar(max)') FROM xmlNewText.nodes('//li[@name = "SeriesNew"]') AS t(s)) AS SeriesNew,
		(SELECT t.s.value('.', 'nvarchar(max)') FROM xmlNewText.nodes('//li[@name = "SeriesFaNew"]') AS t(s)) AS SeriesFaNew,
		(SELECT t.s.value('.', 'nvarchar(max)') FROM xmlNewText.nodes('//li[@name = "NameNew"]') AS t(s)) AS NameNew,
		(SELECT t.s.value('.', 'nvarchar(max)') FROM xmlNewText.nodes('//li[@name = "NameFaNew"]') AS t(s)) AS NameFaNew,
		(SELECT t.s.value('.', 'nvarchar(max)') FROM xmlNewText.nodes('//li[@name = "AuthorNew"]') AS t(s)) AS AuthorNew,
		(SELECT t.s.value('.', 'nvarchar(max)') FROM xmlNewText.nodes('//li[@name = "PublicationNew"]') AS t(s)) AS PublicationNew,
		(SELECT t.s.value('.', 'nvarchar(max)') FROM xmlNewText.nodes('//li[@name = "LinkNew"]') AS t(s)) AS LinkNew,
		(SELECT t.s.value('.', 'nvarchar(max)') FROM xmlNewText.nodes('//li[@name = "SeriesDdNew"]') AS t(s)) AS SeriesDdNew,
		(SELECT t.s.value('.', 'nvarchar(max)') FROM xmlNewText.nodes('//li[@name = "ArtistIdNew"]') AS t(s)) AS ArtistIdNew
	INTO #dt_add_artwork
	FROM
		cte
		INNER JOIN DataHistory d WITH (NOLOCK) ON d.Id = cte.Id;

	-- GET EDIT DATA HISTORY ARTWORK BY USER
	SELECT
		dt.FieldId
	INTO #dt_edit_artwork
	FROM
		DataHistory dt WITH (NOLOCK)
	WHERE
		dt.PageId = 27
		AND dt.CollectorId = @CollectorId
		AND ISNULL(dt.IsAdd, 0) = 0
		AND ISNULL(dt.IsCompleted, 0) = 1
		AND ISNULL(dt.IsDeleted, 0) = 0
		AND ISNULL(dt.IsApproved, 0) = 0 
		AND ISNULL(dt.IsRejected, 0) = 0
	GROUP BY dt.FieldId

	-- Select Artwork
	SELECT 
		art.Id,
		art.ArtistId,
		art.Title,
		art.TitleFa,
		art.Series,
		art.SeriesFa,
		-1 as SeriesDd,
		art.Collaboration,
		art.CollaborationFa,
		art.IsCollaborationDisplayOnWebsite,
		CASE
			WHEN (art.CreationYear <> 0 AND art.CreationYear <> -1) THEN
				art.CreationYear
			ELSE
				NULL
		END AS CreationYear,
		CASE
			WHEN (art.CreationYearFa <> 0 AND art.CreationYearFa <> -1 AND art.CreationYearFa <> -622) THEN
				art.CreationYearFa
			ELSE
				NULL
		END AS CreationYearFa,
		art.Picture,
		art.Medium,
		art.MediumFa,
		art.Height,
		art.Width,
		art.SizeUnit,
		art.Category,
		art.IsAuctionRecord,
		art.[Length],
		art.Depth,
		art.ImageHeight,
		art.ImageWidth,
		art.ModifiedDate,
		art.LastStatusDescription,   
		art.LastStatusDescriptionFa,
		(CASE
				WHEN art.VerificationStatus = 2 THEN
					1
				WHEN art.VerificationStatus = 3 THEN
					2
				WHEN art.VerificationStatus = 1 THEN
					3
				ELSE
					4
			END
		) AS VerificationStatus,
		a.FirstName,
		a.LastName,
		a.FirstNameFa,
		a.LastNameFa,
		LTRIM(RTRIM(a.Nickname)) AS NickName,
		(CASE
				WHEN (a.FirstName IS NULL AND a.LastName IS NULL AND a.Nickname IS NOT NULL) THEN
					LTRIM(RTRIM(a.Nickname))
				WHEN (a.FirstName IS NOT NULL AND a.LastName IS NOT NULL AND a.Nickname IS NOT NULL) THEN
					LTRIM(RTRIM(a.FirstName)) + ' ' + LTRIM(RTRIM(a.LastName)) + ' (' + LTRIM(RTRIM(a.Nickname)) + ')'
				ELSE
					LTRIM(RTRIM(a.FirstName)) + ' ' + LTRIM(RTRIM(a.LastName))
			END
		) AS ArtistName,
		(CASE
				WHEN (a.FirstNameFa IS NULL AND a.FirstNameFa IS NULL AND a.NicknameFa IS NOT NULL) THEN
				LTRIM(RTRIM(a.NicknameFa))
				WHEN (a.FirstName IS NOT NULL AND a.LastName IS NOT NULL AND a.Nickname IS NOT NULL) THEN
				LTRIM(RTRIM(a.FirstNameFa)) + ' ' + LTRIM(RTRIM(a.LastNameFa)) + ' (' + LTRIM(RTRIM(a.NicknameFa)) + ')'
				ELSE
				LTRIM(RTRIM(a.FirstNameFa)) + ' ' + LTRIM(RTRIM(a.LastNameFa))
			END
		) AS ArtistNameFa,
		afmp.Id AS ArtworkFromMarketProvenanceId,
		afmp.ToSell,
		afmp.PrivacyId,
		afmp.WebsiteOffer,
		(SELECT 1 FROM #dt_edit_artwork dea WHERE dea.FieldId = art.Id) AS IsWaitingForAdminApproval
		INTO 
			#ArtworkResults
		FROM 
			ArtWork AS art WITH(nolock) 	
			LEFT JOIN Artist AS a WITH(NOLOCK) ON art.ArtistId = a.Id 
			LEFT JOIN ArtistSeries AS ass WITH(NOLOCK) ON art.SeriesId = ass.Id				
			LEFT JOIN Category AS c WITH(NOLOCK) ON  art.Category = c.Id
			INNER JOIN ArtworkFromMarketProvenance AS afmp WITH(nolock) ON art.Id = afmp.ArtworkId
		WHERE   
			(ISNULL(@ArtistId,0) = 0 OR a.Id = @ArtistId) and   
			(ISNULL(@CollectorId,0) = 0 OR afmp.CollectorId = @CollectorId)


	-- SET DATA HISTORY ARTWORK
		SELECT 
			(daa.Id + 1000) AS Id,			
			CASE WHEN ISNULL(daa.ArtistIdNew, '') <> '' THEN (SELECT LTRIM(RTRIM(Value)) FROM dbo.Split(daa.ArtistIdNew, ':') sn WHERE sn.Id = 2) ELSE '' END AS ArtistId,
			CASE WHEN ISNULL(daa.TitleNew, '') <> '' THEN (SELECT LTRIM(RTRIM(Value)) FROM dbo.Split(daa.TitleNew, ':') sn WHERE sn.Id = 2) ELSE '' END AS Title,
			CASE WHEN ISNULL(daa.NewTitleFa, '') <> '' THEN (SELECT LTRIM(RTRIM(Value)) FROM dbo.Split(daa.NewTitleFa, ':') sn WHERE sn.Id = 2) ELSE '' END AS TitleFa,
			CASE WHEN ISNULL(daa.SeriesNew, '') <> '' THEN (SELECT LTRIM(RTRIM(Value)) FROM dbo.Split(daa.SeriesNew, ':') sn WHERE sn.Id = 2) ELSE '' END AS Series,
			CASE WHEN ISNULL(daa.SeriesFaNew, '') <> '' THEN (SELECT LTRIM(RTRIM(Value)) FROM dbo.Split(daa.SeriesFaNew, ':') sn WHERE sn.Id = 2) ELSE '' END AS SeriesFa,
			CASE WHEN ISNULL(daa.SeriesDdNew, '') <> '' THEN (SELECT LTRIM(RTRIM(Value)) FROM dbo.Split(daa.SeriesDdNew, ':') sn WHERE sn.Id = 2) ELSE '' END AS SeriesDd,
			NULL AS Collaboration,
			NULL AS CollaborationFa,
			NULL AS IsCollaborationDisplayOnWebsite,
			CASE WHEN ISNULL(daa.IsPersian, 0) = 0 AND ISNULL(daa.CreationYearNew, '') <> '' THEN (SELECT LTRIM(RTRIM(Value)) FROM dbo.Split(daa.CreationYearNew, ':') sn WHERE sn.Id = 2) ELSE 0 END AS CreationYear,
			CASE WHEN ISNULL(daa.IsPersian, 0) = 1 AND ISNULL(daa.CreationYearNew, '') <> '' THEN (SELECT LTRIM(RTRIM(Value)) FROM dbo.Split(daa.CreationYearNew, ':') sn WHERE sn.Id = 2) ELSE 0 END AS CreationYearFa,
			CASE WHEN ISNULL(daa.PictureNew, '') <> '' 
				THEN (
						SELECT LTRIM(RTRIM(Value)) FROM dbo.Split(REPLACE(REPLACE(PictureNew,'/Content/DarzImages/', ''), 'style=''width', ''), ':') sn WHERE sn.Id = 2
					) 
				ELSE '' END AS Picture,
			CASE WHEN ISNULL(daa.IsPersian, 0) = 0 AND ISNULL(daa.MediumNew, '') <> '' THEN (SELECT LTRIM(RTRIM(Value)) FROM dbo.Split(daa.MediumNew, ':') sn WHERE sn.Id = 2) ELSE '' END AS Medium,
			CASE WHEN ISNULL(daa.IsPersian, 0) = 1 AND ISNULL(daa.MediumNew, '') <> '' THEN (SELECT LTRIM(RTRIM(Value)) FROM dbo.Split(daa.MediumNew, ':') sn WHERE sn.Id = 2) ELSE '' END AS MediumFa,
			CASE WHEN ISNULL(daa.SizeNew, '') <> '' 
				THEN (
						SELECT 
							(SELECT LTRIM(RTRIM(Value)) FROM dbo.Split(LTRIM(RTRIM(Value)), 'x') sn2 WHERE sn2.Id = 1)
						FROM dbo.Split(daa.SizeNew, ':') sn WHERE sn.Id = 2
					) 
			ELSE '0' END AS Height,
			CASE WHEN ISNULL(daa.SizeNew, '') <> '' 
				THEN (
						SELECT 
							(SELECT LTRIM(RTRIM(Value)) FROM dbo.Split(LTRIM(RTRIM(Value)), 'x') sn2 WHERE sn2.Id = 2)
						FROM dbo.Split(daa.SizeNew, ':') sn WHERE sn.Id = 2
					) 
			ELSE '0' END AS Width,
			1 AS SizeUnit,
			CASE WHEN ISNULL(daa.NewCategoryId, '') <> '' THEN (SELECT LTRIM(RTRIM(Value)) FROM dbo.Split(daa.NewCategoryId, ':') sn WHERE sn.Id = 2) ELSE 0 END AS Category,
			0 AS IsAuctionRecord,
			'0' AS [Length],
			CASE WHEN ISNULL(daa.SizeNew, '') <> '' 
				THEN (
						SELECT 
							(SELECT LTRIM(RTRIM(Value)) FROM dbo.Split(LTRIM(RTRIM(Value)), 'x') sn2 WHERE sn2.Id = 3)
						FROM dbo.Split(daa.SizeNew, ':') sn WHERE sn.Id = 2
					) 
			ELSE '0' END AS Depth,
			0 AS ImageHeight,	
			0 AS ImageWidth,
			daa.CreatedDate AS ModifiedDate,
			'' AS LastStatusDescription,
			'' AS LastStatusDescriptionFa,
			1 AS VerificationStatus,
			'' AS FirstName,
			'' AS LastName,
			'' AS FirstNameFa,
			'' AS LastNameFa,			
			'' AS NickName,
		    '' AS ArtistName,
		    '' AS ArtistNameFa,
			0 AS ArtworkFromMarketProvenanceId,
			0 AS ToSell,
			0 AS PrivacyId,
			'' AS WebsiteOffer,
			1 AS IsWaitingForAdminApproval
		INTO 
			#dt_add_artwork_final
		FROM 
			#dt_add_artwork daa;


	-- SELECT ARTWORK	
	SELECT 
		ar.*
	INTO 
			#CombinationCollectorArtwork
	FROM 
	(
		SELECT
			*
		FROM
			#ArtworkResults
		UNION ALL
		SELECT 
			* 
		FROM 
			#dt_add_artwork_final
	) ar

	IF(@sort = 'year_asc')
	BEGIN
			SELECT
				*
			FROM
				#CombinationCollectorArtwork
			ORDER BY
				ISNULL(CreationYear, 10000) ASC OFFSET ((@PageIndex - 1) * @PageSize) ROWS FETCH NEXT @PageSize ROWS ONLY;
	END
	ELSE IF(@sort = 'year_desc')
	BEGIN
			SELECT
				*
			FROM
				#CombinationCollectorArtwork
			ORDER BY
				ISNULL(CreationYear, 0) DESC OFFSET ((@PageIndex - 1) * @PageSize) ROWS FETCH NEXT @PageSize ROWS ONLY;
	END
	ELSE IF(@sort = 'recently_added')
	BEGIN
			SELECT
				*
			FROM					
				#CombinationCollectorArtwork
			ORDER BY
				ModifiedDate DESC OFFSET ((@PageIndex - 1) * @PageSize) ROWS FETCH NEXT @PageSize ROWS ONLY;
	END
	ELSE 
	BEGIN
				
		SELECT 
			ar.*
		FROM 
		#CombinationCollectorArtwork ar
		ORDER BY
			ISNULL(CreationYear, 0) DESC OFFSET ((@PageIndex - 1) * @PageSize) ROWS FETCH NEXT @PageSize ROWS ONLY;
	END    	
END;
