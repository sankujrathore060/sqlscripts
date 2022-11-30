---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- QueuedSMSOTP_GetById
-- ***********************************************************************************************
-- SP NAME: QueuedSMSOTP_GetById
-- DESCRIPTION: get record for queued sms otp that sent to user
-- CREATED: VIPUL KAVA on 10Aug2021
-- MODIFICATION LOG:
-- ***********************************************************************************************
CREATE PROCEDURE [dbo].[QueuedSMSOTP_GetById]
(
	@QueuedSMSOTPId AS INT
)
AS
BEGIN
		SET NOCOUNT ON;
		SET TRANSACTION ISOLATION LEVEL SNAPSHOT;

		SELECT *
		FROM [QueuedSMSOTP] WITH(NOLOCK)
		WHERE QueuedSMSOTPId = @QueuedSMSOTPId;
END;

