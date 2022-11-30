---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- [dbo].[QueuedSMSOTP_SentToday_User] '09101010101', 'mashinchi'
ALTER PROCEDURE [dbo].[QueuedSMSOTP_SentToday_User]
(
    @CellNumber AS NVARCHAR(50),
	@WebsiteName AS NVARCHAR(50)
)
AS
BEGIN
		SET NOCOUNT ON;
		SET TRANSACTION ISOLATION LEVEL SNAPSHOT;

		DECLARE @CountSentToday INT,
				@LastSentDateTime DATETIME,
				@LastVerifiedSentDateTime DATETIME
	
		SELECT TOP 1
			@LastVerifiedSentDateTime = ModifiedDate
		FROM 
			[QueuedSMSOTP] WITH(NOLOCK)
		WHERE 
			ToNumber = @CellNumber
			AND CAST(ModifiedDate AS DATE) = CAST(GETDATE() AS DATE)
			AND ISNULL(WebsiteName, '') = ISNULL(@WebsiteName, '')
			AND ISNULL(IsCompleted, 0) = 1
		ORDER BY
			ModifiedDate DESC;

		SELECT 
			@CountSentToday = COUNT(*)
		FROM 
			[QueuedSMSOTP] WITH(NOLOCK)
		WHERE 
			ToNumber = @CellNumber
			AND CAST(ModifiedDate AS DATE) = CAST(GETDATE() AS DATE)
			AND ISNULL(WebsiteName, '') = ISNULL(@WebsiteName, '')
			AND (@LastVerifiedSentDateTime IS NULL OR ModifiedDate > @LastVerifiedSentDateTime);

		SELECT TOP 1
			@LastSentDateTime = ModifiedDate
		FROM 
			[QueuedSMSOTP] WITH(NOLOCK)
		WHERE 
			ToNumber = @CellNumber
			AND CAST(ModifiedDate AS DATE) = CAST(GETDATE() AS DATE)
			AND ISNULL(WebsiteName, '') = ISNULL(@WebsiteName, '')
			AND (@LastVerifiedSentDateTime IS NULL OR ModifiedDate > @LastVerifiedSentDateTime)
		ORDER BY
			ModifiedDate DESC;

		SELECT 
			@CountSentToday as CountSentToday,
			@LastSentDateTime as LastSentDateTime
END;
