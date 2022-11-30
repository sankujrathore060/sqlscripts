ALTER PROCEDURE [dbo].[Persons_InsertOrUpdate]
	@Id INT = 0,
	@Name NVARCHAR(50) = NULL,
	@NameFa NVARCHAR(50) = NULL,	
	@CreationDate DATETIME,
	@ModifiedDate DATETIME,
	@returnId INT OUTPUT
AS 
BEGIN
	SET TRANSACTION ISOLATION LEVEL SNAPSHOT;

	IF @Id > 0
	BEGIN		
		UPDATE Persons 
		SET Name = @Name, NameFa = @NameFa, ModifiedDate = @ModifiedDate
		WHERE Id = @Id
		SET @returnId = @Id
	END
	ELSE
	BEGIN	
		INSERT INTO Persons(Name, NameFa, CreationDate, ModifiedDate)
		VALUES (@Name, @NameFa, @CreationDate, @ModifiedDate)
		SET @returnId = @@IDENTITY
	END
	
	SELECT @returnId
END