CREATE PROCEDURE [dbo].[Persons_DeleteById]
	@Id INT = 0
AS
BEGIN
	SET TRANSACTION ISOLATION LEVEL SNAPSHOT;
	
	DELETE FROM Persons
	WHERE (ISNULL(@Id,0) = 0 OR (Id = @Id))
END