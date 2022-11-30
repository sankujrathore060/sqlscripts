ALTER PROCEDURE [dbo].[PersonsToBuy_InsertOrUpdate]
	@Id INT = 0,
	@PersonId INT = 0,
	@Deal INT = 0,
	@ArtistId INT = 0,
	@BudgetPrice INT = 0,
	@CommaSepratedMedium NVARCHAR(MAX) = '',
	@CommaSepratedColor NVARCHAR(MAX) = '',
	@CommaSepratedStyles NVARCHAR(MAX) = '',
	@Category INT = 0,
	@SizeUnit INT = 0,
	@Height NVARCHAR(100) = '0',
	@Width NVARCHAR(100) = '0',
	@Depth NVARCHAR(100) = '0',
	@Length NVARCHAR(100) = '0',
	@CreationDate DATETIME,
	@ModifiedDate DATETIME,
	@returnId INT OUTPUT
AS
BEGIN
	SET TRANSACTION ISOLATION LEVEL SNAPSHOT;

	IF @Id > 0
	BEGIN			
		UPDATE PersonsToBuy
		SET PersonId = @PersonId, Deal = @Deal, ArtistId = @ArtistId, BudgetPrice = @BudgetPrice,
			Mediums = @CommaSepratedMedium, Colors = @CommaSepratedColor, Styles = @CommaSepratedStyles,
			Category = @Category, SizeUnit = @SizeUnit, Height = @Height, Width = @Width, Depth = @Depth, Length = @Length, ModifiedDate = @ModifiedDate	
		WHERE Id = @Id
		SET @returnId = @Id;
	END
	ELSE
	BEGIN	
		INSERT INTO PersonsToBuy(PersonId, Deal, ArtistId, BudgetPrice,
				Mediums, Colors, Styles,Category, SizeUnit, Height, Width, Depth, Length, ModifiedDate, CreationDate)
		VALUES (@PersonId, @Deal, @ArtistId, @BudgetPrice,
				@CommaSepratedMedium, @CommaSepratedColor, @CommaSepratedStyles, @Category, @SizeUnit, @Height, @Width, @Depth, @Length, @ModifiedDate, @CreationDate)
		SET @returnId = @@IDENTITY
	END
	
	SELECT @returnId
END