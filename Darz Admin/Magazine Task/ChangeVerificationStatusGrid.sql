
ALTER PROCEDURE [dbo].[ChangeVerificationStatusGrid]
	@Id INT,
	@Status INT,
	@PageName VARCHAR(150)
AS
BEGIN
	SET TRANSACTION ISOLATION LEVEL SNAPSHOT
	SET NOCOUNT ON;

	IF(@PageName = 'Gallery')
	BEGIN
			UPDATE dbo.Gallery SET VerificationStatus = @Status WHERE Id = @Id
			-- SELECT 1
	END
	ELSE IF(@PageName = 'GalleryEvent')
	BEGIN
			UPDATE dbo.GalleryEvent SET VerificationStatus = @Status WHERE Id = @Id
			-- SELECT 1
	END
	ELSE IF(@PageName = 'Auction')
	BEGIN
			UPDATE dbo.AuctionHouse SET VerificationStatus = @Status WHERE Id = @Id
			-- SELECT 1
	END
	ELSE IF(@PageName = 'AuctionEvent')
	BEGIN
			UPDATE dbo.AuctionEvent SET VerificationStatus = @Status WHERE Id = @Id
			-- SELECT 1
	END
	ELSE IF(@PageName = 'Museum')
	BEGIN
			UPDATE dbo.Museum SET VerificationStatus = @Status WHERE Id = @Id
			-- SELECT 1
	END
	ELSE IF(@PageName = 'MuseumEvent')
	BEGIN
			UPDATE dbo.MuseumEvents SET VerificationStatus = @Status WHERE Id = @Id
			-- SELECT 1
	END
	ELSE IF(@PageName = 'Artfair')
	BEGIN
			UPDATE dbo.ArtFair SET VerificationStatus = @Status WHERE Id = @Id
			-- SELECT 1
	END
	ELSE IF(@PageName = 'ArtfairEvent')
	BEGIN
			UPDATE dbo.ArtFairEvent SET VerificationStatus = @Status WHERE Id = @Id
			-- SELECT 1
	END
	ELSE IF(@PageName = 'Biennale')
	BEGIN
			UPDATE dbo.Biennale SET VerificationStatus = @Status WHERE Id = @Id
			-- SELECT 1
	END
	ELSE IF(@PageName = 'BiennaleEvent')
	BEGIN
			UPDATE dbo.BiennaleEvent SET VerificationStatus = @Status WHERE Id = @Id
			-- SELECT 1
	END
	ELSE IF(@PageName = 'Book')
	BEGIN
			UPDATE dbo.Book SET VerificationStatus = @Status WHERE Id = @Id
			-- SELECT 1
	END
	ELSE IF(@PageName = 'PriceRecord')
	BEGIN
			UPDATE dbo.PriceRecord SET VerificationStatus = @Status WHERE PriceRecordId = @Id
			-- SELECT 1
	END
	ELSE IF(@PageName = 'AdminArtistTagMenu')
	BEGIN
			UPDATE dbo.AdminArtistTagMenu SET VerificationStatus = @Status WHERE Id = @Id
			-- SELECT 1
	END
	ELSE IF(@PageName = 'Magazine')
	BEGIN
			UPDATE dbo.Magazines SET VerificationStatus = @Status WHERE Id = @Id
			-- SELECT 1
	END
END

SP_hELPTEXT  CREATE PROCEDURE [dbo].[GetAllMagazines]   

EXEC [GetAllMagazinesOrGetMagazineById] @ID = 7