ALTER PROCEDURE [dbo].[ArtworkFromMarketProvenance_InsertOrUpdate]
	@Id INT = 0,
	@ArtworkId  INT = 0, 
	@Provenance NVARCHAR(50) = NULL,
	@ProvenanceFa NVARCHAR(50) = NULL,
	@OwnerId INT,
	@CollectorId INT,
	@BuyerId INT,
	@GalleryId INT,
	@Deal INT,
	@LotText NVARCHAR(MAX) = '', 
	@LotTextFa NVARCHAR(MAX) = '', 
	@IsDisplayLotText BIT = 0, 
	@IsDisplayLotTextFa BIT = 0,
	@ConditionReport NVARCHAR(MAX) = '', 
	@ConditionReportFa NVARCHAR(MAX) = '', 
	@IsDisplayConditionReport BIT = 0, 
	@IsDisplayConditionReportFa BIT = 0,
	@ToSell BIT = 0, 
	@Commision VARCHAR(50) = NULL, 
	@FinalPrice VARCHAR(50) = NULL, 
	@AskingPrice VARCHAR(50) = NULL, 
	@CountryId INT = 0, 
	@CityId INT = 0, 
	@PrivacyId INT = 0,
	@CreationDate DATETIME,
	@ModifiedDate DATETIME,
	@returnId INT OUTPUT
AS
BEGIN
	SET TRANSACTION ISOLATION LEVEL SNAPSHOT;

	IF @Id > 0
	BEGIN			
		UPDATE ArtworkFromMarketProvenance 
		SET Provenance = @Provenance, ProvenanceFa = @ProvenanceFa, OwnerId = @OwnerId, CollectorId = @CollectorId,
				BuyerId = @BuyerId, GalleryId = @GalleryId, Deal = @Deal, ModifiedDate = @ModifiedDate, ArtworkId = @ArtworkId,
				LotText = @LotText, LotTextFa = @LotTextFa, IsDisplayLotText = @IsDisplayLotText, IsDisplayLotTextFa = @IsDisplayLotTextFa,
				ConditionReport = @ConditionReport, ConditionReportFa = @ConditionReportFa, IsDisplayConditionReport = @IsDisplayConditionReport,
				IsDisplayConditionReportFa = @IsDisplayConditionReportFa, ToSell = @ToSell, Commision = @Commision, FinalPrice = @FinalPrice,
				AskingPrice = @AskingPrice, CountryId = @CountryId, CityId = @CityId, PrivacyId = @PrivacyId	
		WHERE Id = @Id
		SET @returnId = @Id;
	END
	ELSE
	BEGIN	
		INSERT INTO ArtworkFromMarketProvenance(Provenance, ProvenanceFa, OwnerId, CollectorId, BuyerId, GalleryId, Deal, CreationDate, ModifiedDate, ArtworkId,
									LotText, LotTextFa, IsDisplayLotText, IsDisplayLotTextFa, ConditionReport, ConditionReportFa, IsDisplayConditionReport,
									IsDisplayConditionReportFa, ToSell, Commision, FinalPrice,
									AskingPrice, CountryId, CityId, PrivacyId)
		VALUES (@Provenance, @ProvenanceFa, @OwnerId, @CollectorId, @BuyerId, @GalleryId, @Deal, @CreationDate, @ModifiedDate, @ArtworkId,
				@LotText, @LotTextFa, @IsDisplayLotText, @IsDisplayLotTextFa, @ConditionReport, @ConditionReportFa, @IsDisplayConditionReport,
				@IsDisplayConditionReportFa, @ToSell, @Commision, @FinalPrice,
				@AskingPrice, @CountryId, @CityId, @PrivacyId)
		SET @returnId = @@IDENTITY
	END
	
	SELECT @returnId
END