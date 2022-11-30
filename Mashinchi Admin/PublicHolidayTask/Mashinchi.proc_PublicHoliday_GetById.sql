ALTER PROCEDURE [Mashinchi].[proc_PublicHoliday_GetById]
	@PublicHolidayId INT = 0
AS
BEGIN
	SET TRANSACTION ISOLATION LEVEL SNAPSHOT

	SELECT * 
	FROM Mashinchi.PublicHoliday WITH(NOLOCK)
	WHERE PublicHolidayId = @PublicHolidayId
END