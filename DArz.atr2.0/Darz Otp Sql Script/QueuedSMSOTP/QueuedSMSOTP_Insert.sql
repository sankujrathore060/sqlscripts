---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- QueuedSMSOTP_Insert
-- **************************************************************************************************************************************************************
-- SP NAME: QueuedSMSOTP_Insert
-- DESCRIPTION: insert record for queued sms otp that sent to user
-- CREATED: VIPUL KAVA on 13Aug2021
-- MODIFICATION LOG:
--		* NO NEED TO UPDATE THE RECORDS - WE DO NOT GET CORRECT COUNT FOR SENT SMS - DISCUSS WITH VISHAL - VIPUL KAVA 18Jan2019
--		* Added Conditions if user is attempting to resend otp with less than passed seconds then it will return -1
--		 				   if user is attempting to send otp with same cell number for more than @NoOfSMSOTPForSameNumberInDay numbers then it will return -2
--						   if user is attempting to send otp with same ip address for more than @@NoOfSMSOTPForSameIPAddressInDay numbers then it will return -3
--																										 - VISHAL PAREKH 20Jan2019
-- **************************************************************************************************************************************************************
CREATE PROCEDURE [dbo].[QueuedSMSOTP_Insert]
(
    @FromNumber AS NVARCHAR(50),
    @ToNumber AS NVARCHAR(50),
    @OTP AS INT,
    @IsVerified AS BIT,
    @IsCompleted AS BIT,
    @Message AS NVARCHAR(MAX) = NULL,
    @ValidTillDateTime AS DATETIME,
    @SMSFor AS TINYINT,
    @ModifiedDate AS DATETIME,
    @IPAddress AS CHAR(15),
    @AllowedDelayForContinuousSMSOTP AS INT, -- In Seconds
    @NoOfSMSOTPForSameNumberInDay AS INT,
    @NoOfSMSOTPForSameIPAddressInDay AS INT,
	@WebsiteName AS VARCHAR(20) = NULL
)
AS
BEGIN
	SET NOCOUNT ON;

    SET TRANSACTION ISOLATION LEVEL SNAPSHOT;

    DECLARE @LastSMSOTPSentForSameCellNumber DATETIME;
    DECLARE @TotalSMSOTPSentForSameCellNumberInDay INT;
    DECLARE @TotalSMSOTPSentForSameIPAddressInDay INT;

    SELECT 
		@LastSMSOTPSentForSameCellNumber = ModifiedDate
    FROM 
		[QueuedSMSOTP] WITH(NOLOCK)
    WHERE 
		ToNumber = @ToNumber
		AND CAST(ModifiedDate AS DATE) = CAST(GETDATE() AS DATE)
		AND ISNULL(WebsiteName, '') = ISNULL(@WebsiteName, '');

    SELECT 
		@TotalSMSOTPSentForSameCellNumberInDay = COUNT(1)
    FROM 
		[QueuedSMSOTP] WITH(NOLOCK)
    WHERE 
		ToNumber = @ToNumber
        AND CAST(ModifiedDate AS DATE) = CAST(GETDATE() AS DATE)
		AND ISNULL(WebsiteName, '') = ISNULL(@WebsiteName, '');

    SELECT 
		@TotalSMSOTPSentForSameIPAddressInDay = COUNT(1)
    FROM 
		[QueuedSMSOTP] WITH(NOLOCK)
    WHERE 
		IPAddress = @IPAddress
        AND CAST(ModifiedDate AS DATE) = CAST(GETDATE() AS DATE)
		AND ISNULL(WebsiteName, '') = ISNULL(@WebsiteName, '');

	--IF (DATEDIFF(SECOND, @LastSMSOTPSentForSameCellNumber, GETDATE()) < @AllowedDelayForContinuousSMSOTP)
	--BEGIN
	--	SELECT -1;
	--END;	 
	--ELSE 
	IF (@TotalSMSOTPSentForSameCellNumberInDay >= @NoOfSMSOTPForSameNumberInDay)
    BEGIN
			SELECT -2;
    END;
    ELSE IF (@TotalSMSOTPSentForSameIPAddressInDay >= @NoOfSMSOTPForSameIPAddressInDay)
    BEGIN
			SELECT -3;
    END;

    ELSE
    BEGIN

		UPDATE [QueuedSMSOTP] SET IsVerified = 1 WHERE ToNumber = @ToNumber AND OTP != @OTP AND ISNULL(WebsiteName, '') = ISNULL(@WebsiteName, '');

        INSERT [QueuedSMSOTP]([FromNumber], [ToNumber], [OTP], [Message], [IsVerified], [IsCompleted], [ValidTillDateTime], 
								[SMSFor], [ModifiedDate], IPAddress, WebsiteName)
							VALUES(@FromNumber, @ToNumber, @OTP, @Message, @IsVerified, @IsCompleted, @ValidTillDateTime, 
								@SMSFor, GETDATE(), @IPAddress, @WebsiteName);

        -- RETURN THE NEW ID
        SELECT SCOPE_IDENTITY();
    END;
END;