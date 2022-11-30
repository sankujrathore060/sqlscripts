CREATE PROCEDURE [dbo].[BackofficeUser_Update]
(
    @BackofficeUserID AS INT,
    @UserName AS NVARCHAR(50),
    @Email AS NVARCHAR(256) = NULL,
    @Name AS NVARCHAR(50) = NULL,
    @IsActive AS BIT = 1,
    @LastSuccessfulLoginTime AS DATETIME = NULL,
    @LoginAttemptCount AS INT = NULL,
    @IsLocked AS BIT = NULL,
    @LastLockingTime AS DATETIME = NULL,
    @ModifiedDate AS DATETIME = GETDATE,
    @ModerateAdmin AS BIT = 0, -- added on 18-JAN-2018
	@IsMashinchiAdmin AS BIT = 0
)
AS
BEGIN
    SET NOCOUNT ON;

    UPDATE
        [Clients].[BackofficeUser]
    SET
        [UserName] = @UserName,
        [Email] = @Email,
        [Name] = @Name,
        [IsActive] = @IsActive,
        [LastSuccessfulLoginTime] = @LastSuccessfulLoginTime,
        [LoginAttemptCount] = @LoginAttemptCount,
        [IsLocked] = @IsLocked,
        [LastLockingTime] = @LastLockingTime,
        [ModifiedDate] = @ModifiedDate,
        [ModerateAdmin] = @ModerateAdmin, -- added on 18-JAN-2018
		[IsMashinchiAdmin] = @IsMashinchiAdmin
    WHERE
        BackofficeUserID = @BackofficeUserID; -- Return the ID
USE BAMA