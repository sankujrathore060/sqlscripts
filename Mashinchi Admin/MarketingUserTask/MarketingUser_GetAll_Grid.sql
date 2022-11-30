CREATE PROCEDURE [dbo].[MarketingUser_GetAll_Grid]
(
	@Sort NVARCHAR(50) = 'MarketingUserId',
    @SortOrder NVARCHAR(4) = 'DESC',
    @PageNo INT = 0,
    @PageSize INT = NULL
)
AS
BEGIN
	
	SET NOCOUNT ON;
	SET TRANSACTION ISOLATION LEVEL SNAPSHOT;

	DECLARE @PageSkip INT = (@PageSize * @PageNo);
	
	SELECT *
	FROM   (
	           SELECT ROW_NUMBER() OVER(
	                      ORDER BY     
	                      CASE 
	                           WHEN (@Sort = 'MarketingUserId' AND @SortOrder = 'ASC') THEN 
	                                mu.MarketingUserId
	                      END ASC,
	                      CASE 
	                           WHEN (@Sort = 'MarketingUserId' AND @SortOrder = 'DESC') THEN 
	                                mu.MarketingUserId
	                      END DESC,
	                      CASE 
	                           WHEN (@Sort = 'Fullname' AND @SortOrder = 'ASC') THEN 
	                                mu.Fullname
	                      END ASC,
	                      CASE 
	                           WHEN (@Sort = 'Fullname' AND @SortOrder = 'DESC') THEN 
	                                mu.Fullname
	                      END DESC,
	                      CASE 
	                           WHEN (@Sort = 'CreatedDate' AND @SortOrder = 'ASC') THEN 
	                                mu.CreatedDate
	                      END ASC,
	                      CASE 
	                           WHEN (@Sort = 'CreatedDate' AND @SortOrder = 'DESC') THEN 
	                                mu.CreatedDate
	                      END DESC,
	                      CASE 
	                           WHEN (@Sort = 'Cellphone' AND @SortOrder = 'ASC') THEN 
	                                mu.Cellphone
	                      END ASC,
	                      CASE 
	                           WHEN (@Sort = 'Cellphone' AND @SortOrder = 'DESC') THEN 
	                                mu.Cellphone
	                      END DESC,
	                      CASE 
	                           WHEN (@Sort = 'IsDeleted' AND @SortOrder = 'ASC') THEN 
	                                mu.IsDeleted
	                      END ASC,
	                      CASE 
	                           WHEN (@Sort = 'IsDeleted' AND @SortOrder = 'DESC') THEN 
	                                mu.IsDeleted
	                      END DESC,
	                      CASE 
	                           WHEN (@Sort = 'BackOfficeUserName' AND @SortOrder = 'ASC') THEN 
	                                bu.UserName
	                      END ASC,
	                      CASE 
	                           WHEN (@Sort = 'BackOfficeUserName' AND @SortOrder = 'DESC') THEN 
	                                bu.UserName
	                      END DESC
	                  ) AS row,
	                  COUNT(*) OVER()  AS TotalRecords,
					  mu.*,
					  bu.Name As BackOfficeUserName
	           FROM  
					Clients.MarketingUser  mu WITH(NOLOCK)
					LEFT JOIN Clients.BackofficeUser bu WITH(NOLOCK) ON mu.BackOfficeUserId = bu.BackofficeUserID
			   WHERE
					ISNULL(mu.IsDeleted,0) = 0
	       ) AS tbl
	ORDER BY
	    row ASC OFFSET @PageSkip ROWS FETCH NEXT @PageSize ROWS ONLY;
END;