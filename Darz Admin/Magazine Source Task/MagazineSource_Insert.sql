CREATE PROCEDURE [dbo].[MagazineSource_Insert]
		@MagazineId INT = 0,
		@SourceLink NVARCHAR(MAX) = ''
AS
BEGIN
	SET TRANSACTION ISOLATION LEVEL SNAPSHOT;

	INSERT INTO MagazineSource(MagazineId, SourceLink, CreatedDate)
	VALUES (@MagazineId, @SourceLink, GETDATE())
	
	SELECT @@IDENTITY
END