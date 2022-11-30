ALTER PROCEDURE ArtistVerification_Insert

	@ArtistId INT,
	@IsVerified BIT,
	@ArtistLastModifiedDate DATETIME,
	@VerifiedByFa NVARCHAR(255),
	@VerifiedBy NVARCHAR(255),
	@VerifiedEmails VARCHAR(MAX),
	@MainVerifiedEmail VARCHAR(MAX),
	@PhoneNumber VARCHAR(255),
	@CreatedDate DATETIME,
	@ModifiedDate DATETIME
AS 
BEGIN
	SET TRANSACTION ISOLATION LEVEL SNAPSHOT;

	INSERT INTO ArtistVerification( ArtistId, IsVerified, ArtistLastModifiedDate, VerifiedByFa, VerifiedBy,
											VerifiedEmails, MainVerifiedEmail, PhoneNumber, CreatedDate, ModifiedDate)
	VALUES( @ArtistId, @IsVerified, @ArtistLastModifiedDate, @VerifiedByFa, @VerifiedBy,
											@VerifiedEmails, @MainVerifiedEmail, @PhoneNumber, @CreatedDate, @ModifiedDate)
	SELECT @@IDENTITY
END
