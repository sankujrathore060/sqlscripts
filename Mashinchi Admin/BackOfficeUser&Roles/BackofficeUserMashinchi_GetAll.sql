CREATE PROCEDURE [dbo].[BackofficeUserMashinchi_GetAll]	@Sort NVARCHAR(50) = 'Id',
    @SortOrder NVARCHAR(4) = 'desc',
    @PageNo INT = 0,
    @PageSize INT = NULL
AS
BEGIN
	SET TRANSACTION ISOLATION LEVEL SNAPSHOT;
	SET NOCOUNT ON;

	IF(@PageSize IS NULL)
	BEGIN
		SELECT 
			ROW_NUMBER() OVER (
				ORDER BY
				CASE WHEN (@Sort = 'RoleName' AND @SortOrder = 'ASC') THEN RoleName END ASC,
				CASE WHEN (@Sort = 'RoleName' AND @SortOrder = 'DESC') THEN RoleName END DESC,
				CASE WHEN (@Sort = 'Id' AND @SortOrder = 'ASC') THEN BackofficeUserID END ASC,
				CASE WHEN (@Sort = 'Id' AND @SortOrder = 'DESC') THEN BackofficeUserID END DESC
			) AS row1,
			*,
			BackofficeUserID as Id
		FROM 			(				SELECT 
					ROW_NUMBER() OVER (
							ORDER BY
							CASE WHEN (@Sort = 'Id' AND @SortOrder = 'ASC') THEN BackofficeUserID END ASC,
							CASE WHEN (@Sort = 'Id' AND @SortOrder = 'DESC') THEN BackofficeUserID END DESC
					) AS row, 
					COUNT(*) OVER() AS TotalRecords,  
					bou.*,
					STUFF((
						SELECT ', ' + cb.Name
						FROM 
							Clients.BackOfficeUserRoles t
							INNER JOIN Clients.BackOfficeRoles cb on cb.Id = t.RoleId
						WHERE t.UserId = bou.BackOfficeUserId
						ORDER BY cb.Name
						FOR XML PATH('')
					), 1, 1, ' ') as RoleName
				FROM  
					Clients.BackofficeUser bou
				WHERE
					ISNULL(bou.IsDeleted, 0) = 0 AND	 				
					bou.IsMashinchiAdmin = 1
			) AS tbl 
		WHERE (row BETWEEN  @PageNo AND TotalRecords AND @PageSize IS NULL) --OR ((row BETWEEN @PageNo AND @PageSize) AND @PageSize IS NOT NULL)
			ORDER BY row1 ASC
	END
	ELSE
	BEGIN
			SELECT 
				ROW_NUMBER() OVER (
						ORDER BY
						CASE WHEN (@Sort = 'RoleName' AND @SortOrder = 'ASC') THEN RoleName END ASC,
						CASE WHEN (@Sort = 'RoleName' AND @SortOrder = 'DESC') THEN RoleName END DESC,
						CASE WHEN (@Sort = 'Id' AND @SortOrder = 'ASC') THEN BackofficeUserID END ASC,
						CASE WHEN (@Sort = 'Id' AND @SortOrder = 'DESC') THEN BackofficeUserID END DESC
				) AS row1,
				*,
				BackofficeUserID as Id
			FROM 				(					SELECT 
						ROW_NUMBER() OVER (
								ORDER BY
									CASE WHEN (@Sort = 'Id' AND @SortOrder = 'ASC') THEN BackofficeUserID END ASC,
									CASE WHEN (@Sort = 'Id' AND @SortOrder = 'DESC') THEN BackofficeUserID END DESC
						) AS row, 
						COUNT(*) OVER() AS TotalRecords,  
						bou.*,
						STUFF((
							SELECT ', ' + cb.Name
							FROM 
								Clients.BackOfficeUserRoles t
								INNER JOIN Clients.BackOfficeRoles cb on cb.Id = t.RoleId
							WHERE t.UserId = bou.BackOfficeUserId
							ORDER BY cb.Name
							FOR XML PATH('')
						), 1, 1, ' ') as RoleName
					FROM  Clients.BackofficeUser bou
					WHERE
						ISNULL(bou.IsDeleted, 0) = 0 AND	 				
						bou.IsMashinchiAdmin = 1
				) AS tbl 
			ORDER BY row1 ASC OFFSET(@PageNo) * @PageSize ROWS
	
	FETCH NEXT @PageSize ROWS ONLY
	END
END;