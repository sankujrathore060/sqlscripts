CREATE PROCEDURE ArtistVerification_Update
	@Id INT,
	@ArtistId INT,
	@IsVerified BIT,
	@ArtistLastModifiedDate DATETIME,
	@VerifiedByFa NVARCHAR(255),
	@VerifiedBy NVARCHAR(255),
	@VerifiedEmails VARCHAR(MAX),
	@MainVerifiedEmail VARCHAR(MAX),
	@PhoneNumber VARCHAR(255),
	@ModifiedDate DATETIME
AS 
BEGIN
	SET TRANSACTION ISOLATION LEVEL SNAPSHOT;
	
	UPDATE ArtistVerification
	SET ArtistId = @ArtistId, IsVerified = @IsVerified, ArtistLastModifiedDate = @ArtistLastModifiedDate,
		VerifiedByFa = @VerifiedByFa, VerifiedBy = @VerifiedBy, VerifiedEmails = @VerifiedEmails, MainVerifiedEmail = @MainVerifiedEmail,
		PhoneNumber = @PhoneNumber, ModifiedDate = @ModifiedDate
	WHERE Id = @Id

END