ALTER PROCEDURE [dbo].[DeleteMagazine] 
	@id INT
AS
BEGIN
	SET TRANSACTION ISOLATION LEVEL SNAPSHOT;

	DELETE FROM 
	dbo.MagazineSelectedTags
	WHERE MagazineId = @id

    DELETE FROM
    dbo.Magazines
    WHERE
        Id = @id;
END;