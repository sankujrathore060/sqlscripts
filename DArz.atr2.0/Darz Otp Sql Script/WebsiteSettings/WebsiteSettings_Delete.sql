CREATE PROCEDURE [dbo].[WebsiteSettings_Delete] (@Id AS TINYINT)
AS
BEGIN
    SET NOCOUNT ON;

    DELETE FROM
    [dbo].[WebsiteSettings]
    WHERE
        Id = @Id;
-- Return the ID
END;

