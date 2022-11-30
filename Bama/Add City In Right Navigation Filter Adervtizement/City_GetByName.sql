CREATE PROCEDURE [dbo].[City_GetByName]
	@Name NVARCHAR(50) = ''
AS 
BEGIN
	SELECT * 
	FROM City c WITH(nolock)
	WHERE c.CityName = @Name; 
END
