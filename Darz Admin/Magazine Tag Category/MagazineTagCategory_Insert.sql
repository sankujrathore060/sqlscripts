ALTER PROCEDURE [dbo].[MagazineTagCategory_Insert]
	@Name NVARCHAR(50),
	@NameFa NVARCHAR(50),
	@CreationDate DATETIME 
AS 
BEGIN
	SET TRANSACTION ISOLATION LEVEL SNAPSHOT;

	INSERT INTO MagazineTagCategory(Name, NameFa, CreationDate)
	VALUES (@Name, @NameFa, @CreationDate)

	SELECT @@IDENTITY
END