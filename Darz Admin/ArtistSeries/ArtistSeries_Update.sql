CREATE PROCEDURE ArtistSeries_Update
	@Id INT = 0,
	@Name NVARCHAR(50) = '',
	@NameFa NVARCHAR(50) = '',
	@ArtistId INT = 0
AS 
BEGIN
	SET TRANSACTION ISOLATION LEVEL SNAPSHOT
	
	UPDATE ArtistSeries
	SET Name = @Name,
		NameFa = @NameFa,
		ArtistId = @ArtistId
	WHERE
		Id = @Id
END