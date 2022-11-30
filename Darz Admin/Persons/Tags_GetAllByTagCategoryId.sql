ALTER PROCEDURE [dbo].[Tags_GetAllByTagCategoryId]
	@TagCategoryId int = 0
AS
BEGIN
	SET TRANSACTION ISOLATION LEVEL SNAPSHOT
	SET NOCOUNT ON;
	SELECT TagName as Name, TagId as Id, * FROM Tags  WHERE TagCategoryId = @TagCategoryId
END