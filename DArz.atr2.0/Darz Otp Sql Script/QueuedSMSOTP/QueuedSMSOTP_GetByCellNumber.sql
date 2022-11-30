
---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- QueuedSMSOTP_GetByCellNumber
-- ***********************************************************************************************
-- SP NAME: QueuedSMSOTP_GetByCellNumber
-- DESCRIPTION: get last record for queued sms otp that sent to user using cell number
-- CREATED: VIPUL KAVA on 13Aug2021
-- MODIFICATION LOG:
-- ***********************************************************************************************
CREATE PROCEDURE [dbo].[QueuedSMSOTP_GetByCellNumber]
(
	@CellNumber AS nvarchar(20)
)
AS
BEGIN
		SET NOCOUNT ON;
	SET TRANSACTION ISOLATION LEVEL SNAPSHOT;	

		SELECT 
			TOP 1 *
		FROM 
			[QueuedSMSOTP]
		WHERE 
			[ToNumber] = @CellNumber
		ORDER BY 
			QueuedSMSOTPId DESC
END;