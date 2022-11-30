ALTER PROCEDURE [dbo].[ArtworkContactFromWebsite_GetAll_Grid]
	@Email NVARCHAR(MAX) = NULL,
    @PageNo INT = 0,
    @PageSize INT = 10,
    @SortColumn NVARCHAR(100) = 'CreatedDate DESC'
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

    SET @SQL = N'With CTE AS ( SELECT acfw.*,
								au.Email,
								aw.Picture,
								(CASE   
									WHEN (art.FirstName is null and art.LastName is null and art.Nickname is not null)   
									THEN LTRIM(RTRIM(art.Nickname))   
									ELSE LTRIM(RTRIM(art.FirstName)) +'' ''+ LTRIM(RTRIM(art.LastName)) END) AS ArtistName,  
								(CASE   
									WHEN (art.FirstNameFa is null and art.FirstNameFa is null and art.NicknameFa is not null)   
									THEN LTRIM(RTRIM(art.NicknameFa))   
									ELSE LTRIM(RTRIM(art.FirstNameFa)) +'' ''+ LTRIM(RTRIM(art.LastNameFa)) END) AS ArtistNameFa,
								(CASE acfw.PageId
									WHEN ''1'' THEN ''Shows Detail''
									ELSE ''Shows Detail'' END) AS PageName,
								(CASE acfw.PageId
									WHEN ''1'' THEN (Select g.Name +''#''+ ge.Title from Gallery g INNER JOIN GalleryEvent ge ON g.Id = ge.GalleryId WHERE ge.Id = acfw.PageRelativeId)
									ELSE ''#'' END) AS PageRelativeName
							FROM 
							dbo.ArtworkContactFromWebsite acfw WITH(NOLOCK) 
							INNER JOIN dbo.ApplicationUser au WITH(NOLOCK)  ON acfw.UserId = au.UserId
							INNER JOIN dbo.ArtWork aw WITH(NOLOCK) ON acfw.ArtworkId = aw.Id
							INNER JOIN dbo.Artist art WITH(NOLOCK) ON art.Id = aw.ArtistId';

	IF (@Email IS NOT NULL)
	BEGIN	
	  SET @SQL = @SQL + N' WHERE au.Email IN(''' + CAST(@Email AS NVARCHAR(MAX)) + N''')';
	END

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