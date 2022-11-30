CREATE PROCEDURE ArtistSeries_Delete
	@Id INT = 0
AS 
BEGIN
	DELETE FROM ArtistSeries
	Where Id = @Id
END