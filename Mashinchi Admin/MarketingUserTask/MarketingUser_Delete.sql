CREATE PROCEDURE [dbo].[MarketingUser_Delete]
	@Id INT
AS
BEGIN
	
	UPDATE Clients.MarketingUser
	SET IsDeleted = 1
	WHERE MarketingUserId = @Id 
END

