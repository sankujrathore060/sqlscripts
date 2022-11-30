CREATE PROCEDURE [Mashinchi].[proc_PublicHoliday_GetAll_Grid]
	@Sort NVARCHAR(50) = 'HolidayDate',
    @SortOrder NVARCHAR(4) = 'DESC',
    @PageSize INT = 10,
	@PageIndex INT = 0
AS
BEGIN

	SET NOCOUNT ON;
	SET TRANSACTION ISOLATION LEVEL SNAPSHOT;

	DECLARE @pageSkip INT = (@pageSize * @pageIndex);
	
	SELECT *
	FROM   (
	           SELECT ROW_NUMBER() OVER(
	                      ORDER BY
							CASE WHEN (@Sort = 'PublicHolidayId' AND @SortOrder='ASC')  
										THEN PublicHolidayId  
							END ASC,
							CASE WHEN (@Sort = 'PublicHolidayId' AND @SortOrder='DESC')  
										THEN PublicHolidayId  
							END DESC,
							CASE WHEN (@Sort = 'StrHolidayDate' AND @SortOrder='ASC')  
										THEN HolidayDate  
							END ASC,  
							CASE WHEN (@Sort = 'StrHolidayDate' AND @SortOrder='DESC')  
										THEN HolidayDate  
							END DESC,  
							CASE WHEN (@Sort = 'IsActive' AND @SortOrder='ASC')  
										THEN IsActive  
							END ASC,  
							CASE WHEN (@Sort = 'IsActive' AND @SortOrder='DESC')  
										THEN IsActive  
							END DESC,
							CASE WHEN (@Sort = 'StrCreatedDate' AND @SortOrder='ASC')  
										THEN CreatedDate 
							END ASC,  
							CASE WHEN (@Sort = 'StrCreatedDate' AND @SortOrder='DESC')  
										THEN CreatedDate 
							END DESC,
							CASE WHEN (@Sort = 'Description' AND @SortOrder='ASC')  
										THEN [Description] 
							END ASC,  
							CASE WHEN (@Sort = 'Description' AND @SortOrder='DESC')  
										THEN [Description] 
							END DESC
	                  ) AS row,
	                  COUNT(*) OVER()  AS TotalRecords,
					  *
	           FROM  
					Mashinchi.PublicHoliday WITH(NOLOCK)
	       ) AS tbl
	ORDER BY
	    row ASC OFFSET @pageSkip ROWS FETCH NEXT @PageSize ROWS ONLY;
END

