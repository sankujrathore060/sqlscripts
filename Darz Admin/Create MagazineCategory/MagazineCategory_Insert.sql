CREATE PROCEDURE [dbo].[MagazineCategory_Insert]
    @Name NVARCHAR(50),
    @NameFa NVARCHAR(50),
    @ModifiedDate DATETIME,
    @rowguid UNIQUEIDENTIFIER,
    @StatementType TINYINT = 0,
    @returnId INT = 0,
	@OrderInSeries INT = 1000,
	@IsActive BIT = 0,
	@ParentCategoryId INT = 0
AS
BEGIN
	SET NOCOUNT ON;
	
	INSERT INTO MagazineCategory ([Name], [Namefa], [ModifiedDate], [rowguid], [OrderInSeries], [IsActive],[ParentCategoryId])
	VALUES (@Name, @NameFa, @ModifiedDate, @rowguid, @OrderInSeries, @IsActive, @ParentCategoryId);

	SET @returnId = SCOPE_IDENTITY();

	RETURN @returnId;
END
