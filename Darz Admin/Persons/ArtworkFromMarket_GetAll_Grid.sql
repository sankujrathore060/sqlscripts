ALTER PROCEDURE [dbo].[ArtworkFromMarket_GetAll_Grid]
	@ArtistId INT = 0,
    @PersonTypeId INT = 0,
	@Deal INT = 0,
	@Type NVARCHAR(100) = '',
	@PageNo INT = 1,
    @PageSize INT = 10,
    @SortColumn NVARCHAR(100) = 'ModifiedDate DESC'
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

    SET @SQL = N'With CTE AS ( 
					SELECT 
						afmp.*, aw.Picture,
						(CASE   
						WHEN (afmp.PersonType = 1)   
						THEN p.LevelOfEngagement   
						ELSE p2.LevelOfEngagement END) as LevelOfEngagement,
						(CASE   
						WHEN (afmp.PersonType = 1)   
						THEN p.Name   
						ELSE p2.Name END) as PersonName,
						(CASE   
						WHEN (a.FirstName is null and a.LastName is null and a.Nickname is not null)   
						THEN LTRIM(RTRIM(a.Nickname))   
						ELSE LTRIM(RTRIM(a.FirstName)) +'' ''+ LTRIM(RTRIM(a.LastName)) END) as ArtistName,
						aw.Height,
						aw.Width,
						aw.Depth,
						aw.Length
						FROM ArtWork AS aw WITH(NOLOCK) 						
					LEFT JOIN Artist AS a WITH(NOLOCK) ON aw.ArtistId = a.Id 
					INNER JOIN ArtworkFromMarketProvenance AS afmp WITH(NOLOCK) ON aw.Id = afmp.ArtworkId						 
					LEFT JOIN Persons As p WITH(NOLOCK) ON afmp.CollectorId = p.Id
					LEFT JOIN Persons As p2 WITH(NOLOCK) ON afmp.DealerId = p2.Id';

    SET @SQL = @SQL + N' Where (ISNULL(' + Cast(@ArtistId AS NVARCHAR(20)) + N',0) = 0 OR aw.ArtistId = ' + Cast(@ArtistId AS NVARCHAR(20)) + N')';
    SET @SQL = @SQL + N' AND (ISNULL(' + CAST(@PersonTypeId AS NVARCHAR(20)) + N', 0) = 0  OR afmp.PersonType = ' + CAST(@PersonTypeId AS NVARCHAR(10)) + N')';
	SET @SQL = @SQL + N' AND (ISNULL(' + CAST(@Deal AS NVARCHAR(20)) + N',0) = 0 OR afmp.Deal = ' + CAST(@Deal AS NVARCHAR(20)) + N')';
	
	IF (@Type = 'tosell')
	BEGIN		
		SET @SQL = @SQL + N' AND afmp.ToSell = 1';
	END
	IF (@Type = 'buy')
	BEGIN		
		SET @SQL = @SQL + N' AND afmp.ToSell = 0';
	END
	
    SET @SQL = @SQL + N')';
    SET @TSql = @SQL;
    SET @SQL += N' SELECT @cnt = COUNT(*) FROM CTE ';
	
	PRINT @SQL;
	EXECUTE sp_executesql @SQL, N'@cnt int OUTPUT', @cnt = @TCount OUTPUT;

    IF (@TCount > 0)
    BEGIN
        SET @TSql += N' SELECT *,' + CAST(@TCount AS NVARCHAR(15)) + N' AS TotalRecord FROM CTE ' + N' ORDER BY '
                     + @SortColumn + N' OFFSET(' + CAST(@PageOffset AS NVARCHAR(10)) + N') ROWS' + N' FETCH NEXT '
                     + CAST(@PageSize AS NVARCHAR(10)) + N' ROWS ONLY';

        EXECUTE sp_executesql @TSql;
    END;
END;