
-- proc_GetAllArtWorkByArtist_Profile @firstName = 'Shirin', @lastName = 'Neshat'
ALTER PROCEDURE [dbo].[proc_GetAllArtWorkByArtist_Profile]
    @UserId UNIQUEIDENTIFIER = NULL,
    @nickname NVARCHAR(250) = NULL,
    @firstName NVARCHAR(500) = NULL,
    @lastName NVARCHAR(500) = NULL,
    @artworkId INT = 0,
    @pageIndex INT = 1,
    @PageSize INT = 20,
	@sort varchar(max) = '0'
AS
BEGIN
		SET TRANSACTION ISOLATION LEVEL SNAPSHOT;
		DECLARE @ArtistId INT;

		SELECT 
			@ArtistId = a.Id
		FROM 
			dbo.Artist a
		WHERE
			((@firstName IS NOT NULL AND @lastName IS NOT NULL)
			AND REPLACE(a.FirstName, ' ', '') = @firstName
			AND REPLACE(a.LastName, ' ', '') = @lastName
        )
        OR ((@nickname IS NOT NULL AND @firstName IS NULL AND @lastName IS NULL) AND REPLACE(a.Nickname,' ','') = @nickname);
		
		-- GET ADD DATA HISTORY ARTWORK BY USER
		;WITH cte AS 
		(
			SELECT
				dt.Id,
				CAST(REPLACE(REPLACE(dt.NewText, '<img src=', ''), '&', '&amp;') AS XML) AS xmlNewText
			FROM
				DataHistory dt WITH (NOLOCK)
			WHERE
				dt.PageId IN (3,8,9,10,11)
				AND dt.ArtistId = @ArtistId
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
			(SELECT t.s.value('.', 'nvarchar(max)') FROM xmlNewText.nodes('//li[@name = "SeriesDdNew"]') AS t(s)) AS SeriesDdNew
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
			dt.PageId IN (3,8,9,10,11)
			AND dt.ArtistId = @ArtistId
			AND ISNULL(dt.IsAdd, 0) = 0
			AND ISNULL(dt.IsCompleted, 0) = 1
			AND ISNULL(dt.IsDeleted, 0) = 0
			AND ISNULL(dt.IsApproved, 0) = 0 
			AND ISNULL(dt.IsRejected, 0) = 0
		GROUP BY dt.FieldId

		-- GET COLLABORATION ARTWORK
		SELECT 
			Id 
		INTO #CollaborationArtwork
		FROM 
			vw_Artwork 
		WHERE 
			ISNULL(IsCollaborationDisplayOnWebsite, 0) = 1 
			AND @ArtistId IN (SELECT value FROM dbo.Split(CollaborationIds, ','));

		-- GET ARTWORK DATA
        SELECT           
            aw.Id,
            aw.ArtistId,
            aw.Title,
            aw.TitleFa,
            aw.Series,
            aw.SeriesFa,
			-1 as SeriesDdNew,
            aw.Collaboration,
            aw.CollaborationFa,
			aw.IsCollaborationDisplayOnWebsite,
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
            aw.Medium,
			aw.MediumFa,
            aw.Height,
            aw.Width,
			aw.SizeUnit,
            aw.Category,
            aw.IsAuctionRecord,
            aw.[Length],
            aw.Depth,
            aw.ImageHeight,
            aw.ImageWidth,
            aw.ModifiedDate,
			aw.LastStatusDescription,   
			aw.LastStatusDescriptionFa,
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
            a.FirstName,
            a.LastName,
            a.FirstNameFa,
            a.LastNameFa,
            f.Id AS FavouriteId,
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
			a.VerificationStatus AS Artist_VerificationStatus,
			(SELECT 1 FROM #dt_edit_artwork dea WHERE dea.FieldId = aw.Id) AS IsWaitingForAdminApproval
		INTO
            #ArtworkResults
        FROM
			vw_Artwork AS aw WITH(NOLOCK)
            INNER JOIN Artist AS a WITH(NOLOCK) ON aw.ArtistId = a.Id
			LEFT JOIN Favourites f WITH(NOLOCK) ON aw.Id = f.MainId AND f.UserId = @UserId
			LEFT JOIN #CollaborationArtwork ca ON aw.Id = ca.Id
        WHERE
            a.VerificationStatus = 2
            AND aw.VerificationStatus = 2
            AND ((aw.Id IN (SELECT Id FROM #CollaborationArtwork)) OR a.Id = @ArtistId);
		
		-- SET DATA HISTORY ARTWORK
		SELECT 
			(daa.Id + 1000) AS Id,
			@ArtistId AS ArtistId,
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
			a.FirstName,
            a.LastName,
            a.FirstNameFa,
            a.LastNameFa,
            NULL AS FavouriteId,
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
			a.VerificationStatus AS Artist_VerificationStatus,
			1 AS IsWaitingForAdminApproval
		INTO 
			#dt_add_artwork_final
		FROM 
			#dt_add_artwork daa
			INNER JOIN Artist AS a WITH(NOLOCK) ON daa.ArtistId = a.Id;
		
		-- SELECT ARTWORK		
		SELECT 
			ar.*
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
		ORDER BY
			ISNULL(CreationYear, 0) DESC OFFSET ((@PageIndex - 1) * @PageSize) ROWS FETCH NEXT @PageSize ROWS ONLY;
END;

