ALTER PROCEDURE [dbo].[MagazineSource_Update]
		@Id INT = 0,
		@MagazineId INT = 0,
		@SourceLink NVARCHAR(MAX) = ''
AS
BEGIN
	SET TRANSACTION ISOLATION LEVEL SNAPSHOT;
		
	UPDATE MagazineSource
	SET 
		MagazineId = @MagazineId,
		SourceLink = @SourceLink,
		CreatedDate = GETDATE()
	WHERE 
		Id = @Id 
END

