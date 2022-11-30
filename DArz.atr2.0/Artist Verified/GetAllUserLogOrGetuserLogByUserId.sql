ALTER PROCEDURE [dbo].[GetAllUserLogOrGetuserLogByUserId] 
	@UserId UNIQUEIDENTIFIER
AS
BEGIN
	SELECT * FROM ApplicationUserLog WITH(nolock) 
	WHERE UserId = @UserId 
	ORDER BY LoginTime DESC
END