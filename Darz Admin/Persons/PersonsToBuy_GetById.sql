CREATE PROCEDURE [dbo].[PersonsToBuy_GetById]
	@Id int = 0
AS
BEGIN
	SET TRANSACTION ISOLATION LEVEL SNAPSHOT
	SET NOCOUNT ON;

	SELECT Mediums AS CommaSepratedMedium, Colors AS CommaSepratedColor, Styles AS CommaSepratedStyles, * 
	FROM PersonsToBuy 
	WHERE Id = @Id
END
