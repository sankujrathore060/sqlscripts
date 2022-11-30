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
				SELECT 
				 art.Id,
            art.ArtistId,
            art.Title,
            art.TitleFa,
            art.Series,
            art.SeriesFa,
			-1 as SeriesDdNew,
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
			a.VerificationStatus AS Artist_VerificationStatus,
			afmp.Id AS ArtworkFromMarketProvenanceId,
			afmp.ToSell,
			afmp.PrivacyId,
			afmp.WebsiteOffer
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

		-- SELECT ARTWORK	
		
		
		IF(@sort = 'year_asc')
		BEGIN
				SELECT
					*
				FROM
					#ArtworkResults
				ORDER BY
					ISNULL(CreationYear, 10000) ASC OFFSET ((@PageIndex - 1) * @PageSize) ROWS FETCH NEXT @PageSize ROWS ONLY;
		END
		ELSE IF(@sort = 'year_desc')
		BEGIN
				SELECT
					*
				FROM
					#ArtworkResults
				ORDER BY
					ISNULL(CreationYear, 0) DESC OFFSET ((@PageIndex - 1) * @PageSize) ROWS FETCH NEXT @PageSize ROWS ONLY;
		END
		ELSE IF(@sort = 'recently_added')
		BEGIN
				SELECT
					*
				FROM					
					#ArtworkResults
				ORDER BY
					ModifiedDate DESC OFFSET ((@PageIndex - 1) * @PageSize) ROWS FETCH NEXT @PageSize ROWS ONLY;
		END
		ELSE 
		BEGIN
				
			SELECT 
				ar.*
			FROM 
			#ArtworkResults ar
			ORDER BY
				ISNULL(CreationYear, 0) DESC OFFSET ((@PageIndex - 1) * @PageSize) ROWS FETCH NEXT @PageSize ROWS ONLY;
		END    	
END;