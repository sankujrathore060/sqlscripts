CREATE PROCEDURE [dbo].[MagazineCategory_GetAll_Grid]
	@Sort NVARCHAR(50) = 'Id',
    @SortOrder NVARCHAR(4) = 'DESC',
    @PageSize INT = 10,
	@PageIndex INT = 0
AS
BEGIN

	SET NOCOUNT ON;
	SET TRANSACTION ISOLATION LEVEL SNAPSHOT;

	DECLARE @PageSkip INT = (@PageSize * @PageIndex);
	
	SELECT *
	FROM   (
	           SELECT ROW_NUMBER() OVER(
	                      ORDER BY
							CASE WHEN (@Sort = 'Id' AND @SortOrder='ASC')  
										THEN Id  
							END ASC,
							CASE WHEN (@Sort = 'Id' AND @SortOrder='DESC')  
										THEN Id  
							END DESC,
							CASE WHEN (@Sort = 'Name' AND @SortOrder='ASC')  
										THEN [Name]  
							END ASC,  
							CASE WHEN (@Sort = 'Name' AND @SortOrder='DESC')  
										THEN [Name]  
							END DESC,  
							CASE WHEN (@Sort = 'Namefa' AND @SortOrder='ASC')  
										THEN [Namefa]  
							END ASC,  
							CASE WHEN (@Sort = 'Namefa' AND @SortOrder='DESC')  
										THEN [Namefa]  
							END DESC,
							CASE WHEN (@Sort = 'ModifiedDate' AND @SortOrder='ASC')  
										THEN ModifiedDate
							END ASC,  
							CASE WHEN (@Sort = 'ModifiedDate' AND @SortOrder='DESC')  
										THEN ModifiedDate 
							END DESC,
							CASE WHEN (@Sort = 'rowguid' AND @SortOrder='ASC')  
										THEN [rowguid] 
							END ASC,  
							CASE WHEN (@Sort = 'rowguid' AND @SortOrder='DESC')  
										THEN [rowguid] 
							END DESC,
							CASE WHEN (@Sort = 'OrderInSeries' AND @SortOrder ='ASC')
										THEN [OrderInSeries]
							END ASC,
							CASE WHEN (@Sort = 'OrderInSeries' AND @SortOrder ='DESC')
										THEN [OrderInSeries]
							END DESC,
							CASE WHEN (@Sort = 'IsActive' AND @SortOrder ='ASC')
										THEN [IsActive]
							END ASC,
							CASE WHEN (@Sort = 'IsActive' AND @SortOrder ='DESC')
										THEN [IsActive]
							END DESC,
							CASE WHEN (@Sort = 'ParentCategoryId' AND @SortOrder ='ASC')
										THEN [ParentCategoryId]
							END ASC,
							CASE WHEN (@Sort = 'ParentCategoryId' AND @SortOrder ='DESC')
										THEN [ParentCategoryId]
							END DESC	
	                  ) AS row,
	                  COUNT(*) OVER()  AS TotalRecords,
					  *
	           FROM  
					dbo.MagazineCategory WITH(NOLOCK)
	       ) AS tbl
	ORDER BY
	    row ASC OFFSET @PageSkip ROWS FETCH NEXT @PageSize ROWS ONLY;
END

