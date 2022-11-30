ALTER PROCEDURE [dbo].[Persons_GetAll_Grid]
    @PageNo INT = 0,
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

    SET @SQL = N'With CTE AS ( SELECT * FROM dbo.Persons ma WITH(NOLOCK) ';

    SET @SQL = @SQL + N' WHERE 1 = 1';
	
    SET @SQL = @SQL + N')';
    SET @TSql = @SQL;
    SET @SQL += N' SELECT @cnt = COUNT(*) FROM CTE ';
	
	-- PRINT @SQL;

    EXECUTE sp_executesql @SQL, N'@cnt int OUTPUT', @cnt = @TCount OUTPUT;

    IF (@TCount > 0)
    BEGIN
        SET @TSql += N' SELECT *,' + CAST(@TCount AS NVARCHAR(15)) + N' AS TotalRecord FROM CTE ' + N' ORDER BY '
                     + @SortColumn + N' OFFSET(' + CAST(@PageOffset AS NVARCHAR(10)) + N') ROWS' + N' FETCH NEXT '
                     + CAST(@PageSize AS NVARCHAR(10)) + N' ROWS ONLY';

        EXECUTE sp_executesql @TSql;
    END;
END;