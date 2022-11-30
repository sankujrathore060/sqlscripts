ALTER PROCEDURE [dbo].[ArtworkContactFromWebsite_GetByUserAndArtwork]
	@ArtworkId INT = 0,
	@UserId UNIQUEIDENTIFIER,
	@PageId INT = 0,
	@PageRelativeId INT = 0
AS 
BEGIN
	SET TRANSACTION ISOLATION LEVEL SNAPSHOT;

	SELECT * FROM ArtworkContactFromWebsite WITH(NOLOCK)
	WHERE ArtworkId = @ArtworkId
	AND UserId = @UserId
	AND PageId = @PageId
	AND PageRelativeId = @PageRelativeId
END