--Exec [dbo].[proc_GetAllArtWorkByArtistId]
--      @firstName  = 'milad',
--    @lastName  = 'mousavi'
---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--sp_helptext [proc_GetAllArtWorkByArtistId]
ALTER PROCEDURE [dbo].[proc_GetAllArtWorkByArtistId]
    @UserId UNIQUEIDENTIFIER = NULL,
    @nickname NVARCHAR(250) = NULL,
    @firstName NVARCHAR(500) = NULL,
    @lastName NVARCHAR(500) = NULL,
    @artworkId INT = 0,
    @pageIndex INT = 1,
    @PageSize INT = 20,
	@order VARCHAR(50) = NULL
AS
BEGIN
    SET TRANSACTION ISOLATION LEVEL SNAPSHOT;

    BEGIN
		DECLARE @ArtistId INT;

		SELECT 
			@ArtistId = a.Id
		FROM 
			dbo.Artist a WITH(NOLOCK)
		WHERE
			((@firstName IS NOT NULL AND @lastName IS NOT NULL)
			AND REPLACE(a.FirstName, ' ', '') = @firstName
			AND REPLACE(a.LastName, ' ', '') = @lastName
        )
        OR ((@nickname IS NOT NULL AND @firstName IS NULL AND @lastName IS NULL) AND REPLACE(a.Nickname,' ','') = @nickname);

		SELECT 
			Id INTO #CollaborationArtwork 
		FROM 
			vw_Artwork 
		WHERE 
			ISNULL(IsCollaborationDisplayOnWebsite, 0) = 1 
			AND @ArtistId IN (SELECT value FROM dbo.Split(CollaborationIds, ','));

        SELECT
            ROW_NUMBER() OVER (
				-- Condition: When Creation Year is null show them last in list, When IsFeatured it will always first  
				ORDER BY
					IIF(aw.IsFeatured IS NULL OR aw.IsFeatured = 0, 1, 0) ASC,
					IIF(aw.CreationYear IS NULL OR aw.CreationYear = 0 OR aw.CreationYear = -1, 1, 0) ASC,
					aw.ModifiedDate DESC
            ) AS RowNumber,
            aw.Id,
            aw.ArtistId,
            aw.Title,
            aw.TitleFa,
            aw.Series,
            aw.SeriesFa,
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
            -- f.Id AS FavouriteId,
            LTRIM(RTRIM(a.Nickname)) AS NickName,
            (CASE
				WHEN (a.FirstName IS NULL AND a.LastName IS NULL AND a.Nickname IS NOT NULL ) THEN
					LTRIM(RTRIM(a.Nickname))			 
				WHEN (a.FirstName IS NOT NULL AND a.LastName IS NOT NULL AND a.Nickname IS NOT NULL AND (a.IsNickNameBefore IS NOT NULL AND a.IsNickNameBefore > 0)) THEN
					LTRIM(RTRIM(a.Nickname)) + ' (' + LTRIM(RTRIM(a.FirstName)) + ' ' + LTRIM(RTRIM(a.LastName)) + ')'				  
				WHEN (a.FirstName IS NOT NULL AND a.LastName IS NOT NULL AND a.Nickname IS NOT NULL AND (a.IsNickNameBefore IS NULL OR a.IsNickNameBefore = 0)) THEN
					LTRIM(RTRIM(a.FirstName)) + ' ' + LTRIM(RTRIM(a.LastName)) + ' (' + LTRIM(RTRIM(a.Nickname)) + ')'
				ELSE
					LTRIM(RTRIM(a.FirstName)) + ' ' + LTRIM(RTRIM(a.LastName))
			 END
			) AS ArtistName,
            (CASE
             WHEN (a.FirstNameFa IS NULL AND a.FirstNameFa IS NULL AND a.NicknameFa IS NOT NULL) THEN
					LTRIM(RTRIM(a.NicknameFa))
			 WHEN (a.FirstNameFa IS NOT NULL AND a.LastNameFa IS NOT NULL AND a.NicknameFa IS NOT NULL AND (a.IsNickNameBefore IS NOT NULL AND a.IsNickNameBefore > 0)) THEN
                  LTRIM(RTRIM(a.NicknameFa)) + ' (' + LTRIM(RTRIM(a.FirstNameFa)) + ' ' + LTRIM(RTRIM(a.LastNameFa)) +')' 
             WHEN (a.FirstNameFa IS NOT NULL AND a.LastNameFa IS NOT NULL AND a.NicknameFa IS NOT NULL AND (a.IsNickNameBefore IS NULL OR a.IsNickNameBefore = 0)) THEN
                 LTRIM(RTRIM(a.FirstNameFa)) + ' ' + LTRIM(RTRIM(a.LastNameFa)) + ' (' + LTRIM(RTRIM(a.NicknameFa)) + ')'
             ELSE
                 LTRIM(RTRIM(a.FirstNameFa)) + ' ' + LTRIM(RTRIM(a.LastNameFa))
			 END
			) AS ArtistNameFa,
			a.VerificationStatus AS Artist_VerificationStatus
		INTO
            #ArtworkResults
        FROM
			vw_Artwork AS aw WITH(NOLOCK)
            INNER JOIN Artist AS a WITH(NOLOCK) ON aw.ArtistId = a.Id
			-- LEFT JOIN Favourites f WITH(NOLOCK) ON aw.Id = f.MainId AND f.UserId = @UserId
			LEFT JOIN #CollaborationArtwork ca ON aw.Id = ca.Id			
        WHERE
            a.VerificationStatus = 2
            AND aw.VerificationStatus = 2
			And (aw.IsDuplicate is null OR aw.IsDuplicate = 0)
            AND
              (
				  (aw.Id IN (SELECT Id FROM #CollaborationArtwork))
				  OR
				  a.Id = @ArtistId
              );
			  
        DECLARE @RecordCount INT;
        SELECT
            @RecordCount = COUNT(*)
        FROM
            #ArtworkResults;
			
        IF (@RecordCount > 0)
        BEGIN
				IF (@pageIndex = 1 AND @artworkId > 0)
				BEGIN
						SELECT
							@PageSize = (CEILING((CAST(RowNumber AS DECIMAL(6, 2)) / CAST(@PageSize AS DECIMAL(6, 2))))) * @PageSize
						FROM
							#ArtworkResults ar
						WHERE
							Id = @artworkId
						--ORDER BY
						--    ISNULL(ar.CreationYear, 0) DESC
				END;

				-- showed un-tagged artwork first for admin - 24Jan2020
				IF(@order = 'untagged')
				BEGIN
						SELECT
							awt.ArtworkId,
							COUNT(awt.ArtworkId) AS AwtCount
						INTO #artowrk_tag
						FROM
							#ArtworkResults aw
							INNER JOIN dbo.TagArtwork awt ON awt.ArtworkId = aw.Id						
						GROUP BY
							awt.ArtworkId
							
						SELECT
							ar.*,
							awt.AwtCount
						FROM
							#ArtworkResults ar
							LEFT JOIN #artowrk_tag awt ON awt.ArtworkId = ar.Id
						ORDER BY
							ISNULL(awt.AwtCount, 0) ASC, ISNULL(ar.CreationYear, 0) DESC OFFSET ((@pageIndex - 1) * @PageSize) ROWS FETCH NEXT @PageSize ROWS ONLY;
				END
				ELSE
				BEGIN
						SELECT
							*
						FROM
							#ArtworkResults
						ORDER BY
							ISNULL(CreationYear, 0) DESC OFFSET ((@pageIndex - 1) * @PageSize) ROWS FETCH NEXT @PageSize ROWS ONLY;
				END
        END;
        ELSE
        BEGIN
				SELECT 
					(CASE
						WHEN (a.FirstName IS NULL AND a.LastName IS NULL AND a.Nickname IS NOT NULL ) THEN
							LTRIM(RTRIM(a.Nickname))			 
						WHEN (a.FirstName IS NOT NULL AND a.LastName IS NOT NULL AND a.Nickname IS NOT NULL AND (a.IsNickNameBefore IS NOT NULL AND a.IsNickNameBefore > 0)) THEN
							LTRIM(RTRIM(a.Nickname)) + ' (' + LTRIM(RTRIM(a.FirstName)) + ' ' + LTRIM(RTRIM(a.LastName)) + ')'				  
						WHEN (a.FirstName IS NOT NULL AND a.LastName IS NOT NULL AND a.Nickname IS NOT NULL AND (a.IsNickNameBefore IS NULL OR a.IsNickNameBefore = 0)) THEN
							LTRIM(RTRIM(a.FirstName)) + ' ' + LTRIM(RTRIM(a.LastName)) + ' (' + LTRIM(RTRIM(a.Nickname)) + ')'
						ELSE
							LTRIM(RTRIM(a.FirstName)) + ' ' + LTRIM(RTRIM(a.LastName))
					 END
					) AS ArtistName,
					(CASE
					 WHEN (a.FirstNameFa IS NULL AND a.FirstNameFa IS NULL AND a.NicknameFa IS NOT NULL) THEN
							LTRIM(RTRIM(a.NicknameFa))
					 WHEN (a.FirstNameFa IS NOT NULL AND a.LastNameFa IS NOT NULL AND a.NicknameFa IS NOT NULL AND (a.IsNickNameBefore IS NOT NULL AND a.IsNickNameBefore > 0)) THEN
						  LTRIM(RTRIM(a.NicknameFa)) + ' (' + LTRIM(RTRIM(a.FirstNameFa)) + ' ' + LTRIM(RTRIM(a.LastNameFa)) +')' 
					 WHEN (a.FirstNameFa IS NOT NULL AND a.LastNameFa IS NOT NULL AND a.NicknameFa IS NOT NULL AND (a.IsNickNameBefore IS NULL OR a.IsNickNameBefore = 0)) THEN
						 LTRIM(RTRIM(a.FirstNameFa)) + ' ' + LTRIM(RTRIM(a.LastNameFa)) + ' (' + LTRIM(RTRIM(a.NicknameFa)) + ')'
					 ELSE
						 LTRIM(RTRIM(a.FirstNameFa)) + ' ' + LTRIM(RTRIM(a.LastNameFa))
					 END
					) AS ArtistNameFa,
					a.FirstName,
					a.LastName,
					a.Id AS ArtistId
				FROM
					Artist a WITH(NOLOCK)
				WHERE
					((@firstName IS NOT NULL AND @lastName IS NOT NULL)
					AND   REPLACE(a.FirstName, ' ', '') = @firstName
					AND   REPLACE(a.LastName, ' ', '') = @lastName
					)
					OR ((@nickname IS NOT NULL AND @firstName IS NULL AND @lastName IS NULL) AND REPLACE(a.Nickname, ' ', '') = @nickname);
        END;
    END;
END;





