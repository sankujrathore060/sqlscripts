CREATE PROCEDURE [dbo].[ArtworkFromMarket_GetAll_FilterList]
		@userId uniqueidentifier = null,    
		@pageIndex int = 1,    
		@topCategoryId int = 0,
		@artistId int = 0,    
		@subjectCategoryId int = 0,		 
		@year varchar(50) = '0',    
		@sort varchar(50) = '',
		@PageSize INT = 20,
		@PageArtworkIDs varchar(max) = NULL,
		@MovementId INT = 0,
		@ColorId INT = 0,
		@MediumId INT = 0
AS    
BEGIN    
		SET TRANSACTION ISOLATION LEVEL SNAPSHOT;
		
		-- TOP CATEGORY = 52, 54, 63, 53, 60, 61, 57
		-- TO BE DISPLAY IN OTHER CATEGORY (-1) = 51, 55, 56. 57, 58, 59, 60, 62, 63, 64, 65, 66, 67, 68
		
		CREATE TABLE #artworkResults_PageIds
		(
			PageId_ArtworkId INT
		)

		IF(ISNULL(@PageArtworkIDs, '') <> '')
		BEGIN
				INSERT INTO #artworkResults_PageIds(PageId_ArtworkId)
						(SELECT VALUE FROM Split(@pageArtworkIDs, ','))
		END
		
		-- REMOVE RECORDs MAIN CATEGORY RECORDs
		IF(@topCategoryId = -1 OR @topCategoryId = -2)
		BEGIN
				;WITH cte as
				(
					SELECT 
						REPLACE(
							STUFF(
								(SELECT
									',' + CONVERT(VARCHAR(20), awt.TagId)
									FROM TagArtwork awt
									WHERE awt.ArtworkId = aw.Id
									FOR XML PATH(''), TYPE
								).value('.','varchar(max)')
								,1,1, ','
							), 
						',,', ',') + ',' AS TagValues, 
						aw.Id
					FROM 
						dbo.vw_ArtworkFromMarket	aw
				)
				SELECT Id INTO #deleteArtworkIds FROM cte 
					WHERE  -- 52, 54, 63, 53, 60, 61, 57
						TagValues LIKE '%,52,%' 
						OR TagValues LIKE '%,54,%' 
						OR TagValues LIKE '%,63,%'
						OR TagValues LIKE '%,53,%'
						OR TagValues LIKE '%,60,%'
						OR TagValues LIKE '%,61,%'
						OR TagValues LIKE '%,57,%';
				
				INSERT INTO #artworkResults_PageIds(PageId_ArtworkId)
						(SELECT Id FROM #deleteArtworkIds);
				
				DROP TABLE #deleteArtworkIds;
		END	
		
		CREATE TABLE #artworkResults_before
		(
			beforeArtworkId INT
		)

		-- SELECT RECORDs BASED ON FILTER
		IF(@subjectCategoryId > 0 OR @MovementId > 0 OR @ColorId > 0 OR @MediumId > 0)
		BEGIN
				DECLARE @selected_tags VARCHAR(100),
						@how_many_filter INT = 0;

				IF(@subjectCategoryId > 0)
				BEGIN
						SET @selected_tags = CAST(@subjectCategoryId AS VARCHAR(10));
						SET @how_many_filter = 1;
				END

				IF(@MovementId > 0 AND @selected_tags <> '')
				BEGIN
						SET @selected_tags = @selected_tags + ',' + CAST(@MovementId AS VARCHAR(10));
						SET @how_many_filter = @how_many_filter + 1;
				END
				ELSE IF(@MovementId > 0)
				BEGIN
						SET @selected_tags = CAST(@MovementId AS VARCHAR(10));
						SET @how_many_filter = 1;
				END

				IF(@ColorId > 0 AND @selected_tags <> '')
				BEGIN
						SET @selected_tags = @selected_tags + ',' + CAST(@ColorId AS VARCHAR(10));
						SET @how_many_filter = @how_many_filter + 1;
				END
				ELSE IF(@ColorId > 0)
				BEGIN
						SET @selected_tags = CAST(@ColorId AS VARCHAR(10));
						SET @how_many_filter = 1;
				END

				IF(@MediumId > 0 AND @selected_tags <> '')
				BEGIN
						SET @selected_tags = @selected_tags + ',' + CAST(@MediumId AS VARCHAR(10));
						SET @how_many_filter = @how_many_filter + 1;
				END
				ELSE IF(@MediumId > 0)
				BEGIN
						SET @selected_tags = CAST(@MediumId AS VARCHAR(10));
						SET @how_many_filter = 1;
				END

				INSERT INTO #artworkResults_before(beforeArtworkId)
				SELECT DISTINCT
					aw.Id AS beforeArtworkId
				FROM dbo.vw_ArtworkFromMarket aw
				WHERE
					Id IN 
					(
						SELECT
							awt.ArtworkId
						FROM
							TagArtwork awt WITH (NOLOCK)
						WHERE
							TagId IN (SELECT Value FROM dbo.Split(@selected_tags, ','))
						GROUP BY awt.ArtworkId
						HAVING COUNT(awt.ArtworkId) > (@how_many_filter - 1)
					)
		END

		-- SELECT RECORDs BASED ON TOP CATEGORY FILTER
		IF((SELECT COUNT(*) FROM #artworkResults_before) > 0 AND (@topCategoryId > 0 OR @topCategoryId = -1 OR @topCategoryId = -2))
		BEGIN
				SELECT DISTINCT
					aw.Id AS beforeArtworkId
				INTO #artworkResults_before_2
				FROM dbo.vw_ArtworkFromMarket aw
					INNER JOIN #artworkResults_before tmp_awt ON aw.Id = tmp_awt.beforeArtworkId
					LEFT JOIN TagArtwork awt with(nolock) on awt.ArtworkId = aw.Id
					LEFT JOIN Tags t with(nolock) on awt.TagId = t.TagId	
				WHERE
					(@topCategoryId > 0 AND t.TagId = @topCategoryId)
					OR
					(@topCategoryId = -1 AND t.TagId IN (51, 55, 56, 57, 58, 59, 60, 62, 63, 64, 65, 66, 67, 68))
					OR
					(@topCategoryId = -2 AND t.TagId NOT IN (52, 54, 63, 53, 60, 61, 57))
				GROUP BY aw.Id;

				-- REMOVE AND INSERT IT AGAIN FOR SOME TOP CATEGORY RECORDs
				TRUNCATE TABLE #artworkResults_before;
				INSERT INTO #artworkResults_before(beforeArtworkId)
					SELECT beforeArtworkId FROM #artworkResults_before_2;

				DROP TABLE #artworkResults_before_2;
		END
		ELSE		
		BEGIN IF(@topCategoryId > 0 OR @topCategoryId = -1 OR @topCategoryId = -2)
				
				INSERT INTO #artworkResults_before(beforeArtworkId)
				SELECT DISTINCT
					aw.Id AS beforeArtworkId				
				FROM dbo.vw_ArtworkFromMarket aw					
					LEFT JOIN TagArtwork awt with(nolock) on awt.ArtworkId = aw.Id
					LEFT JOIN Tags t with(nolock) on awt.TagId = t.TagId	
				WHERE
					(@topCategoryId > 0 AND t.TagId = @topCategoryId)
					OR
					(@topCategoryId = -1 AND t.TagId IN (51, 55, 56, 57, 58, 59, 60, 62, 63, 64, 65, 66, 67, 68))
					OR 
					(@topCategoryId = -2 AND t.TagId NOT IN (52, 54, 63, 53, 60, 61, 57))
				GROUP BY aw.Id;
		END
		
		DECLARE @sql_script NVARCHAR(MAX);
		SET @sql_script  = '
					SELECT TOP 20
						ROW_NUMBER() OVER(PARTITION BY aw.ArtistId ORDER BY IIF(aw.CreationYear IS NULL or aw.CreationYear = 0 or aw.CreationYear = -1,1, 0) ASC, aw.Id ASC, aw.ModifiedDate DESC) AS RowNumber,
						aw.Id,    
						aw.ArtistId,    
						CASE WHEN (aw.CreationYear <> 0 and aw.CreationYear <> -1)    
							THEN aw.CreationYear    
						ELSE 
							NUll    
						END AS CreationYear,
						CASE WHEN (aw.CreationYear <> 0 and aw.CreationYear <> -1)    
							THEN aw.CreationYear    
						ELSE 
							100000
						END AS CreationYear_SortAsc,
						CASE WHEN (aw.CreationYearFa <> 0 and aw.CreationYearFa <> -1 and aw.CreationYearFa <> -622)    
							THEN aw.CreationYearFa    
						ELSE 
							NUll    
						END AS CreationYearFa,    
						aw.Title,    
						aw.TitleFa,    
						aw.Category,    
						aw.Medium,    
						aw.MediumFa,    
						aw.Collaboration,    
						aw.CollaborationFa,   
						aw.IsCollaborationDisplayOnWebsite, 
						aw.IsAuctionRecord,    
						aw.Series,    
						aw.SeriesFa,    
						aw.Height,
						aw.Width,
						aw.depth,
						aw.Length,
						aw.SizeUnit,					
						aw.Picture,    
						aw.ImageHeight,    
						aw.ImageWidth,    
						-- f.Id as FavouriteId,    
						aw.ModifiedDate,    
						aw.LastStatusDescription,   
						aw.LastStatusDescriptionFa,   
						(CASE WHEN aw.VerificationStatus = 2    
						THEN 1    
						WHEN aw.VerificationStatus = 3    
						THEN 2    
						WHEN aw.VerificationStatus = 1    
						THEN 3    
						ELSE 4 END) as VerificationStatus,    
						LTRIM(RTRIM(a.NickName)) as NickName,    
						LTRIM(RTRIM(a.FirstName)) as FirstName,    
						LTRIM(RTRIM(a.LastName)) as LastName,    
						(CASE     
						WHEN (FirstName is null and LastName is null and Nickname is not null)     
						THEN LTRIM(RTRIM(Nickname))     
						ELSE LTRIM(RTRIM(FirstName)) + '' '' + LTRIM(RTRIM(LastName)) END) as ArtistName,
						(CASE     
						WHEN (FirstNameFa is null and FirstNameFa is null and NicknameFa is not null)     
						THEN LTRIM(RTRIM(NicknameFa))     
						ELSE LTRIM(RTRIM(FirstNameFa)) + '' '' + LTRIM(RTRIM(LastNameFa)) END) as ArtistNameFa,
						a.VerificationStatus AS Artist_VerificationStatus,
						aw.VerificationStatus,
						-- gaa.GalleryId AS GalleryId
						aw.ArtworkEdition,
						aw.ArtworkEditionFa
					FROM   
						vw_ArtworkFromMarket aw WITH(NOLOCK)
						INNER JOIN Artist as a WITH(NOLOCK) on aw.ArtistId = a.Id
					WHERE  
						aw.VerificationStatus = 2 and a.VerificationStatus = 2
			';    
		
		IF(@artistId > 0)
		BEGIN
				SET @sql_script = @sql_script + ' AND aw.ArtistId = CONVERT(INT, (' + CONVERT(VARCHAR(20), @artistId) + ')) ';
		END

		IF(@year <> '0')
		BEGIN
				SET @sql_script = @sql_script + ' AND 
							(
								aw.CreationYear BETWEEN CONVERT(INT, ('+ SUBSTRING(@year, 1, 4) + ')) AND CONVERT(INT, '+ SUBSTRING(@year, 6, 9) + ')
								OR aw.CreationYearFa BETWEEN CONVERT(INT, ('+ SUBSTRING(@year, 1, 4) + ')) AND CONVERT(INT, '+ SUBSTRING(@year, 6, 9) + ')
							) ';
		END

		IF((SELECT COUNT(*) FROM #artworkResults_before) > 0)
		BEGIN
				SET @sql_script = @sql_script + ' AND aw.Id IN (SELECT beforeArtworkId FROM #artworkResults_before) ';
		END

		IF((SELECT COUNT(*) FROM #artworkResults_PageIds) > 0)
		BEGIN
				SET @sql_script = @sql_script + ' AND aw.Id NOT IN (SELECT PageId_ArtworkId FROM #artworkResults_PageIds) ';
		END

		IF(@sort = 'year_asc')
		BEGIN
				SET @sql_script = @sql_script + ' ORDER BY ISNULL(CreationYear, 100000) ASC';
		END
		ELSE IF(@sort = 'year_desc')
		BEGIN
				SET @sql_script = @sql_script + ' ORDER BY ISNULL(aw.CreationYear, 0) DESC';
		END
		ELSE IF(@sort = 'recently_added')
		BEGIN
				SET @sql_script = @sql_script + ' ORDER BY aw.ModifiedDate DESC, ISNULL(aw.CreationYear, 0) DESC';
		END
		ELSE 
		BEGIN
				SET @sql_script = @sql_script + ' ORDER BY NEWID() ASC, RowNumber, aw.ModifiedDate DESC, ISNULL(aw.CreationYear, 0) DESC, aw.VerificationStatus';
		END

		PRINT @sql_script;
		EXEC (@sql_script);

		-- DROP TABLE #artworkResults;
		DROP TABLE #artworkResults_before;
		DROP TABLE #artworkResults_PageIds;
END;