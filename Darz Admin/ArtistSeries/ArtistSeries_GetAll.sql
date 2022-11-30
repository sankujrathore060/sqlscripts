CREATE PROCEDURE ArtistSeries_GetAll
AS 
BEGIN
	SET TRANSACTION ISOLATION LEVEL SNAPSHOT
	
	SELECT * FROM ArtistSeries WITH(NOLOCK) ORDER BY CreatedDate DESC

END