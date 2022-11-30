CREATE PROCEDURE [dbo].[Persons_GetByVerifiedEmail]
	@VerifiedEmail NVARCHAR(100) = ''
AS
BEGIN
	SET TRANSACTION ISOLATION LEVEL SNAPSHOT;

	SELECT * 
	FROM Persons WITH(nolock)
	WHERE (ISNULL(@VerifiedEmail,'') = '' OR (Email = @VerifiedEmail))
	ORDER BY CreationDate DESC
END