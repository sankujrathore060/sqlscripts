ALTER PROCEDURE [dbo].[MagazineTagCategory_GetById]
	@Id INT = 0
AS
BEGIN
	SET TRANSACTION ISOLATION LEVEL SNAPSHOT;

	SELECT * 
	FROM MagazineTagCategory WITH(nolock)
	WHERE (ISNULL(@Id,0) = 0 OR (Id = @Id))
	ORDER BY CreationDate DESC
END
