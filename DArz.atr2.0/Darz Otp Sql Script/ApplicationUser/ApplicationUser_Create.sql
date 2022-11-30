---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
CREATE PROCEDURE [dbo].[ApplicationUser_Create]
	@UserId uniqueidentifier,
	@UserName nvarchar(256),
	@Email nvarchar(256),
	@EmailConfirmed bit,
	@PasswordHash nvarchar(max),
	@SecurityStamp nvarchar(max),
	@PhoneNumber nvarchar(max),
	@PhoneNumberConfirmed bit,	
	@Name nvarchar(250),	
	@Password nvarchar(max),
	@Country nvarchar(256),
	@Profession nvarchar(256)
AS
BEGIN
		SET NOCOUNT ON;

		-- USER
		INSERT INTO [dbo].[ApplicationUser]([UserId], [Email], [EmailConfirmed], [PasswordHash], [SecurityStamp],
										[PhoneNumber], [PhoneNumberConfirmed], [UserName], [Name],
										[CreateBy], [ModifyBy], [CreateDate], [ModifyDate], 
										[Password], [Country], [Profession])
						VALUES(@UserId, @Email, @EmailConfirmed, @PasswordHash, @SecurityStamp, 
										@PhoneNumber, @PhoneNumberConfirmed, @UserName, @Name,
										@UserId, @UserId, GETDATE(), GETDATE(), 
										@Password, @Country, @Profession);

		-- PROFILE
		INSERT INTO [dbo].[ApplicationUserProfile]([UserId], [CreateBy], [ModifyBy], [FirstName], [LastName])
						VALUES(@UserId, @UserId, @UserId, @UserName, @UserName);
END