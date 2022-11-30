CREATE PROCEDURE [dbo].[MarketingUser_Update]
	@MarketingUserId AS INT,
	@Fullname AS NVARCHAR(256),
	@BackOfficeUserId AS INT,
	@Cellphone AS VARCHAR(11)
AS
BEGIN
	SET NOCOUNT ON;

	UPDATE Clients.MarketingUser 
	SET [Fullname] = @Fullname, [BackOfficeUserId] = @BackOfficeUserId, [CreatedDate] = GetDate(), [Cellphone] = @Cellphone
	WHERE [MarketingUserId] = @MarketingUserId

END