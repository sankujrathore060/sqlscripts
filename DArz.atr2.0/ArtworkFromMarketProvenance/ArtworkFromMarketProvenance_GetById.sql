CREATE PROCEDURE [dbo].[ArtworkFromMarketProvenance_GetById]
	@Id INT = 0
AS
BEGIN
	SET TRANSACTION ISOLATION LEVEL SNAPSHOT;

	SELECT * 
	FROM ArtworkFromMarketProvenance WITH(nolock)
	WHERE (ISNULL(@Id,0) = 0 OR (Id = @Id))
	ORDER BY CreationDate DESC
END