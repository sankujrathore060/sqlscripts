CREATE PROCEDURE [dbo].[ArtistLongBioBodyImageList_InsertUpdate]
    @Id INT = 0,  
    @ArtistId INT = 0,	
	@ArtistLongBioId INT = 0,	
	@ImageLink NVARCHAR(MAX) = '',
	@ImageWidth INT = 0,
	@ImageHeight INT = 0,
	@CreatedDate DATETIME = '',
	@StatementType INT = 1
AS
BEGIN
	IF @StatementType = 1
    BEGIN
		INSERT INTO ArtistLongBioBodyImageList(ArtistLongBioId, ArtistId, ImageLink, ImageWidth, ImageHeight, CreatedDate)
		VALUES (@ArtistLongBioId, @ArtistId, @ImageLink, @ImageWidth, @ImageHeight, @CreatedDate)
	END
	ELSE
	BEGIN
		UPDATE ArtistLongBioBodyImageList
		SET 
			ArtistLongBioId = @ArtistLongBioId,
			ArtistId = @ArtistId,
			ImageLink = @ImageLink,
			ImageWidth = @ImageWidth,
			ImageHeight = @ImageHeight,
			CreatedDate = @CreatedDate
		WHERE
			ArtistLongBioBodyImageListId = @Id
	END
END;
