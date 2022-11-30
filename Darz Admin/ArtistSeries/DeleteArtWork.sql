ALTER PROCEDURE [dbo].[DeleteArtWork] 
	@id int,
	@UserId uniqueidentifier = null
AS
BEGIN
	BEGIN TRANSACTION;
	BEGIN TRY
	DECLARE @ParentId INT
	
	INSERT INTO BackOfficeActivityLog
		SELECT @UserId,
		       @Id,
		       Title,
		       'ArtWork',
			   Picture AS ImageUrl,
		       3,
		       GETDATE(),
		       NULL,
		       NULL,
		       rowguid
		FROM   ArtWork
		WHERE  Id = @ID
		
		SELECT @ParentId = SCOPE_IDENTITY()
	
		SELECT * INTO #temp
		FROM   (
		           SELECT aea.Id    AS TitleID,
		                  (ae.Title)  AS Title,
		                  'Auction event artWork' AS PageName,
						  a.Picture AS ImageUrl,
		                  aea.rowguid
		           FROM   AuctionEventArtwork aea
				   inner join AuctionEvent ae on aea.AuctionEventId = ae.Id
				   inner join ArtWork a on aea.ArtworkId = a.Id
		           WHERE  aea.ArtworkId = @id

		           UNION

		           SELECT gea.Id AS TitleID,
		                  (ge.Title) AS Title,
		                  'Gallery event artWork' AS PageName,
						  a.Picture AS ImageUrl,
		                  gea.rowguid
		           FROM   GalleryEventArtwork gea
				   inner join GalleryEvent ge on gea.GalleryEventId = ge.Id
				   inner join ArtWork a on gea.ArtworkId = a.Id
		           WHERE  gea.ArtworkId = @id
		       ) AS tbl

		DELETE aga FROM ArtFairGalleryArtwork aga
		INNER JOIN ArtWork ar
		ON ar.Id=aga.ArtWorkId where ArtworkId = @id

		DELETE at FROM ArtWorkTag at
		INNER JOIN ArtWork ar
		ON ar.Id=at.ArtworkId
		WHERE ar.Id = @id

		DELETE aea FROM AuctionEventArtwork aea
		INNER JOIN ArtWork ar
		ON ar.Id=aea.ArtworkId
		WHERE ar.Id = @id

		DELETE at FROM FeaturedImageDimentions at
		INNER JOIN ArtWork ar
		ON ar.Id=at.ArtWorkId
		WHERE ar.Id = @id

		DELETE ga FROM GalleryEventArtwork ga
		INNER JOIN ArtWork ar
		ON ar.Id=ga.ArtWorkId
		WHERE ar.Id = @id

		DELETE ArtworkSeries WHERE ArtworkId = @id

		delete ArtWork where Id = @id

	INSERT INTO BackOfficeActivityLog
	SELECT @UserId,
		    TitleID,
		    CAST(Title AS NVARCHAR(200)),
		    PageName,
			ImageUrl,
		    3,
		    GETDATE(),
		    @ParentId,
		       NULL,
		    rowguid
	FROM   #temp
				
		
	END TRY
	BEGIN CATCH
		SELECT ERROR_NUMBER()     AS ErrorNumber,
		       ERROR_SEVERITY()   AS ErrorSeverity,
		       ERROR_STATE()      AS ErrorState,
		       ERROR_PROCEDURE()  AS ErrorProcedure,
		       ERROR_LINE()       AS ErrorLine,
		       ERROR_MESSAGE()    AS ErrorMessage;
		
		IF @@TRANCOUNT > 0
		    ROLLBACK TRANSACTION;
	END CATCH;
	
	IF @@TRANCOUNT > 0
	    COMMIT TRANSACTION
END