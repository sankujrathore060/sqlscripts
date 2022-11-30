ALTER PROCEDURE [dbo].[Magazines_GetByTagId]   
	@TagId INT = 0,
	@IsDevelopmentMode BIT = 0,
	@DisplayLanguage INT = 1
AS
BEGIN
    SET TRANSACTION ISOLATION LEVEL SNAPSHOT;
	SET NOCOUNT ON;
	
	SELECT TOP 30
        ma.*,
		mt.RelativeId as MagazineRelativeId,		
		mt.Name as MagazineTagName,
		mt.NameFa as MagazineTagNameFa,
		mtc.Id as TagCategoryId,
		mtc.Name as TagCategoryName,
		mtc.NameFa as TagCategoryNameFa
    FROM
        Magazines ma WITH(NOLOCK)
		INNER JOIN MagazineSelectedTags mst WITH(NOLOCK) ON ma.Id = mst.MagazineId
		INNER JOIN MagazineTags mt WITH(NOLOCK) ON mt.Id = mst.MagazineTagId
		INNER JOIN MagazineTagCategory mtc WITH(NOLOCK) ON mt.TagCategoryId = mtc.Id
    WHERE
		ma.PublishDate IS NOT NULL AND ma.PublishDate < GETDATE() AND
	    (
			(@IsDevelopmentMode = 1 AND ma.VerificationStatus IN (2, 4))
			OR
			(@IsDevelopmentMode = 0 AND ma.VerificationStatus IN (2))
		)
	     AND ma.DisplayLanguage IN (3, @DisplayLanguage)
		 AND mst.MagazineTagId = @TagId
	ORDER BY
		ma.PublishDate DESC;
END;