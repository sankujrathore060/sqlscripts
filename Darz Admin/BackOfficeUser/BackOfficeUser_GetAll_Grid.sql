ALTER PROCEDURE [dbo].[BackOfficeUser_GetAll_Grid]
	@PageIndex INT = 0,
	@PageSize INT = 10,
	@Sort NVARCHAR(50) = 'Email',
	@SortOrder NVARCHAR(4) = 'DESC'
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
								CASE WHEN (@SortOrder = 'ASC' AND @Sort = 'UserId' )
											THEN UserId
								END ASC,
								CASE WHEN (@SortOrder = 'DESC' AND @Sort = 'UserId')
											THEN UserId
								END DESC,
								CASE WHEN (@SortOrder = 'ASC' AND @Sort = 'Email' )
											THEN [Email]
								END ASC,
								CASE WHEN (@SortOrder = 'DESC' AND @Sort = 'Email' )
											THEN [Email]
								END ASC,
								CASE WHEN (@SortOrder = 'ASC' AND @Sort = 'PhoneNumber' )
											THEN PhoneNumber
								END ASC,
								CASE WHEN (@SortOrder = 'DESC' AND @Sort = 'PhoneNumber' )
											THEN PhoneNumber
								END DESC,
								CASE WHEN (@SortOrder = 'ASC' AND @Sort = 'UserName' )
											THEN UserName
								END ASC,
								CASE WHEN (@SortOrder = 'DESC' AND @Sort = 'UserName')
											THEN UserName
								END DESC,
								CASE WHEN (@SortOrder = 'ASC' AND @Sort = 'PasswordHash')
											THEN PasswordHash
								END DESC,
								CASE WHEN (@SortOrder = 'DESC' AND @Sort = 'PasswordHash')
											THEN PasswordHash
								END DESC 								  
							)	AS row,
							COUNT(*) OVER() AS TotalRecords,
							UserId,
							Email,
							PhoneNumber,
							UserName,
							PasswordHash
							FROM
							BackOfficeUser WITH(NOLOCK)
							WHERE 
							IsDeleted  = 0
	       ) AS tbl
	ORDER BY
	    row ASC OFFSET @PageSkip ROWS FETCH NEXT @PageSize ROWS ONLY;
END
