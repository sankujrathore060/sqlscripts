---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- QueuedSMSOTP_ValidateOTP 09464656454, 4999
-- ***********************************************************************************************
-- SP NAME: QueuedSMSOTP_ValidateOTP
-- DESCRIPTION: get record after validate otp with cell number and otp that enter by user
-- CREATED: VIPUL KAVA on 13Aug2021
-- MODIFICATION LOG:
-- ***********************************************************************************************
ALTER PROCEDURE [dbo].[QueuedSMSOTP_ValidateOTP]
(
	@CellNumber as nvarchar(20),
	@OTP as int
)
AS
BEGIN
		SET NOCOUNT ON;
		SET TRANSACTION ISOLATION LEVEL SNAPSHOT;

		DECLARE @QueuedSMSOTPId int = 0;
		
		SELECT 
			@QueuedSMSOTPId = QueuedSMSOTPId
		FROM 
			[QueuedSMSOTP] WITH(NOLOCK)
		WHERE 
			[ToNumber] = @CellNumber
			and OTP = @OTP
			and IsVerified=0
			and ValidTillDateTime >= GETDATE();

		IF(@QueuedSMSOTPId > 0)
		BEGIN
				UPDATE [QueuedSMSOTP] SET [IsVerified] = 1 WHERE QueuedSMSOTPId = @QueuedSMSOTPId;
		END

		SELECT * FROM [QueuedSMSOTP] WITH(NOLOCK) WHERE QueuedSMSOTPId = @QueuedSMSOTPId;
END;



