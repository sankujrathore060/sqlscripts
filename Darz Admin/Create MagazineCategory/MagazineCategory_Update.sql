ALTER PROCEDURE [dbo].[MagazineCategory_Update]
	@Id INT = 0,
    @Name NVARCHAR(50),
    @NameFa NVARCHAR(50),
    @ModifiedDate DATETIME,
    @rowguid UNIQUEIDENTIFIER,
    @StatementType TINYINT = 0,
	@OrderInSeries INT = 1000,
	@IsActive BIT = 0,
	@ParentCategoryId INT = 0
AS
BEGIN
	SET NOCOUNT ON;
	
	UPDATE MagazineCategory
	SET [Name] = @Name, [NameFa] = @NameFa, 
		[ModifiedDate] = @ModifiedDate, [rowguid] = @rowguid,
		[OrderInSeries] = @OrderInSeries, [IsActive] = @IsActive,
		[ParentCategoryId] = @ParentCategoryId
	WHERE Id = @Id

END
