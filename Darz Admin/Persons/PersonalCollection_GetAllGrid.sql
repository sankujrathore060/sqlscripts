--, @ArtistId = 0;
--exec PersonalCollection_GetAllGrid @CollectorId = 46

ALTER PROCEDURE [dbo].[PersonalCollection_GetAllGrid] 
	@CollectorId INT = 0,	
    @ArtistId INT = 0,
    @PageNo INT = 0,
    @PageSize INT = 10,
    @SortColumn NVARCHAR(250) = 'ModifiedDate DESC'
AS
BEGIN
    SET TRANSACTION ISOLATION LEVEL SNAPSHOT;
    SET NOCOUNT ON;
    DECLARE @SQL NVARCHAR(MAX) = '';
    DECLARE @TSql NVARCHAR(MAX) = '';
    DECLARE @TCount INT = 0;
    DECLARE @PageOffset INT = 0;

    SET @PageOffset = (@PageNo * @PageSize);
    IF (@PageOffset < 0)
        SET @PageOffset = 0;
    SET @Sql = N';With CTE AS (SELECT 
				(CASE   
					WHEN (a.FirstName is null and a.LastName is null and a.Nickname is not null)   
					THEN LTRIM(RTRIM(a.Nickname))   
					ELSE LTRIM(RTRIM(a.FirstName)) +'' ''+ LTRIM(RTRIM(a.LastName)) END) as ArtistName, 
				art.VerificationStatus AS VerificationStatus,
				CASE WHEN (ISNULL(art.SeriesId, 0) > 0 AND ass.Id > 0) THEN ass.Name
					ELSE art.Series
				END AS Series,
				art.Title,
				art.TitleFa,
				art.CreationYear,
				c.Name AS CategoryName,
				art.Picture,    
				art.Height,
				art.Width,
				art.Depth,
				art.Length,
				art.SizeUnit,	
				art.ImageHeight,
				art.ImageWidth,			
				art.Medium,
				afmp.ToSell,
				afmp.Deal,
				afmp.PrivacyId,
				afmp.ModifiedDate,
				afmp.ArtworkId,
				afmp.Id AS ArtworkFromMarketProvenanceId
			FROM 
				ArtWork AS art WITH(nolock) 	
				LEFT JOIN Artist AS a WITH(NOLOCK) ON art.ArtistId = a.Id 
				LEFT JOIN ArtistSeries AS ass WITH(NOLOCK) ON art.SeriesId = ass.Id				
				LEFT JOIN Category AS c WITH(NOLOCK) ON  art.Category = c.Id
				INNER JOIN ArtworkFromMarketProvenance AS afmp WITH(nolock) ON art.Id = afmp.ArtworkId
			WHERE   
				(ISNULL(' + Cast(@ArtistId AS NVARCHAR(20)) + N',0) = 0 OR a.Id = ' + Cast(@ArtistId AS NVARCHAR(20)) + N') and   
				(ISNULL(' + Cast(@CollectorId AS NVARCHAR(20)) + N',0) = 0 OR (afmp.CollectorId = ' + Cast(@CollectorId AS NVARCHAR(20)) + N'))';
				
	SET @SQL = @SQL + N')';
	SET @TSql = @SQL;
	SET @SQL += N' SELECT @cnt = COUNT(*) FROM CTE ';
		
	EXECUTE sp_executesql @SQL, N'@cnt int OUTPUT', @cnt = @TCount OUTPUT;
        
	IF (@TCount > 0)
	BEGIN
		SET @TSql += N' SELECT *,' + CAST(@TCount AS NVARCHAR(15)) + N' AS TotalRecord FROM CTE ' + N' ORDER BY '
						+ @SortColumn + N' OFFSET(' + CAST(@PageOffset AS NVARCHAR(10)) + N') ROWS' + N' FETCH NEXT '
						+ CAST(@PageSize AS NVARCHAR(10)) + N' ROWS ONLY';

		EXECUTE sp_executesql @TSql;
	END;
END;






