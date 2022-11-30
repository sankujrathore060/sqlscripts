ALTER PROCEDURE [Mashinchi].[proc_PublicHoliday_Delete]
(
	@PublicHolidayId INT = 0	
)
AS
BEGIN
		SET TRANSACTION ISOLATION LEVEL SNAPSHOT;
		SET NOCOUNT ON;

		DELETE FROM [Mashinchi].[PublicHoliday]
		WHERE PublicHolidayId = @PublicHolidayId 
END;
