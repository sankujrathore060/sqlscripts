ALTER PROCEDURE [dbo].[GetAllMagazines] 
	@Id INT = 0,
	@Author NVARCHAR(50) = '',
	@Name NVARCHAR(50) = '',
	@Category INT = 0,
	@FromDate NVARCHAR(50) = '',
	@ToDate NVARCHAR(50) = ''
AS
BEGIN
    SET TRANSACTION ISOLATION LEVEL SNAPSHOT;
	
	SELECT * FROM Magazines WITH(nolock)
	WHERE (ISNULL(@Id,0)=0 OR(Id = @Id)) AND
	(ISNULL(@Author,'')='' OR(Author Like '%'+@Author+'%')) AND
	(ISNULL(@Name,'')='' OR(Name Like '%'+@Name+'%')) AND
	(ISNULL(@Category,0)=0 OR(Category = @Category)) AND
	((ISNULL(@FromDate,'') = '' OR ISNULL(@ToDate,'') = '')  OR(MagazineDate BETWEEN @FromDate AND @ToDate))
	ORDER BY ModifiedDate DESC
END;
