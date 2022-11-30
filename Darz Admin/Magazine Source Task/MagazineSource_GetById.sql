ALTER PROCEDURE [dbo].[MagazineSource_GetById]
		@Id INT = 0
AS
BEGIN
	SET TRANSACTION ISOLATION LEVEL SNAPSHOT;
		
	SELECT * 
	FROM MagazineSource WITH(NOLOCK)
	WHERE MagazineId = @Id  
END