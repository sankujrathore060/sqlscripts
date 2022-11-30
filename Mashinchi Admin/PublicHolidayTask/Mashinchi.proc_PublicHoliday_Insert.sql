ALTER PROCEDURE [Mashinchi].[proc_PublicHoliday_Insert]
	@StrHolidayDate NVARCHAR(20),
	@IsActive BIT,
	@Description NVARCHAR(255) 
AS
BEGIN
	SET NOCOUNT ON;

	INSERT INTO Mashinchi.PublicHoliday(HolidayDate, IsActive, Description, CreatedDate)
	VALUES (CAST(@StrHolidayDate AS DATE), @IsActive, @Description, GetDate())

	SELECT @@IDENTITY;
END

