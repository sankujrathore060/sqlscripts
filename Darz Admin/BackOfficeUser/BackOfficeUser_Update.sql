ALTER PROCEDURE [dbo].[BackOfficeUser_Update]
	@UserId UNIQUEIDENTIFIER = '',
	@Email NVARCHAR(512) = '',	
	@PhoneNumber NVARCHAR(MAX) = '',
	@UserName NVARCHAR(512) = '',
	@Password NVARCHAR(MAX) = ''
AS
BEGIN
	SET TRANSACTION ISOLATION LEVEL SNAPSHOT

	UPDATE BackOfficeUser
			SET
				Email = @Email, PhoneNumber = @PhoneNumber, UserName = @UserName, [Password] = @Password
			WHERE
				UserId = @UserId					
END
	 