CREATE PROCEDURE [dbo].[ArtworkFromMarketProvenance_DeleteById]
	@Id INT = 0
AS
BEGIN
	SET TRANSACTION ISOLATION LEVEL SNAPSHOT;
	
	DELETE FROM ArtworkFromMarketProvenance
	WHERE (ISNULL(@Id,0) = 0 OR (Id = @Id))
END