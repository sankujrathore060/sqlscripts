CREATE PROCEDURE [dbo].[MarketingUser_Insert]
	@Fullname AS NVARCHAR(256),
	@BackOfficeUserId AS INT,
	@Cellphone AS VARCHAR(11)
AS
BEGIN
	SET NOCOUNT ON;

	INSERT 
	INTO Clients.MarketingUser([Fullname], [CreatedDate], [BackOfficeUserId], [Cellphone])
	VALUES (@Fullname, GETDATE(), @BackOfficeUserId, @Cellphone)
	
	-- Return the new ID
    SELECT
        SCOPE_IDENTITY(); 
END