ALTER PROCEDURE BackOfficeUser_InsertPassword
	@UserName NVARCHAR(512) = '',
	@Password NVARCHAR(MAX) =''
AS
BEGIN
	SET TRANSACTION ISOLATION LEVEL SNAPSHOT

	UPDATE BackOfficeUser 
	SET [Password] = @Password
	WHERE UserName = @UserName
END
DROP PROCEDURE BackOfficeUser_InsertPassword
