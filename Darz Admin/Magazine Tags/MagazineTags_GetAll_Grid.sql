ALTER PROCEDURE [dbo].[MagazineTags_GetAll_Grid]
	@PageIndex INT = 0,
	@PageSize INT = 10,
	@Sort NVARCHAR(50) = 'CreationDate',
	@SortOrder NVARCHAR(4) = 'DESC',
	@Description NVARCHAR(MAX) = ''
AS
BEGIN
	SET TRANSACTION ISOLATION LEVEL SNAPSHOT;

	DECLARE @PageSkip INT = (@PageSize * @PageIndex);
	SELECT 
	*
	FROM
	(
		SELECT ROW_NUMBER() OVER (
							ORDER BY 
								CASE WHEN (@SortOrder = 'ASC' AND @Sort = 'Id' )
											THEN Id
								END ASC,
								CASE WHEN (@SortOrder = 'DESC' AND @Sort = 'Id')
											THEN Id
								END DESC,
								CASE WHEN (@SortOrder = 'ASC' AND @Sort = 'TagCategoryId' )
											THEN [TagCategoryId]
								END ASC,
								CASE WHEN (@SortOrder = 'DESC' AND @Sort = 'TagCategoryId' )
											THEN [TagCategoryId]
								END ASC,
								CASE WHEN (@SortOrder = 'ASC' AND @Sort = 'Name' )
											THEN Name
								END ASC,
								CASE WHEN (@SortOrder = 'DESC' AND @Sort = 'Name' )
											THEN Name
								END DESC,
								CASE WHEN (@SortOrder = 'ASC' AND @Sort = 'NameFa' )
											THEN NameFa
								END ASC,
								CASE WHEN (@SortOrder = 'DESC' AND @Sort = 'NameFa')
											THEN NameFa
								END DESC,
								CASE WHEN (@SortOrder = 'ASC' AND @Sort = 'CreationDate')
											THEN CreationDate
								END DESC,
								CASE WHEN (@SortOrder = 'DESC' AND @Sort = 'CreationDate')
											THEN CreationDate
								END DESC,
								CASE WHEN (@SortOrder = 'ASC' AND @Sort = 'Description')
											THEN Description
								END DESC,
								CASE WHEN (@SortOrder = 'DESC' AND @Sort = 'Description')
											THEN Description
								END DESC 								  
							)	AS row,
							COUNT(*) OVER() AS TotalRecords,
							*
							FROM
							MagazineTags WITH(NOLOCK)
	       ) AS tbl
	ORDER BY
	    row ASC OFFSET @PageSkip ROWS FETCH NEXT @PageSize ROWS ONLY;
END
