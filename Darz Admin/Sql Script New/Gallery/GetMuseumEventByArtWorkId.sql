-- GetAssignMuseumEventByArtWorkId
CREATE PROCEDURE [dbo].[GetMuseumEventByArtWorkId] 
	@Id INT = NULL
AS
BEGIN
    SET NOCOUNT ON;
    SET TRANSACTION ISOLATION LEVEL SNAPSHOT;

    SELECT
        m.*,
		m.Id as MuseumId,
		mea.Id as Id
    FROM
        Museum AS m
		INNER JOIN dbo.MuseumEvents As me ON m.Id = me.MuseumId
        INNER JOIN dbo.MuseumEventArtworks mea ON mea.MuseumEventId = me.Id AND ISNULL(mea.IsAssigned, 0) = 1
    WHERE
        mea.ArtWorkId = @Id;
END;
