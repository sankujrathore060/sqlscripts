ALTER PROCEDURE [dbo].[GetAllArtWorkOrGetArtWorkbyId]
    @ID INT = 0,
    @ArtistId INT = NULL,
    @IsFeatured BIT = NULL,
    @titleFilter TINYINT = 0,
    @PageNo INT = 0,
    @IsC BIT = NULL,
    @PageSize INT = 10,
    @SortColumn NVARCHAR(250) = 'ModifiedDate DESC,IsFeatured DESC,AssignLifelogYear DESC'
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

    --if (@PageOffset > 0)    
    -- set @SortColumn = 'IsFeatured DESC,AssignLifelogYear DESC'    

    IF @ID > 0
    BEGIN
        SET @TSql
            = N'SELECT AW.* ,STUFF((select   
  '','' + cast(TagId aS NVARCHAR)  from ArtWorkTag where ArtworkId = ' + CAST(@ID AS NVARCHAR(20))
              + N' FOR XML PATH('''')), 1, 1, '''') as Tag, AR.ArtistSeriesId			      
    FROM ArtWork AW LEFT JOIN ArtworkSeries AR ON AW.Id = AR.ArtworkId where    
    AW.Id = ' + CAST(@ID AS NVARCHAR(20));

        PRINT @TSql;
        EXECUTE sp_executesql @TSql;
    END;
    ELSE
    BEGIN
        SET @SQL
            = N'      
    
  Select ArtistId,Count(ArtistId) as FeaturedCount into #temp  
  FROM   ArtWork  AS AW  
  Where IsFeatured = 1  
  Group By ArtistId,IsFeatured  
        ;With CTE AS (SELECT     
        AW.Medium,    
        AW.Id,    
  AW.VerificationStatus,  
              AW.Title,    
              AW.TitleFa,    
     AW.Series,  
     AW.SeriesFa,  
     AW.ArtistId,    
        AW.SecondArtistId,    
              AW.CreationYear,    
              AW.CreationYearFa,    
              AW.Picture,    
			  AW.Height,
		AW.Width,
		AW.Depth,
		AW.Length,
		AW.SizeUnit,
     --CONCAT(convert(DOUBLE PRECISION ,AW.Height),'' x'',convert(DOUBLE PRECISION ,AW.Width),'' x '',convert(DOUBLE PRECISION ,AW.Depth)) as Size,  
   --CASE     
   --when (AW.Height <> 0.000 and AW.Width = 0.000 and AW.Depth = 0.000)     
   --then CONCAT(convert(DOUBLE PRECISION ,aw.Height),'' x - x -'')     
   --when (AW.Height = 0.000 and AW.Width <> 0.000 and AW.Depth = 0.000)     
   --then CONCAT(''- x '',convert(DOUBLE PRECISION ,AW.Width),'' x -'')    
   --when (AW.Height = 0.000 and AW.Width = 0.000 and AW.Depth <> 0.000)     
   --then CONCAT(''- x - x '',convert(DOUBLE PRECISION ,AW.Depth))     
   --when (AW.Height <> 0.000 and AW.Width <> 0.000 and AW.Depth = 0.000)     
   --then CONCAT(convert(DOUBLE PRECISION ,AW.Height),'' x '',convert(DOUBLE PRECISION ,AW.Width) ,'' x -'')     
   --when (AW.Height = 0.000 and AW.Width <> 0.000 and AW.Depth <> 0.000)     
   --then CONCAT(''- x '',convert(DOUBLE PRECISION ,AW.Width),'' x '',convert(DOUBLE PRECISION ,AW.Depth))    
   --when (AW.Height <> 0.000 and AW.Width = 0.000 and AW.Depth <> 0.000)     
   --then CONCAT(convert(DOUBLE PRECISION ,AW.Height),'' x - x '',convert(DOUBLE PRECISION ,AW.Depth))     
   --when (AW.Height <> 0.000 and AW.Width <> 0.000 and AW.Depth <> 0.000)     
   --then CONCAT(convert(DOUBLE PRECISION ,AW.Height),'' x '',convert(DOUBLE PRECISION ,AW.Width),'' x '',convert(DOUBLE PRECISION ,AW.Depth))    
   --when (AW.Height = 0.000 and AW.Width = 0.000 and AW.Depth = 0.000)      
   --then ''- x - x -''   
   --End as Size,  
   (Select YearFrom from ArtistLifeLog where Id = AW.LifeLogId) as AssignLifelogYear,  
              --AW.IsFeatured,    
      CAST(CASE WHEN AW.IsFeatured = 1 THEN 1  ELSE 0 END AS BIT) AS IsFeatured,       
              AW.IsAuctionRecord,    
              AW.IsMobileImage,    
        AW.ModifiedDate,    
     CASE WHEN A.FeaturedImageUrl IS NULL THEN ''False'' ELSE ''True'' END as IsDesktopFeaturedImageUrl,  
     CASE WHEN A.MobileFeaturedImageUrl IS NULL THEN ''False'' ELSE ''True'' END as IsMobileFeaturedImageUrl,  
     (CASE   
     WHEN (FirstName is null and LastName is null and Nickname is not null)   
     THEN LTRIM(RTRIM(Nickname))   
     ELSE LTRIM(RTRIM(FirstName)) +'' ''+ LTRIM(RTRIM(LastName)) END) as ArtistName,  
     (CASE   
     WHEN (FirstNameFa is null and FirstNameFa is null and NicknameFa is not null)   
      THEN LTRIM(RTRIM(NicknameFa))   
     ELSE LTRIM(RTRIM(FirstNameFa)) +'' ''+ LTRIM(RTRIM(LastNameFa)) END) as ArtistNameFa,  
  
              C.Name AS CategoryName,    
              C.Namefa AS CategoryNameFa,  
     ISNULL(t.FeaturedCount,0) as FeaturedCount ,
	 AW.LinkedPriceRecordId,
	 AW.IsDuplicate
       FROM ArtWork AS AW    
       Left Join #temp t 
      on t.ArtistId = aw.ArtistId  
              left JOIN Artist AS A    
                   ON  A.Id = AW.ArtistId    
              LEFT JOIN Category  AS C    
                   ON  C.Id = AW.Category  
        WHERE  
         ((@IsC is null or @IsC = 0) or aw.Censorship = @IsC) and   
         (ISNULL(@ArtistId,0) = 0 or A.Id = @ArtistId) and  
         (@IsFeatured is null or AW.IsFeatured = @IsFeatured) and  
         (ISNULL(@titleFilter,0) = 0   
         OR (@titleFilter = 1 and aw.TitleFa = Cast(aw.TitleFa AS VARCHAR))  
         OR (@titleFilter = 2 and aw.TitleFa <> Cast(aw.TitleFa AS VARCHAR)))  
      ' ;

        --if(@ArtistId is not null and @IsFeatured is not null)    
        --BEGIN    
        --set @SQL = @SQL +' where (A.Id = Cast('+Cast(@ArtistId as nvarchar)+' as int)) and (AW.IsFeatured = Cast('+Cast(@IsFeatured as nvarchar)+' as bit))';    
        --END    
        --Else    
        --BEGIN    
        --  if(@ArtistId is not null)    
        --  BEGIN    
        --  set @SQL = @SQL +' where (A.Id = Cast('+Cast(@ArtistId as nvarchar)+' as int))';    
        --  END    
        --   if(@IsFeatured is not null)    
        --  BEGIN    
        --  set @SQL = @SQL +' where (AW.IsFeatured = Cast('+Cast(@IsFeatured as nvarchar)+' as bit))';    
        --     END    

        --   IF(@titleFilter = 1)          
        --BEGIN    
        -- set @SQL = @SQL +' where  TitleFa = Cast(TitleFa AS VARCHAR)';   
        --END   

        --IF(@titleFilter = 2)          
        --BEGIN    
        -- set @SQL = @SQL +' where TitleFa <> Cast(TitleFa AS VARCHAR)';   
        --END   

        -- END    
        SET @SQL = @SQL + N')';

        SET @TSql = @SQL;
        SET @SQL += N' SELECT @cnt=COUNT(*) FROM CTE ';
        -- PRINT @SQL    
        EXECUTE sp_executesql
            @SQL,
            N'@ArtistId  int, @IsFeatured bit ,@titleFilter tinyint ,@IsC bit, @cnt int OUTPUT',
            @ArtistId = @ArtistId,
            @IsFeatured = @IsFeatured,
            @titleFilter = @titleFilter,
            @IsC = @IsC,
            @cnt = @TCount OUTPUT;
        IF (@TCount > 0)
        BEGIN
            SET @TSql += N' SELECT *,' + CAST(@TCount AS NVARCHAR(15)) + N' AS TotalRecord FROM CTE ' + N' ORDER BY '
                         + @SortColumn + N' OFFSET(' + CAST(@PageOffset AS NVARCHAR(10)) + N') ROWS' + N' FETCH NEXT '
                         + CAST(@PageSize AS NVARCHAR(10)) + N' ROWS ONLY';
            PRINT @TSql;
            EXECUTE sp_executesql
                @TSql,
                N'@ArtistId  int, @IsFeatured bit ,@titleFilter tinyint,@IsC bit, @cnt int OUTPUT',
                @ArtistId = @ArtistId,
                @IsFeatured = @IsFeatured,
                @titleFilter = @titleFilter,
                @IsC = @IsC,
                @cnt = @TCount OUTPUT;
        END;
    END;
END;