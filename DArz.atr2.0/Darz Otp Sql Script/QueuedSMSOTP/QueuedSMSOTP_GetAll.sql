
---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- QueuedSMSOTP_GetAll
-- ***********************************************************************************************
-- SP NAME: QueuedSMSOTP_GetAll
-- DESCRIPTION: get all records for queued sms otp that sent to user
-- CREATED: VIPUL KAVA on 13Aug2021
-- MODIFICATION LOG:
-- ***********************************************************************************************
CREATE PROCEDURE [dbo].[QueuedSMSOTP_GetAll] (@IsCompleted BIT = NULL)
AS
BEGIN
    SET NOCOUNT ON;
    SET TRANSACTION ISOLATION LEVEL SNAPSHOT;

    SELECT
        *
    FROM
        [QueuedSMSOTP] WITH(NOLOCK)
    WHERE
        (@IsCompleted IS NULL OR IsCompleted = @IsCompleted)
    ORDER BY
        QueuedSMSOTPId;
END;