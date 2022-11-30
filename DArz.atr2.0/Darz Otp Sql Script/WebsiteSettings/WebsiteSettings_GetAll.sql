CREATE PROCEDURE [dbo].[WebsiteSettings_GetAll]
AS
BEGIN
    SET NOCOUNT ON;
    SET TRANSACTION ISOLATION LEVEL SNAPSHOT;
    SELECT
        *
    FROM
        [dbo].[WebsiteSettings]
    ORDER BY
        Id DESC;

END;
