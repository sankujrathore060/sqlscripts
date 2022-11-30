CREATE PROCEDURE [dbo].[ArtworkFromMarket_GeAllArtwork_FilterList_Dropdown]
		@topCategoryId int = 0,
		@artistId int = 0,    
		@subjectCategoryId int = 0,
		@year varchar(50) = '0',    
		@sort varchar(50) = '',
		@MovementId INT = 0,
		@ColorId INT = 0,
		@MediumId INT = 0
AS    
BEGIN    
		SET TRANSACTION ISOLATION LEVEL SNAPSHOT  
		
		-- TOP CATEGORY = 52, 54, 63, 53, 60, 61, 57
		SELECT DISTINCT
			aw.Id,
			a.Id as ArtistId,	
			ISNULL(t.TagId, 0)as TagId,
			ISNULL(aw.CreationYear, 0) as CreationYear,
			ISNULL(aw.CreationYearFa, 0) as CreationYearFa
		INTO #artworkResults
		FROM   
			vw_ArtworkFromMarket aw WITH(NOLOCK)
			INNER JOIN Artist as a WITH(NOLOCK) on aw.ArtistId = a.Id        			
			LEFT JOIN TagArtwork awt with(nolock) on awt.ArtworkId = aw.Id
			LEFT JOIN Tags t with(nolock) on awt.TagId = t.TagId		
		WHERE
			(
				(@topCategoryId = 0)
				OR
				(@topCategoryId > 0 AND t.TagId = @topCategoryId)
				OR
				(@topCategoryId = -1 AND t.TagId IN (51, 55, 56, 57, 58, 59, 60, 62, 63, 64, 65, 66, 67, 68))
				OR 
				(@topCategoryId = -2 AND t.TagId NOT IN (52, 54, 63, 53, 60, 61, 57))
			)			
			AND (@artistId = 0 OR aw.ArtistId = @artistId)
			AND (
					@year = '0'  OR aw.CreationYear between CONVERT(int,(SUBSTRING(@year,1,4))) and CONVERT(int,SUBSTRING(@year,6,9))    
					OR	@year = '0'  OR aw.CreationYearFa between CONVERT(int,(SUBSTRING(@year,1,4))) and CONVERT(int,SUBSTRING(@year,6,9))
				)
			AND aw.VerificationStatus = 2 and a.VerificationStatus = 2
    
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
						#artworkResults	aw
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
				
				-- SELECT Id FROM #deleteArtworkIds
				DELETE FROM #artworkResults WHERE Id IN (SELECT Id FROM #deleteArtworkIds);
				
				DROP TABLE #deleteArtworkIds;
		END

		-- -- WHEN SUBJECT CATEGORY SELECTED
		-- SELECT DISTINCT
		-- 	aw.*
		-- INTO #artworkResults_new
		-- FROM #artworkResults aw
		-- 	LEFT JOIN TagArtwork awt with(nolock) on awt.ArtworkId = aw.Id
		-- 	LEFT JOIN Tags t with(nolock) on awt.TagId = t.TagId
		-- WHERE
		-- 	(@subjectCategoryId = 0 OR t.TagId = @subjectCategoryId)

		DECLARE @selected_tags VARCHAR(100) = '',
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

		SELECT DISTINCT
			aw.*
		INTO #artworkResults_new
		FROM #artworkResults aw					
		WHERE
			(	
				@selected_tags = '' 
				OR 
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
			)
		
		DECLARE @RecordCount INT    
		SELECT @RecordCount = COUNT(*)
		FROM   #artworkResults_new
     
		-- YEAR 
		;WITH cte AS (  
			SELECT ROW_NUMBER() OVER(ORDER BY [year]) AS row,  
				*  
			FROM   
			(  
				SELECT DISTINCT   
					SUBSTRING(CONVERT(VARCHAR(10), CreationYear), 1, 3) +   
					'0' AS [year]
				FROM 
					#artworkResults_new aw 
				WHERE  
					ISNULL(aw.CreationYear, 0) > 0
				GROUP BY 
					aw.CreationYear
			) AS tbl  
		)  
		SELECT 
			ISNULL(c.year, '') + '-' + cast((cast(c.year as int) + 9) as nvarchar) AS YEAR  
		FROM   
			cte c  
			LEFT JOIN cte c1 ON  (c.row + 1) = c1.row
		WHERE
			c.year > 1700
		ORDER BY c.year DESC 

		-- YEAR FA
		;WITH cte AS (  
			SELECT 
				ROW_NUMBER() OVER(ORDER BY [yearFa]) AS row,
				*
			FROM   
			(  
				SELECT DISTINCT   
					(case when (len(CreationYearFa) < 4 ) then
					'0'+(SUBSTRING(CONVERT(VARCHAR(10), CreationYearFa), 1, 2) +'0')
					ELSE
					(SUBSTRING(CONVERT(VARCHAR(10), CreationYearFa), 1, 3) + '0')
					END 
					) AS [YearFa]
				FROM 
					#artworkResults_new aw 
				WHERE  
					ISNULL(aw.CreationYearFa, 0) > 0
				GROUP BY 
					aw.CreationYearFa
			) AS tbl  
		)  
		SELECT 
			ISNULL(c.YearFa, '') + '-' + 
			(case when (len(cast(c.YearFa as int)) < 4 ) then '0' +cast((cast(c.YearFa as int) + 9) as nvarchar)
				ELSE cast((cast(c.YearFa as int) + 9) as nvarchar) END)AS YearFa
		FROM   
			cte c
			LEFT JOIN cte c1 ON  (c.row + 1) = c1.row
		WHERE
			c.YearFa < 2000
		ORDER BY c.YearFa DESC

		-- TAG LIST
		-- SELECT aw.TagId as TagIds FROM #artworkResults_new aw GROUP BY aw.TagId
		SELECT 
			ISNULL(t.TagId, 0) as TagId
			-- t.TagName
		FROM 
			#artworkResults_new aw 
			LEFT JOIN TagArtwork awt with(nolock) on awt.ArtworkId = aw.Id
			LEFT JOIN Tags t with(nolock) on awt.TagId = t.TagId
		WHERE
			ISNULL(t.TagId, 0) > 0
		GROUP BY 
			t.TagId -- , t.TagName
		
		-- ARTIST LIST
		SELECT 
			aw.ArtistId as Id,
			LTRIM(RTRIM(a.NickName)) as NickName,    
			LTRIM(RTRIM(a.FirstName)) as FirstName,    
			LTRIM(RTRIM(a.LastName)) as LastName,    
			LTRIM(RTRIM(a.NicknameFa)) as NicknameFa,    
			LTRIM(RTRIM(a.FirstNameFa)) as FirstNameFa,    
			LTRIM(RTRIM(a.LastNameFa)) as LastNameFa,
			(CASE     
			WHEN (FirstName is null and LastName is null and Nickname is not null)     
			THEN LTRIM(RTRIM(Nickname))     
			ELSE LTRIM(RTRIM(FirstName)) +' '+ LTRIM(RTRIM(LastName)) END) as ArtistName,
			(CASE     
			WHEN (FirstNameFa is null and FirstNameFa is null and NicknameFa is not null)     
			THEN LTRIM(RTRIM(NicknameFa))     
			ELSE LTRIM(RTRIM(FirstNameFa)) +' '+ LTRIM(RTRIM(LastNameFa)) END) as ArtistNameFa
		FROM 
			#artworkResults_new aw 
			INNER JOIN Artist as a WITH(NOLOCK) on aw.ArtistId = a.Id        
		GROUP BY 
			aw.ArtistId, a.NickName, a.FirstName, a.LastName, a.NicknameFa, a.FirstNameFa, a.LastNameFa

		DROP TABLE #artworkResults
		DROP TABLE #artworkResults_new
END