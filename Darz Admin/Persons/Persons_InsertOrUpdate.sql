ALTER PROCEDURE [dbo].[Persons_InsertOrUpdate]
	@Id INT = 0,
	@Name NVARCHAR(50) = NULL,
	@NameFa NVARCHAR(50) = NULL,
	@FamilyName NVARCHAR(100) = null,
	@FamilyNameFa NVARCHAR(100) = null,
	@Email NVARCHAR(200) = null,
	@Phone NVARCHAR(100) = null,
	@IsDealer BIT = 0,
	@CreationDate DATETIME,
	@ModifiedDate DATETIME,
	@returnId INT OUTPUT
AS 
BEGIN
	SET TRANSACTION ISOLATION LEVEL SNAPSHOT;

	IF @Id > 0
	BEGIN		
		UPDATE Persons 
		SET Name = @Name, NameFa = @NameFa, ModifiedDate = @ModifiedDate,
		FamilyName = @FamilyName, FamilyNameFa = @FamilyNameFa, Email = @Email, Phone = @Phone, IsDealer = @IsDealer
		WHERE Id = @Id
		SET @returnId = @Id
	END
	ELSE
	BEGIN	
		INSERT INTO Persons(Name, NameFa, FamilyName, FamilyNameFa, Email, Phone, IsDealer, CreationDate, ModifiedDate)
		VALUES (@Name, @NameFa, @FamilyName, @FamilyNameFa, @Email, @Phone, @IsDealer, @CreationDate, @ModifiedDate)
		SET @returnId = @@IDENTITY
	END
	
	SELECT @returnId
END