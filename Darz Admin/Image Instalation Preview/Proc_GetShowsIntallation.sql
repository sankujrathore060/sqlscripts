ALTER PROCEDURE [dbo].[Proc_GetShowsIntallation]
	@eventId INT
AS
BEGIN
	SET NOCOUNT ON;
	SET TRANSACTION ISOLATION LEVEL SNAPSHOT;

    SELECT
        ROW_NUMBER() OVER (ORDER BY install.ModifiedDate DESC) AS row,
		install.Id,
		install.FileName,
        install.InstallationPicture,
        install.InstallPictureHeight,
        install.InstallPictureWidth,
		install.InstallationInfo
    FROM
        ShowsInstallation install WITH(NOLOCK)
        INNER JOIN GalleryEvent ge WITH(NOLOCK) ON ge.Id = install.GalleryEventId
    WHERE
        ge.Id = @eventId;
END;
