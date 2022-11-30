CREATE PROCEDURE [dbo].[ArtistLongBio_GetByArtistId]
	@ArtistId INT = 0
AS
BEGIN
	SET TRANSACTION ISOLATION LEVEL SNAPSHOT;
    SET NOCOUNT ON;
	
    DECLARE @TSql NVARCHAR(MAX) = '';
	SET @TSql = N'SELECT *, C.ArtistLongBioId AS Id, STUFF((select '','' + cast(MagazineTagId as NVARCHAR)  from ArtistLongBioMagazineTags where ArtistId = ' + CAST(@ArtistId AS NVARCHAR(20))
	              + N' FOR XML PATH('''')), 1, 1, '''') as CommaSeparatedTagIds 
				FROM ArtistLongBio AS C where
				C.ArtistId = ' + CAST(@ArtistId AS NVARCHAR(20)) + N'';
    EXECUTE sp_executesql @TSql;
END
