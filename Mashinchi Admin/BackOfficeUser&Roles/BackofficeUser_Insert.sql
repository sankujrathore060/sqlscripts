CREATE PROCEDURE [dbo].[BackofficeUser_Insert]
(
    @UserName AS NVARCHAR(50),
    @Email AS NVARCHAR(256) = NULL,
    @Password AS NVARCHAR(256) = NULL,
    @PasswordSalt AS NVARCHAR(MAX) = NULL,
    @Name AS NVARCHAR(50) = NULL,
    @IsActive AS BIT = 1,
    @CreationDate AS DATETIME = NULL,
    @LastSuccessfulLoginTime AS DATETIME = NULL,
    @LoginAttemptCount AS INT = NULL,
    @IsLocked AS BIT = NULL,
    @LastLockingTime AS DATETIME = NULL,
    @ModifiedDate AS DATETIME = getdate,
    @rowguid AS UNIQUEIDENTIFIER = newid,
    @ModerateAdmin AS BIT = NULL,
    @NormalizedUserName AS NVARCHAR(256) = NULL,
    @NormalizedEmail AS NVARCHAR(256) = NULL,
	@IsMashinchiAdmin AS BIT = 0
)
AS
BEGIN
    SET NOCOUNT ON;

    INSERT [Clients].[BackofficeUser] ([UserName], [Email], [Password], [PasswordSalt], [Name], [IsActive],
    [CreationDate], [LastSuccessfulLoginTime], [LoginAttemptCount], [IsLocked], [LastLockingTime], [ModifiedDate],
    [rowguid], [ModerateAdmin], [NormalizedUserName], [NormalizedEmail], [IsMashinchiAdmin])
    VALUES (
        @UserName, @Email, @Password, @PasswordSalt, @Name, @IsActive, @CreationDate, @LastSuccessfulLoginTime,
        @LoginAttemptCount, @IsLocked, @LastLockingTime, @ModifiedDate, @rowguid, @ModerateAdmin, @NormalizedUserName,
        @NormalizedEmail, @IsMashinchiAdmin
    );

    -- Return the new ID
    SELECT
        SCOPE_IDENTITY();
END;