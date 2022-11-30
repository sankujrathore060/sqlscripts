ALTER PROCEDURE ArtistSeries_Insert
	@Name NVARCHAR(50) = '',
	@NameFa NVARCHAR(50) = '',
	@ArtistId INT = 0
AS 
BEGIN
	SET TRANSACTION ISOLATION LEVEL SNAPSHOT
	
	INSERT INTO ArtistSeries(Name, NameFa, ArtistId, CreatedDate)
	VALUES(@Name, @NameFa, @ArtistId, GETDATE())

	SELECT @@IDENTITY
END