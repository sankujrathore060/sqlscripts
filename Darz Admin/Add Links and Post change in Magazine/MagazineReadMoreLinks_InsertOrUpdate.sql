CREATE PROCEDURE [dbo].[MagazineReadMoreLinks_InsertOrUpdate]
	@Id INT = 0,
	@MagazineId INT = 0,	
	@Title NVARCHAR(MAX) = '',	
	@TitleFa NVARCHAR(MAX) = '',
	@Link NVARCHAR(MAX) = '',
	@ModifiedDate DATETIME
AS
BEGIN
	SET TRANSACTION ISOLATION LEVEL SNAPSHOT;

	IF @Id > 0
	BEGIN			
		UPDATE MagazineReadMoreLinks 
		SET MagazineId = @MagazineId, Title = @Title, TitleFa = @TitleFa, Link = @Link, ModifiedDate = @ModifiedDate
		WHERE Id = @Id
	END
	ELSE
	BEGIN	
		INSERT INTO MagazineReadMoreLinks(MagazineId, Title, TitleFa, Link, ModifiedDate)
		VALUES (@MagazineId, @Title, @TitleFa, @Link, @ModifiedDate)
	END
END