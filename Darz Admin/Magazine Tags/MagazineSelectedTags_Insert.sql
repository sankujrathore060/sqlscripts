CREATE PROCEDURE [dbo].[MagazineSelectedTags_Insert]
	@MagazineId INT,
	@MagazineTagId INT
AS 
BEGIN
	SET TRANSACTION ISOLATION LEVEL SNAPSHOT;

	INSERT INTO MagazineSelectedTags(MagazineId, MagazineTagId, CreatedDate)
	VALUES (@MagazineId, @MagazineTagId, GETDATE())

	SELECT @@IDENTITY
END