ALTER PROCEDURE [dbo].[proc_GetArtworkPremiumShowByEventAndArtWorkId]
	@GalleryEventId int = 0,
	@ArtWorkId int = 0
AS
BEGIN
		SET TRANSACTION ISOLATION LEVEL SNAPSHOT;
		SET NOCOUNT ON;

		SELECT
			@GalleryEventId AS Id,
			(CASE
				 WHEN a.FirstName IS NULL
					  AND a.LastName IS NULL THEN
					 a.Nickname
				 ELSE
					 LTRIM(RTRIM(a.FirstName)) + ' ' + LTRIM(RTRIM(a.LastName))
			 END
			) AS ArtistName,
			(CASE
				 WHEN a.FirstNameFa IS NULL
					  AND a.LastNameFa IS NULL THEN
					 a.NicknameFa
				 ELSE
					 LTRIM(RTRIM(a.FirstNameFa)) + ' ' + LTRIM(RTRIM(a.LastNameFa))
			 END
			) AS ArtistNameFa,
			LTRIM(RTRIM(a.FirstName)) AS FirstName,
			LTRIM(RTRIM(a.LastName)) AS LastName,
			LTRIM(RTRIM(a.Nickname)) AS NickName,
			-- dbo.fn_ArtworkSize(ar.Height, ar.Width, ar.Depth) AS Size,
			ar.Height, 
			ar.Width, 
			ar.Depth,
			ar.[Length],
			ar.SizeUnit, 
			ar.ArtistId,
			ar.Medium,
			ar.MediumFa,
			a.BornYear,
			a.DieYear,
			a.BornYearFa,
			a.DieYearFa,
			a.Id AS ArtistId,
			ar.Id AS ArtworkId,
			ar.Title,
			ar.TitleFa,
			ar.CreationYear,
			ar.CreationYearFa,
			ar.Category,
			ar.Picture,
			ar.ImageHeight,
			ar.ImageWidth,
			ar.Collaboration,
			ar.CollaborationFa,
			ar.LastStatusDescription,   
			ar.LastStatusDescriptionFa, 
			ar.Description,
			ar.DescriptionFa,
			a.VerificationStatus AS Artist_VerificationStatus,			
			ga.Price AS Artwork_Price,
			ga.Currency AS Artwork_Currency,
			ga.IsSold AS Artwork_IsSold
		FROM
			GalleryEventArtwork AS ga WITH(NOLOCK)
			INNER JOIN vw_Artwork AS ar WITH(NOLOCK) ON ar.Id = ga.ArtworkId
			INNER JOIN Artist AS a WITH(NOLOCK) ON a.Id = ar.ArtistId
		WHERE
			ga.GalleryEventId = @galleryEventId
			AND ar.Picture IS NOT NULL
			AND ga.ArtworkId = @ArtWorkId
END
