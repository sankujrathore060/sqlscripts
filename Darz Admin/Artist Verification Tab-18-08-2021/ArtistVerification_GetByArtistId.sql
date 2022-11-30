ALTER PROCEDURE ArtistVerification_GetByArtistId
	@Id INT = 0
AS
BEGIN
	SET TRANSACTION ISOLATION LEVEL SNAPSHOT;

	SELECT * 
	FROM ArtistVerification WITH(nolock)
	WHERE ArtistId = @Id
END
