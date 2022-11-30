CREATE PROCEDURE [dbo].[MagazineTagCategory_Update]
	@Id INT,
	@Name NVARCHAR(50),
	@NameFa NVARCHAR(50)
AS 
BEGIN
	SET TRANSACTION ISOLATION LEVEL SNAPSHOT;

	UPDATE MagazineTagCategory 
	SET Name = @Name, NameFa = @NameFa
	WHERE Id = @Id
END
