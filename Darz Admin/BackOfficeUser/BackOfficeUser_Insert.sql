ALTER PROCEDURE [dbo].[BackOfficeUser_Insert]	
	@PasswordHash NVARCHAR(MAX) = '',
	@SecurityStamp NVARCHAR(MAX) = '',
	@PhoneNumber NVARCHAR(MAX) = '',
	@PhoneNumberConfirmed BIT = 0,
	@TwoFactorEnabled BIT = 0,
	@LockoutEndDateUtc DATETIMEOFFSET = '',
	@LockoutEnabled BIT = 0,
	@AccessFailedCount INT = 0,
	@UserName NVARCHAR(512) = '',
AS
BEGIN
	SET TRANSACTION ISOLATION LEVEL SNAPSHOT

	INSERT INTO BackOfficeUser
					(
						Email, EmailConfirmed, PasswordHash, 
						SecurityStamp, PhoneNumber, PhoneNumberConfirmed, TwoFactorEnabled, 
						LockoutEndDateUtc, LockoutEnabled, AccessFailedCount , UserName,
						 CreateDate,  ModifyDate, IsDeleted
					)
					VALUES
					(
						@Email, @EmailConfirmed, @PasswordHash, 
						@SecurityStamp, @PhoneNumber, @PhoneNumberConfirmed, @TwoFactorEnabled, 
						@LockoutEndDateUtc, @LockoutEnabled, @AccessFailedCount , @UserName,
						 @CreateDate, @ModifyDate, @IsDeleted
					)

	SELECT @@IDENTITY
END
	 
