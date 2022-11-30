
ALTER PROCEDURE [Mashinchi].[proc_PublicHoliday_Update]
	@PublicHolidayId INT,
	@StrHolidayDate NVARCHAR(80),
	@IsActive BIT,
	@Description NVARCHAR(255) 
AS
BEGIN
	SET NOCOUNT ON;

	UPDATE Mashinchi.PublicHoliday
	SET HolidayDate = CAST(@StrHolidayDate AS DATE), IsActive = @IsActive, Description = @Description, CreatedDate = GetDate()
	WHERE PublicHolidayId = @PublicHolidayId
END