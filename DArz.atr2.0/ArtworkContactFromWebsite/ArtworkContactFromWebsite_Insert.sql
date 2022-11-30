CREATE PROCEDURE [dbo].[ArtworkContactFromWebsite_Insert]
	@Id INT = 0,
	@ArtworkId INT = 0,
	@UserId INT = 0,
	@Message NVARCHAR(MAX) = '',
	@PageId INT = 0,
	@PageRelativeId INT = 0,
	@CreatedDate DATETIME
AS 
BEGIN
	SET TRANSACTION ISOLATION LEVEL SNAPSHOT;

	INSERT INTO ArtworkContactFromWebsite(ArtworkId, UserId, Message, PageId, PageRelativeId, CreatedDate)
	VALUES (@ArtworkId, @UserId, @Message, @PageId, @PageRelativeId, @CreatedDate)

	SELECT @@IDENTITY
END