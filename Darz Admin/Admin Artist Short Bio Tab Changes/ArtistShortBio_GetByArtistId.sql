ALTER PROCEDURE [dbo].[ArtistShortBio_GetByArtistId]
	@ArtistId INT = 0
AS
BEGIN
	SET TRANSACTION ISOLATION LEVEL SNAPSHOT;
    SET NOCOUNT ON;
	
    DECLARE @TSql NVARCHAR(MAX) = '';
	SET @TSql = N'SELECT *, C.ArtistShortBioId AS Id, STUFF((select '','' + cast(MagazineTagId as NVARCHAR)  from ArtistShortBioMagazineTags where ArtistId = ' + CAST(@ArtistId AS NVARCHAR(20))
	              + N' FOR XML PATH('''')), 1, 1, '''') as CommaSeparatedTagIds 
				FROM ArtistShortBio AS C where
				C.ArtistId = ' + CAST(@ArtistId AS NVARCHAR(20)) + N'';
    EXECUTE sp_executesql @TSql;
END
