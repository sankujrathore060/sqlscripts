ALTER PROCEDURE [dbo].[MagazineCategory_GetAll]
AS 
BEGIN
	SET NOCOUNT ON
	SET TRANSACTION ISOLATION LEVEL SNAPSHOT;
	SELECT mc1.*,
		   mc2.[Name] AS ParentCategoryName 
	FROM 
	MagazineCategory mc1 WITH(nolock)
	LEFT JOIN MagazineCategory mc2 WITH(nolock) ON mc1.ParentCategoryId = mc2.Id
	ORDER BY mc1.ModifiedDate DESC
END