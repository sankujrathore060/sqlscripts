CREATE PROCEDURE [dbo].[MagazineSource_Delete]
		@Id INT = 0
AS
BEGIN
	SET TRANSACTION ISOLATION LEVEL SNAPSHOT;
	
	DELETE FROM MagazineSource
	WHERE Id  = @Id
END