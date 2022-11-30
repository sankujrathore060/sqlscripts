

ALTER PROCEDURE [dbo].[SearchAdvertisement_TurboAds]
(
	@CarPageDisplayTurboAdOnPage INT = 3,
	@brandId int = 0,
	@modelId int = 0,
	@fromYear smallint = 0,
	@toYear smallint = 0,
	@fromMilage int = -10,
	@toMilage int = -10,
	@fromPrice bigint = 0,
	@toPrice bigint = 0,
	@transmissionType tinyint = 5,
	@hasPic bit = 0,
	--@isInstallmentAds bit = 0,
	@priceOption int = 2,
	@carType int = -3,
	@bodyType int = 0,
	@specialCase int = -1,
	@province int = 0,
	@color int = -1,
	@fuel int = 0, 
	@bodyStatusId int = 0,
	@firstDate nvarchar(100) = '',
	@sort nvarchar(500) = 'BumpDate DESC,ModifiedDate DESC',
	@sortNumber INT = 0,
	@downpayment bigint=0,
	@monthlypayment bigint=0,
	@driveType tinyint = 5	,
	@trimId int = 0,
	@seller int = 0,
	@companyName VARCHAR(20) ='',
	@hasPrice BIT = 0,
	@hasTrade BIT = 0,	
	@isLowConsumption bit = 0,
	@originState int =0,
	@cylinderNumber int =0,
	@engineRangeId int =0,
	@economicState int =0,
	@manufacturingCountry int =0,
	@companyId int=0,
	@CarPageDisplayTurboAdDuration INT = 30,
	@CarPageDisplayTurboAdDuration_WithFilter INT = 30,
	@CityId INT = 0 
)
AS
BEGIN	
	SET NOCOUNT ON;
	SET TRANSACTION ISOLATION LEVEL SNAPSHOT;

	DECLARE @SQL NVARCHAR(MAX) = '';
	DECLARE @TSql nvarchar(max)='';
	DECLARE @TCount int = 0;
	DECLARE @IsFirstPage BIT = 0;

	-- check if first page call when user comes on car page.	
	IF(@brandId = 0 and @modelId = 0 and @trimId = 0 AND @fromYear = 0 and @toYear = 0 and @fromMilage = -10 and @toMilage = -10 and @fromPrice= 0 and @toPrice = 0 and	
		(@transmissionType IS NULL OR @transmissionType = 5) and
		@hasPic = 0 and @priceOption = 2 and @carType = -3 and	@bodyType = 0 and	@specialCase = -1 and @province = 0 and	@color = -1 and
		@fuel = 0 and @bodyStatusId = 0 and (@driveType IS NULL OR @driveType=5) and @seller = 0 AND ISNULL(@companyName, '') = '' AND @hasPrice = 0 AND @hasTrade = 0 and
		@isLowConsumption = 0 AND @originState = 0 AND @cylinderNumber = 0 AND @engineRangeId = 0 AND @economicState = 0 AND @manufacturingCountry = 0 AND @companyId = 0 AND @CityId = 0)
	BEGIN		
			
			SET	@IsFirstPage = 1;
	END

    SET @SQL += 'WITH CTE AS '
			 + '(select   Ad.AdvertisementCount.CarModelID,
			Ad.AdvertisementCount.ModelYear,
			Ad.AdvertisementCount.Price as AdPrice,
			Ad.CarAd.IsHide as IsHide,
			Ad.CarAd.NoShow as NoShow,
			Ad.AdvertisementCount.Milage as AdMilage,
			Ad.CarAd.Description,
			Ad.CarAd.IsInstallmentSale,
			Ad.AdvertisementCount.Color_Fa as Color,
			Ad.AdvertisementCount.Brand_Fa AS BrandName,
			Ad.AdvertisementCount.Model_Fa AS ModelName,
			Ad.AdvertisementCount.Trim_Fa AS TrimName,
			Ad.AdvertisementCount.Brand AS BrandNameEng,
			Ad.AdvertisementCount.Model AS ModelNameEng,
			Ad.AdvertisementCount.Trim AS TrimNameEng,
			Ad.AdvertisementCount.Fuel_Fa AS Fuel_Fa,
			Ad.AdvertisementCount.TranmissionType_Fa AS TranmissionType_Fa,
			Ad.AdvertisementCount.CarAdID as Id,
			Ad.AdvertisementCount.CarType_Fa as CarType_Fa,
			Ad.CarAd.ModifiedDate as ModifiedDate,
			Ad.AdClass.BadgeEnabled as IsBadgeEnabled,
			Ad.AdClass.AdClassID as AdClassId,
			Ad.CarAd.DownPayment as DownPayment,
			Ad.CarAd.UserArea as UserArea,
			Ad.CarAd.RegisteredByUserID,
			Ad.CarAd.MonthlyPayment as MonthlyPayment,
			Ad.CarAd.DownPaymentSecondary as DownPaymentSecondary,
			Ad.CarAd.NumberOfMonth as NumberOfMonth,
			Ad.CarAd.NumberOfInstallment as NumberOfInstallment,
			Ad.CarAd.DeliveryInDays as DeliveryInDays,
			Ad.CarAd.IsPersonal as IsPersonal,
			-- Ad.CarAd.BarteringItemsCount as BarteringItemsCount,
			(SELECT COUNT(*) FROM Ad.CarBarter WITH(NOLOCK) WHERE Ad.CarBarter.CarAdId = Ad.CarAd.CarAdID) as BarteringItemsCount,
			Ad.CarAdImage.ImageFileURL as ImageUrl,
			Clients.Corporation.Title_Fa AS Corporation,
			Clients.CorporateProfile.IsSecret as IsSecret,
			Vehicle.CarSpecialCase.ImageURL as SpecialCaseImageUrl,
			Vehicle.CarSpecialCase.Name as SpecialCaseName,
			Vehicle.CarBodyType.ImageURL as BodyTypeImageUrl,
			Ad.AdvertisementCount.BodyStatus_Fa as BodyStatus,
			Ad.AdvertisementCount.Province_Fa as Province,
			Ad.AdvertisementCount.City_Fa as City,
			ad.carad.BumpDate as BumpDate,
			dbo.Companies.CompanyName_Fa CompanyName,
			dbo.GetCarAdImageCount(Ad.AdvertisementCount.CarAdID) as TotalAdImages,
			Ad.CarAd.IsTurboAd as IsTurboAd,
			Ad.CarAd.IsAdminCheckedAsTurboAd as IsAdminCheckedAsTurboAd,
			suc.URLCode as IdShortCode
		FROM Ad.AdvertisementCount WITH (NOLOCK)
			INNER JOIN Ad.CarAd WITH (NOLOCK) on Ad.AdvertisementCount.CarAdId = Ad.CarAd.CarAdID and Ad.CarAd.IsDeleted = 0 AND 
					Ad.CarAd.IsActive = 1 AND Ad.CarAd.CarSpecialCaseID <> 2 AND Ad.CarAd.isApprovedByAdmin = 1	AND ISNULL(Ad.CarAd.IsTurboAd, 0) = 1
			INNER JOIN Ad.AdClass WITH (NOLOCK) on Ad.CarAd.AdClassID = Ad.AdClass.AdClassID 
			INNER JOIN Vehicle.CarModel WITH (NOLOCK) ON Ad.CarAd.CarModelID=Vehicle.CarModel.CarModelID
            INNER JOIN dbo.Companies WITH (NOLOCK) ON  Vehicle.CarModel.CompanyId=dbo.Companies.CompanyId 
			LEFT JOIN dbo.ShortURLCode suc WITH(NOLOCK) ON suc.RespectiveId = Ad.CarAd.CarAdID AND suc.PageId = 1 ';
			
		IF(@hasPic = 0)
		BEGIN
			SET @SQL = @SQL + 'LEFT JOIN Ad.CarAdImage WITH (NOLOCK) on Ad.CarAd.PrefferedCarAdImageID = Ad.CarAdImage.CarAdImageID ' ;
		END
		ELSE
		BEGIN
			SET @SQL = @SQL + 'INNER JOIN Ad.CarAdImage WITH (NOLOCK) on Ad.CarAd.PrefferedCarAdImageID = Ad.CarAdImage.CarAdImageID ' ;
		END
            
		IF(@hasTrade = 1)
		BEGIN
			SET @sql = @sql + 'INNER JOIN (SELECT DISTINCT CarAdId FROM Ad.CarBarter WITH(NOLOCK)) carBarter ON carBarter.CarAdId = Ad.CarAd.CarAdID '
		END 

		SET @SQL = @SQL + ' LEFT JOIN Clients.CorporateProfile ON Ad.CarAd.OwnedByCorpProfileID = Clients.CorporateProfile.CorporateProfileID 
					LEFT JOIN Clients.Corporation ON Clients.Corporation.CorporationID = Clients.CorporateProfile.CorporationID
					LEFT JOIN Vehicle.CarSpecialCase on Ad.CarAd.CarSpecialCaseID = Vehicle.CarSpecialCase.CarSpecialCaseID
					LEFT JOIN Vehicle.CarBodyType on Ad.AdvertisementCount.CarBodyTypeId = Vehicle.CarBodyType.CarBodyTypeID
			WHERE ';
			
		-- for the /car page record without filter
		IF(@IsFirstPage = 1)
		BEGIN
				SET @SQL = @SQL + ' ISNULL(Ad.CarAd.IsCarPageWithOutFilterTurboAd, 0) = 1 
										AND DATEDIFF(HOUR, Ad.CarAd.CreatedDate, GETDATE()) <= ' + CAST(@CarPageDisplayTurboAdDuration AS NVARCHAR(10)) + ' AND ';
		END
		ELSE
		BEGIN
				SET @SQL = @SQL + ' DATEDIFF(HOUR, Ad.CarAd.CreatedDate, GETDATE()) <= ' + CAST(@CarPageDisplayTurboAdDuration_WithFilter AS NVARCHAR(10)) + ' AND ';
		END

		-- ADDED FOR NOT SHOW NoShow PRICE IN CAR-SEARCH - 19Jun2018
		IF(@sort = 'CASE WHEN (AdPrice <= 0 or IsInstallmentSale != 0) THEN -5 ELSE AdPrice END DESC,BumpDate DESC,ModifiedDate DESC'
			OR @sort = 'CASE WHEN (AdPrice <= 0 or IsInstallmentSale != 0) THEN 9999999999999 ELSE AdPrice END ASC,BumpDate DESC,ModifiedDate DESC')
		BEGIN
				SET @SQL = @SQL + ' ISNULL(Ad.CarAd.NoShow, 0) = 0 and ';
		END

		IF(@companyName <> '')
		BEGIN
			SET @SQL = @SQL + '  (dbo.Companies.CompanyName = '''+ CAST(@companyName as varchar(20))+ ''') and ';
		END

		IF (@brandId != 0)
		BEGIN
			SET @SQL = @SQL + ' (Ad.AdvertisementCount.CarBrandId = ' + CAST(@brandId AS NVARCHAR(10)) + ') and ';
		END;

		IF (@modelId != 0)
		BEGIN
			SET @SQL = @SQL + ' (Ad.AdvertisementCount.CarModelId = ' + CAST(@modelId AS NVARCHAR(10)) + ') and ';
		END;

		IF (@trimId != 0)
		BEGIN
			SET @SQL = @SQL + ' (Ad.AdvertisementCount.CarTrimId = ' + CAST(@trimId AS NVARCHAR(10)) + ') and ';
		END;

		IF (@fromYear != 0)
		BEGIN
			SET @SQL = @SQL + ' (Ad.AdvertisementCount.ModelYear >= ' + CAST(@fromYear AS NVARCHAR(50)) + ') and ';
		END;

		IF (@toYear != 0)
		BEGIN
			SET @SQL = @SQL + ' (Ad.AdvertisementCount.ModelYear <= ' + CAST(@toYear AS NVARCHAR(50)) + ') and ';
		END;

		IF (@fromMilage = 0 AND @toMilage = -10)
		BEGIN
			SET @SQL = @SQL + ' (Ad.AdvertisementCount.Milage = 0) and ';
		END;
		ELSE
		BEGIN
			IF (@fromMilage != -10)
			BEGIN
				SET @SQL = @SQL + ' (Ad.AdvertisementCount.Milage >= ' + CAST(@fromMilage AS NVARCHAR(50)) + ') and ';
			END;

			IF (@toMilage != -10)
			BEGIN
				SET @SQL = @SQL + ' (Ad.AdvertisementCount.Milage <= ' + CAST(@toMilage AS NVARCHAR(50)) + ') and ';
			END;
		END;

		IF (@fromPrice != 0)
		BEGIN
			SET @SQL = @SQL + ' (Ad.AdvertisementCount.Price >= ' + CAST(@fromPrice AS NVARCHAR(50)) + ') and ';
		END;

		IF (@toPrice != 0)
		BEGIN
			SET @SQL = @SQL + ' (Ad.AdvertisementCount.Price <= ' + CAST(@toPrice AS NVARCHAR(50)) + ') and ';
		END;

		-- ADDED NOSHOW CONDITION (ISNULL(Ad.CarAd.NoShow, 0) = 0 and) TO NOT DISPLAY NOSHOW FLAG ACTIVE ADS WHILE SEARCH WITH PRICE - 14MAR2019
		IF (@toPrice > 0 OR @fromPrice > 0 OR @sort = 'AdPrice ASC' OR @sort = 'AdPrice DESC')
		BEGIN
			SET @SQL
				= @SQL
					+ ' (Ad.AdvertisementCount.Price > 0) and (Ad.CarAd.IsInstallmentSale = 0) and ISNULL(Ad.CarAd.NoShow, 0) = 0 and ';
		END;

		IF (@transmissionType != 5)
		BEGIN
			SET @SQL
				= @SQL + ' (Ad.AdvertisementCount.TransmissionType = ' + CAST(@transmissionType AS NVARCHAR(10)) + ') and ';
		END;

		IF (@driveType != 5)
		BEGIN
			SET @SQL = @SQL + ' (ISNULL(Ad.CarAd.ModelDriveType,0) = ' + CAST(@driveType AS NVARCHAR(10)) + ') and ';
		END;

		IF (@hasPic != 0)
		BEGIN
			SET @SQL = @SQL + ' (Ad.AdvertisementCount.PrefferedCarAdImageID > 0) and ';
		END;

		IF (@priceOption != 2)
		BEGIN
			IF (@priceOption = 1)
			BEGIN
				SET @SQL = @SQL + ' (Ad.AdvertisementCount.IsInstallmentSale = 1) and ';
			END;
			IF (@priceOption = 0)
			BEGIN
				SET @SQL = @SQL + ' (Ad.AdvertisementCount.IsInstallmentSale = 0) and ';
			END;
		END;

		IF (@downpayment != 0)
		BEGIN
			SET @SQL
				= @SQL + ' ((ISNULL(Ad.CarAd.DownPayment,0)+ISNULL(Ad.CarAd.DownPaymentSecondary,0)) <= '
					+ CAST(@downpayment AS NVARCHAR(50)) + ') and ';
		END;

		IF (@monthlypayment != 0)
		BEGIN
			SET @SQL
				= @SQL + ' ((ISNULL(Ad.CarAd.MonthlyPayment,0)/ad.CarAd.NumberOfMonth) <= '
					+ CAST(@monthlypayment AS NVARCHAR(50)) + ') and ';
		END;

		IF (@sort = 'AdMilage ASC' OR @sort = 'AdMilage DESC')
		BEGIN
			SET @SQL = @SQL + ' (Ad.AdvertisementCount.Milage > 1) and ';
		END;
                 
		-- exclude "draft ads" and "cartex" ads from ad list when it's sorted by cheapest (4) said Naghmeh - 29Jul2019
		IF (@sortNumber = 4)
		BEGIN 
			SET @SQL = @SQL + ' (Ad.AdvertisementCount.Milage <> -1 and Ad.AdvertisementCount.Milage <> -4) and ';
		END
                 
		IF(@carType != -3)
		BEGIN
				-- ADDED CONDITION - "or ' + cast(@carType as nvarchar(10)) + ' = 1" on 26Jul2018
				-- CHANGED CONDITION - 31Jul2018					
				SET @SQL = @SQL + '(' 
									+'('  +
										'(Ad.CarAd.Milage = ' + cast(@carType as nvarchar(10)) + 
											' and (' + cast(@carType as nvarchar(10)) + ' = -1 or ' + cast(@carType as nvarchar(10))  + ' = 0 or ' 
														+ cast(@carType as nvarchar(10))  + ' = -4 or ' + cast(@carType as nvarchar(10))  + ' = -5)' 
										+ ') ' 
										+ ' or ((Ad.CarAd.Milage > 0 OR Ad.CarAd.Milage = -2) and ' + cast(@carType as nvarchar(10))  + ' = 1)'
										--+ ' or (Ad.CarAd.Milage >= -2 and ' + cast(@carType as nvarchar(10))  + ' = 1 and Ad.AdvertisementCount.CarType_Fa = ''کارکرده'')'
									+' ) ' 
								+ ' or ' + cast(@carType as nvarchar(10)) + ' = -3) and ';
		END
        
		IF (@bodyType != 0)
		BEGIN
			IF (@bodyType = 1)
			BEGIN
				SET @SQL = @SQL + ' (Ad.AdvertisementCount.CarBodyTypeId = 1 or Ad.AdvertisementCount.CarBodyTypeId = 7) and ';
			END;
			ELSE
			BEGIN
				SET @SQL = @SQL + ' (Ad.AdvertisementCount.CarBodyTypeId = ' + CAST(@bodyType AS NVARCHAR(10)) + ') and ';
			END;
		END;

		IF (@specialCase != -1)
		BEGIN
			SET @SQL = @SQL + ' (Ad.AdvertisementCount.CarSpecialCaseID = ' + CAST(@specialCase AS NVARCHAR(10)) + ') and ';
		END;

		IF (@province != 0)
		BEGIN
			SET @SQL = @SQL + ' (Ad.AdvertisementCount.ProvinceId = ' + CAST(@province AS NVARCHAR(10)) + ') and ';
		END;

		IF (@CityId != 0)
		BEGIN
			SET @SQL = @SQL + ' (Ad.AdvertisementCount.CityId = ' + CAST(@CityId AS SMALLINT) + ') and ';
		END;

		IF (@color != -1)
		BEGIN
			SET @SQL = @SQL + ' (Ad.AdvertisementCount.ExteriorColorID = ' + CAST(@color AS NVARCHAR(10)) + ') and ';
		END;

		IF (@bodyStatusId != 0)
		BEGIN
			SET @SQL = @SQL + ' (Ad.AdvertisementCount.CarBodyStatusID = ' + CAST(@bodyStatusId AS NVARCHAR(10)) + ') and ';
		END;

		IF (@fuel != 0)
		BEGIN
			SET @SQL = @SQL + ' (Ad.AdvertisementCount.CarFuelTypeId = ' + CAST(@fuel AS NVARCHAR(10)) + ') and ';
		END;

		IF (@firstDate != '' AND @sort = 'BumpDate DESC,ModifiedDate DESC')
		BEGIN
			SET @SQL
				= @SQL + ' ((Ad.CarAd.BumpDate <= N''' + CAST(@firstDate AS NVARCHAR(100))
					+ ''') OR (Ad.CarAd.ModifiedDate <= N''' + CAST(@firstDate AS NVARCHAR(100)) + ''')) and ';
		END;

		-- ADDED on 09Jan2018
		IF (@seller = 1)
		BEGIN
			SET @SQL = @SQL + ' (Ad.CarAd.IsPersonal = 1 AND ISNULL(Clients.CorporateProfile.IsSecret,0)=0) and ';
		END;

		IF (@seller = 2)
		BEGIN
			SET @SQL = @SQL + ' (Ad.CarAd.IsPersonal = 0 AND ISNULL(Clients.CorporateProfile.IsSecret,0)=0) and ';
		END;

		IF (@hasPrice = 1) -- ADDED on 04Nov2019
		BEGIN
			SET @SQL = @SQL + ' (Ad.AdvertisementCount.Price > 0) and ISNULL(Ad.CarAd.NoShow, 0) = 0 and ';
		END;

		IF (@originState <> 0)
		BEGIN
				IF(@originState = 1)
				BEGIN 
						SET @SQL = @SQL + N' (ISNULL(Ad.AdvertisementCount.IsImported, 0) = 0 and ISNULL(Ad.AdvertisementCount.IsMontage, 0) = 0) AND ';
				END 
				ELSE IF(@originState = 2)
				BEGIN 
						SET @SQL = @SQL + N' (ISNULL(Ad.AdvertisementCount.IsImported, 0) = 1 and ISNULL(Ad.AdvertisementCount.IsMontage, 0) = 0) AND ';
				END 
				ELSE IF (@originState = 3)
				BEGIN 
						SET @SQL = @SQL + N' (Ad.AdvertisementCount.IsMontage = 1) AND ';
				END 
		END

		IF(@manufacturingCountry <> 0)
		BEGIN 
			SET @SQL = @SQL + N' (Ad.AdvertisementCount.ManufacturingCountryId = ' + CAST(@manufacturingCountry AS  NVARCHAR(10))  +N') and ';
		END 

		IF (@companyId <> 0)
		BEGIN
            SET @SQL = @SQL + N'  (Ad.CarAd.CompanyId = ' + CAST(@companyId AS VARCHAR(20)) + N') and ';
	    END

		IF (@economicState <> 0)
		BEGIN 
				IF(@economicState = 1)
				BEGIN
					SET @SQL = @SQL + N'  (Ad.AdvertisementCount.IsEconomic = 1) AND (Ad.AdvertisementCount.Price Between 10000000 and 200000000) AND ';
				END
				ELSE IF(@economicState = 2)
				BEGIN
					-- SET @SQL = @SQL + N'  (Ad.AdvertisementCount.Isluxary = 1) and ';
					-- Vehicle.CarModel.ModelYearType = 1 = MEAN ENGLISH YEAR - NEED DISPLAY RECORD >= 2000 YEAR
					SET @SQL = @SQL + N' (Ad.AdvertisementCount.Isluxary = 1 AND (Vehicle.CarModel.ModelYearType = 0 OR (Vehicle.CarModel.ModelYearType = 1 
												AND Ad.CarAd.ModelYear >= 2000))) AND '
				END 
				ELSE IF(@economicState = 3)
				BEGIN
					SET @SQL = @SQL + N'  (Ad.CarAd.LowConsumption = 1) and ';
				END
		END 

		IF(@cylinderNumber <> 0)
		BEGIN
			 SET @SQL = @SQL + N'  (Ad.AdvertisementCount.CylinderNumber = ' + CAST(@cylinderNumber AS  NVARCHAR(10)) + N') and ';
		END

		IF (@engineRangeId <> 0)
		BEGIN
			DECLARE @engineMax int;
			DECLARE @engineMin int;
			SELECT @engineMin=EngineVolumeMin, @engineMax=EngineVolumeMax from Vehicle.Engine where EngineId=@engineRangeId;
			SET @SQL = @SQL + N'  ((Ad.AdvertisementCount.EngineRangeId = ' + CAST(@engineRangeId AS  NVARCHAR(10)) + N') ) and ';
		END; 

		IF (@isLowConsumption <> 0)
		BEGIN 
			SET @SQL = @SQL + N'  (Ad.CarAd.LowConsumption = ' + CAST(@isLowConsumption AS  NVARCHAR(10)) + N') and ';
		END
            
		SET @SQL = @SQL + ' (1 = 1))';

		SET  @TSql = @SQL;
		SET @SQL += ' SELECT @cnt=COUNT(*) FROM CTE ';  	 	
		
		PRINT @TSql
		EXECUTE sp_executesql @SQL, N'@cnt int OUTPUT', @cnt=@TCount OUTPUT;
		PRINT 'Count-' + cast(@TCount as nvarchar(10))

		IF(@TCount > 0)
		BEGIN
				IF(@CarPageDisplayTurboAdOnPage > 0)
				BEGIN
					SET  @TSql += ' SELECT TOP ' + CAST(@CarPageDisplayTurboAdOnPage as nvarchar(15)) + ' *, ' + CAST(@TCount as nvarchar(15)) 
											+ ' AS TotalRecord, 0 as SimilarAds FROM CTE ORDER BY NEWID(), ' + @sort;
				END
				ELSE 
				BEGIN
					SET  @TSql += ' SELECT TOP 3 *, '+ CAST (@TCount as nvarchar(15)) + ' AS TotalRecord, 0 as SimilarAds FROM CTE ORDER BY NEWID(), ' + @sort;
				END
			
				PRINT @TSql
				EXECUTE  sp_executesql  @TSql
		END 
END