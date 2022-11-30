ALTER PROCEDURE [dbo].[MotorcycleReportAdBugs_Insert]
(
    @MotorcycleReportIssueID SMALLINT,
    @Comment NVARCHAR(MAX),
    @MotorcycleAdID INT,
    @UserID INT,
    @ModifiedDate DATETIME,
    @rowguid UNIQUEIDENTIFIER,
    @IsRead BIT,
    @IPAddress NVARCHAR(MAX),
    @AdminId INT,
    @IsDelete BIT,
	@CellNumber NVARCHAR(50) = NULL
)
AS
BEGIN
    SET NOCOUNT ON;

    INSERT INTO [Ad].[MotorcycleReportAdBugs] ([MotorcycleReportIssueID], [Comment], [MotorcycleAdID], [UserID],
                                               [ModifiedDate], [rowguid], [IsRead], [IPAddress], [AdminId], [IsDelete], [CellNumber])
    VALUES
    (@MotorcycleReportIssueID, @Comment, @MotorcycleAdID, @UserID, @ModifiedDate, @rowguid, @IsRead, @IPAddress,
     @AdminId, @IsDelete, @CellNumber);


    SELECT
        SCOPE_IDENTITY();

END;


