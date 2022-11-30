--Exec [dbo].[proc_GetAllArtWorkByArtistIdLazyLoading]
--    @artistId = 594,
--    @pageIndex = 1,
--    @PageArtworkIDs = '36682,36685,36678,36680,36675,36681,36683,36684,36686,36676,36677,36679,1439,1444,1446,36615,36613,36614,36612,36611,1449,1448,1454,1452,1456,1451,36607,36608,20529,22238,36039,36610,20535,20531,20530,20528,'


ALTER PROCEDURE [dbo].[proc_GetAllArtWorkByArtistIdLazyLoading]
    @UserId UNIQUEIDENTIFIER = NULL,
    @artistId INT = 0,
    @artworkId INT = 0,
    @alphabet VARCHAR(5) = NULL,
    @PageIndex INT = 1,
    @categoryId INT = 0,
    @year VARCHAR(50) = '0',
    @PageSize INT = 20,
    @sort VARCHAR(MAX) = '0',
    @PageArtworkIDs VARCHAR(MAX) = NULL
AS
BEGIN 
			SET TRANSACTION ISOLATION LEVEL SNAPSHOT;
			SET NOCOUNT ON;

			CREATE TABLE #artworkResults_PageIds
			(
				PageId_ArtworkId INT
			)

			SELECT
				Id
			INTO
				#CollaborationArtwork
			FROM
				vw_Artwork
			WHERE
				ISNULL(IsCollaborationDisplayOnWebsite, 0) = 1
				AND @artistId IN (SELECT Value FROM dbo.Split(CollaborationIds, ',') );

			DECLARE @sql_script NVARCHAR(MAX);
			SET @sql_script  = '
					SELECT 
						ROW_NUMBER() OVER (ORDER BY
												IIF(aw.IsFeatured IS NULL OR aw.IsFeatured = 0, 1, 0) ASC,
												IIF(aw.CreationYear IS NULL OR aw.CreationYear = 0 OR aw.CreationYear = -1, 1, 0) ASC,
												aw.ModifiedDate DESC
											) AS RowNumber,
					   
						aw.Id,
						aw.Title,
						aw.TitleFa,
						aw.Collaboration,
						aw.IsCollaborationDisplayOnWebsite,
						aw.IsAuctionRecord,
						aw.Series,
						aw.SeriesFa,
						aw.CollaborationFa,
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
						aw.ImageWidth,
						aw.ImageHeight,
						aw.Medium,
						aw.MediumFa,						
						'''' AS Size,
						aw.rowguid,
						aw.ArtistId,
						aw.ModifiedDate,
						aw.LastStatusDescription,
						aw.LastStatusDescriptionFa,
						aw.Category,

						-- f.Id AS FavouriteId,
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
						(CASE
								WHEN (FirstName IS NULL AND LastName IS NULL AND Nickname IS NOT NULL) THEN
									LTRIM(RTRIM(Nickname))
								ELSE
									LTRIM(RTRIM(FirstName)) + '' '' + LTRIM(RTRIM(LastName))
							END
						) AS ArtistName,
						(CASE
								WHEN (FirstNameFa IS NULL AND FirstNameFa IS NULL AND NicknameFa IS NOT NULL) THEN
									LTRIM(RTRIM(NicknameFa))
								ELSE
									LTRIM(RTRIM(FirstNameFa)) + '' '' + LTRIM(RTRIM(LastNameFa))
							END
						) AS ArtistNameFa,
						a.VerificationStatus AS Artist_VerificationStatus
					FROM
						vw_Artwork AS aw WITH (NOLOCK)
						INNER JOIN Artist AS a WITH (NOLOCK) ON aw.ArtistId = a.Id						
						LEFT JOIN #CollaborationArtwork ca ON aw.Id = ca.Id
					WHERE
						aw.VerificationStatus = 2 AND a.VerificationStatus = 2
						--AND ISNULL(aw.IsDuplicate, 0) = 0						
					';

			IF(@categoryId > 0)
			BEGIN
					SET @sql_script = @sql_script + ' AND aw.Category = CONVERT(INT, (' + @categoryId + '))';
			END
			
			IF(@artistId > 0)
			BEGIN
					SET @sql_script = @sql_script + ' AND (aw.ArtistId = CONVERT(INT, (' + CONVERT(VARCHAR(20), @artistId) + ')) 
																OR (aw.Id IN (SELECT Id FROM #CollaborationArtwork)))';
			END

			IF(@year <> '0')
			BEGIN
					SET @sql_script = @sql_script + ' AND 
								(
									aw.CreationYear BETWEEN CONVERT(INT, ('+ SUBSTRING(@year, 1, 4) + ')) AND CONVERT(INT, '+ SUBSTRING(@year, 6, 9) + ')
									OR aw.CreationYearFa BETWEEN CONVERT(INT, ('+ SUBSTRING(@year, 1, 4) + ')) AND CONVERT(INT, '+ SUBSTRING(@year, 6, 9) + ')
								) ';
			END

			IF(ISNULL(@PageArtworkIDs, '') <> '' AND  @sort <> '0')
			BEGIN
					INSERT INTO #artworkResults_PageIds(PageId_ArtworkId)
							(SELECT VALUE FROM Split(@pageArtworkIDs, ','))

					SET @sql_script = @sql_script + ' AND aw.Id NOT IN (SELECT PageId_ArtworkId FROM #artworkResults_PageIds) ';

			END

			IF(@sort = 'year_asc')
			BEGIN
					SET @sql_script = @sql_script + ' ORDER BY ISNULL(CreationYear, 100000) ASC';
					SET @PageIndex = 1
			END
			ELSE IF(@sort = 'year_desc')
			BEGIN
					SET @sql_script = @sql_script + ' ORDER BY ISNULL(aw.CreationYear, 0) DESC';
					SET @PageIndex = 1
			END
			ELSE IF(@sort = 'recently_added')
			BEGIN
					SET @sql_script = @sql_script + ' ORDER BY aw.ModifiedDate DESC, ISNULL(aw.CreationYear, 0) DESC';
					SET @PageIndex = 1
			END
			ELSE 
			BEGIN
					SET @sql_script = @sql_script + ' ORDER BY ISNULL(aw.CreationYear, 0) DESC';
			END
			
				
     		SET @sql_script = @sql_script + ' OFFSET (('+ CONVERT(VARCHAR(20), (@PageIndex - 1)) + ') * '+ CONVERT(VARCHAR(20), @PageSize) + ') 
			 										ROWS FETCH NEXT ' + CONVERT(VARCHAR(20), @PageSize) + ' ROWS ONLY';

			-- PRINT @sql_script;
			EXEC (@sql_script);

			DROP TABLE #artworkResults_PageIds;
END;

