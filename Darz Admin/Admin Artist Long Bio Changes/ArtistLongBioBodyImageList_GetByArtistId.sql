ALTER PROCEDURE [dbo].[ArtistLongBioBodyImageList_GetByArtistId]
    @ArtistId INT = 0
AS
BEGIN
	SET TRANSACTION ISOLATION LEVEL SNAPSHOT

	SELECT 
		*, ArtistLongBioBodyImageListId AS Id 
	FROM 
		ArtistLongBioBodyImageList WITH(NOLOCK)
	WHERE
		ArtistId = @ArtistId
End