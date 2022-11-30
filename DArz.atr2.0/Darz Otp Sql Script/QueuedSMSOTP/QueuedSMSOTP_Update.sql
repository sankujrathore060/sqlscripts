ALTER PROCEDURE [dbo].[QueuedSMSOTP_Update]
(
    @QueuedSMSOTPId AS INT,
    @IsVerified as bit,
    @ModifiedDate AS DATETIME
)
AS
BEGIN
		SET NOCOUNT ON;

		UPDATE
			[QueuedSMSOTP]
		SET 
			[IsVerified] = @IsVerified,
			[IsCompleted] = @IsCompleted,
			[Message] = @Message,
			[ModifiedDate] = GETDATE()
		WHERE 
			QueuedSMSOTPId = @QueuedSMSOTPId;
END;