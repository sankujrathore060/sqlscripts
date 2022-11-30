ALTER PROCEDURE [dbo].[SearchAdvertisement_New] 
(
	@NeedAdsOnPage INT = 30,
	@pageIndex int,
	@pageSize int,
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
	@PageOffSet INT = 0,
	@FirstPageRandomAdsCount INT = 0,
	@TurboAdIds VARCHAR(100) = '',
	@hasPrice BIT = 0,
	@hasTrade BIT = 0,
	@isLowConsumption bit = 0,
	@originState int =0,
	@cylinderNumber int =0,
	@engineRangeId int =0,
	@economicState int =0,
	@manufacturingCountry int =0,
	@companyId int = 0,
	@isRayan BIT = 0,
	@adType INT = 0,
	@City INT = 0
)
AS
BEGIN	
	SET NOCOUNT ON;
	SET TRANSACTION ISOLATION LEVEL SNAPSHOT;

	declare @SQL NVARCHAR(MAX) = '';
	declare @TSql nvarchar(max)='';
	declare @TCount int = 0;
	--declare @PageOffset int = 0;

	IF(@pageIndex >= 0)
	BEGIN
			SET	@PageOffset = (@pageIndex * @NeedAdsOnPage) - @FirstPageRandomAdsCount;
			IF (@PageOffset < 0)
	    		SET @PageOffset = 0;
	END

	---- BECAUSE OF ARVEN CACHE WE NEED THIS - 23May2019
	--IF(@PageOffSet = 0 AND @FirstPageRandomAdsCount = 0 AND @pageIndex = 1)
	--BEGIN
	--		SET	@PageOffset = (@pageIndex * @NeedAdsOnPage) - 3;
	--END

	-- check if first page call when user comes on car page.
	-- in first page we displays only 9 records with 3 random records.
	-- so we will deduct 3.
	-- @brandId = 0 and @modelId = 0 and @trimId = 0 - 09May2019
	IF(@fromYear = 0 and @toYear = 0 and @fromMilage = -10 and @toMilage = -10 and @fromPrice= 0 and @toPrice = 0 and	
		(@transmissionType IS NULL OR @transmissionType = 5) and
		@hasPic = 0 and @priceOption = 2 and @carType = -3 and	@bodyType = 0 and	@specialCase = -1 and @province = 0 and @City = 0 and	@color = -1 and
		@fuel = 0 and @bodyStatusId = 0 and (((@brandId > 0 or @modelId > 0 OR @trimId > 0) and @sort = 'BumpDate DESC,ModifiedDate DESC,IsBadgeEnabled DESC') 
		OR @sort = 'BumpDate DESC,ModifiedDate DESC') 
		and (@driveType IS NULL OR @driveType=5) and @seller = 0 AND @pageIndex >= 2)
	BEGIN		
			
			SET	@PageOffset = (@pageIndex * @NeedAdsOnPage) - @FirstPageRandomAdsCount; -- 3
			IF (@PageOffset < 0)
				SET @PageOffset = 0;
	END

	PRINT @pageSize 
	PRINT @PageOffset

    SET @SQL += 'WITH CTE AS '
			 + '(select Vehicle.CarModel.OfficialAgentId,
			 Vehicle.CarModel.CompanyId,
			 Ad.AdvertisementCount.CarModelID,
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
			 Ad.CarAd.IsFromIranIps,
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
			  suc.URLCode as IdShortCode,
			  -- Ad.AdvertisementCount.IsOffroad as IsOffroad,
			  CASE WHEN Vehicle.CarAttributes.CarAttributesId > 0 THEN Vehicle.CarAttributes.IsOffroad 
											ELSE Ad.AdvertisementCount.IsOffroad END as IsOffroad,
			  Ad.CarAd.ShowPriceForInstallment as ShowPriceForInstallment,
			  Ad.CarAd.ShowMonthlyPaymentForInstallment as ShowMonthlyPaymentForInstallment
		FROM Ad.AdvertisementCount WITH (NOLOCK)
			INNER JOIN Ad.CarAd WITH (NOLOCK) on Ad.AdvertisementCount.CarAdId = Ad.CarAd.CarAdID and Ad.CarAd.IsDeleted = 0 AND Ad.CarAd.IsActive = 1	 
						AND Ad.CarAd.CarSpecialCaseID <> 2 AND Ad.CarAd.isApprovedByAdmin = 1 
						AND (ISNULL(Ad.CarAd.IsTurboAd, 0) = 0 OR (ISNULL(Ad.CarAd.IsTurboAd, 0) = 1 AND DATEDIFF(HOUR, Ad.CarAd.CreatedDate, GETDATE()) > 48))
			INNER JOIN Ad.AdClass WITH (NOLOCK) on Ad.CarAd.AdClassID = Ad.AdClass.AdClassID 
			INNER JOIN Vehicle.CarModel WITH (NOLOCK) ON Ad.CarAd.CarModelID=Vehicle.CarModel.CarModelID
			INNER JOIN Vehicle.CarAttributes WITH (NOLOCK) on Vehicle.CarAttributes.ModelId = Ad.CarAd.CarModelID
									AND ISNULL(TrimId, 0) = ISNULL(Ad.CarAd.CarTrimID, 0)
            INNER JOIN dbo.Companies WITH (NOLOCK) ON  Vehicle.CarModel.CompanyId=dbo.Companies.CompanyId 			
			LEFT JOIN dbo.ShortURLCode suc WITH(NOLOCK) ON suc.RespectiveId = Ad.CarAd.CarAdID AND suc.PageId = 1 ';

		IF(@companyName <> '')
		BEGIN
			SET @sql = @sql + 'INNER JOIN Vehicle.CarModel cm(NOLOCK) ON cm.CarModelId = ad.CarAd.CarModelId
							INNER JOIN dbo.Companies c(NOLOCK) ON c.CompanyId = cm.CompanyId '
		END 

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

		--IF(@TurboAdIds <> '')
		--BEGIN
		--	SET @SQL = @SQL + ' Ad.AdvertisementCount.CarAdId NOT IN (SELECT Value FROM dbo.Split(''' + @TurboAdIds + ''')) and ' ;
		--END

		-- ADDED FOR NOT SHOW NoShow PRICE IN CAR-SEARCH - 19Jun2018
		--IF(@sort = 'CASE WHEN (AdPrice <= 0 or IsInstallmentSale != 0) THEN -5 ELSE AdPrice END DESC,BumpDate DESC,ModifiedDate DESC'
		--	OR @sort = 'CASE WHEN (AdPrice <= 0 or IsInstallmentSale != 0) THEN 9999999999999 ELSE AdPrice END ASC,BumpDate DESC,ModifiedDate DESC')
		--BEGIN
		--		SET @SQL = @SQL + ' ISNULL(Ad.CarAd.NoShow, 0) = 0 and ';
		--END

		IF(@companyName <> '')
		BEGIN
			SET @SQL = @SQL + '  (c.CompanyName = '''+cast(@companyName as varchar(20))+ ''') and ';
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
			SET @SQL = @SQL + ' (Ad.AdvertisementCount.Price >= ' + CAST(@fromPrice AS NVARCHAR(50)) + ') and ISNULL(Ad.CarAd.IsHide, 0) = 0 and ';
		END;

		IF (@toPrice != 0)
		BEGIN
			SET @SQL = @SQL + ' (Ad.AdvertisementCount.Price <= ' + CAST(@toPrice AS NVARCHAR(50)) + ') and ISNULL(Ad.CarAd.IsHide, 0) = 0 and ';
		END;

		-- ADDED NOSHOW CONDITION (ISNULL(Ad.CarAd.NoShow, 0) = 0 and) TO NOT DISPLAY NOSHOW FLAG ACTIVE ADS WHILE SEARCH WITH PRICE - 14MAR2019
		IF (@toPrice > 0 OR @fromPrice > 0 OR @sort = 'AdPrice ASC' OR @sort = 'AdPrice DESC')
		BEGIN
			SET @SQL = @SQL + ' (Ad.AdvertisementCount.Price > 0) and (Ad.CarAd.IsInstallmentSale = 0) and ISNULL(Ad.CarAd.NoShow, 0) = 0 and ';
		END;

		IF (@transmissionType != 5)
		BEGIN
			SET @SQL = @SQL + ' (Ad.AdvertisementCount.TransmissionType = ' + CAST(@transmissionType AS NVARCHAR(10)) + ') and ';
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
			SET @SQL = @SQL + ' (ISNULL(Ad.CarAd.MonthlyPayment, 0) > 0 AND Ad.CarAd.NumberOfMonth > 0 AND 
									((ISNULL(Ad.CarAd.MonthlyPayment,0) / ad.CarAd.NumberOfMonth) <= ' + CAST(@monthlypayment AS NVARCHAR(50)) + ')) AND ';
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
										--+ ' or (Ad.CarAd.Milage >= -2 and ' + cast(@carType as nvarchar(10))  + ' = 1 and Ad.AdvertisementCount.CarType_Fa = ''???????'')'
									+' ) ' 
								+ ' or ' + cast(@carType as nvarchar(10)) + ' = -3) and ';
		END
        
		IF (@bodyType != 0)
		BEGIN
			-- SET @SQL = @SQL + ' (Ad.AdvertisementCount.CarBodyTypeId = ' + CAST(@bodyType AS NVARCHAR(10)) + ') and ';
			SET @SQL = @SQL + '(CASE WHEN ISNULL(Vehicle.CarModel.CarBodyTypeId, 0) <> 0 THEN ISNULL(Vehicle.CarModel.CarBodyTypeId, 0)
									WHEN ISNULL(Ad.AdvertisementCount.CarBodyTypeId, 0) <> 0 THEN ISNULL(Ad.AdvertisementCount.CarBodyTypeId, 0)
									ELSE 0
								END = ' + CAST(@bodyType AS NVARCHAR(10)) + ') AND ';
		END;

		IF (@specialCase != -1)
		BEGIN
				IF(@specialCase=4)
				BEGIN
						-- SET @SQL = @SQL + ' (Ad.AdvertisementCount.IsOffroad = 1) and ';
						SET @SQL = @SQL + N' (1 = CASE WHEN Vehicle.CarAttributes.CarAttributesId > 0 THEN Vehicle.CarAttributes.IsOffroad 
												ELSE Ad.AdvertisementCount.IsOffroad END) AND ';
				END
				ELSE
				BEGIN
						SET @SQL = @SQL + ' (Ad.AdvertisementCount.CarSpecialCaseID = ' + CAST(@specialCase AS NVARCHAR(10)) + ') and ';
				END;
		END

		IF (@province != 0)
		BEGIN
			SET @SQL = @SQL + ' (Ad.AdvertisementCount.ProvinceId = ' + CAST(@province AS NVARCHAR(10)) + ') and ';
		END;

		IF (@City != 0)
		BEGIN
			SET @SQL = @SQL + ' (Ad.AdvertisementCount.CityId = ' + CAST(@City AS NVARCHAR(10)) + ') and ';
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
			--SET @SQL = @SQL + ' (Ad.AdvertisementCount.Price > 0) and ISNULL(Ad.CarAd.NoShow, 0) = 0 and (Ad.CarAd.IsHide>=0) and';
			SET @SQL = @SQL + ' (Ad.AdvertisementCount.Price > 0) and (Ad.CarAd.IsHide>=0) and';
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
						-- SET @SQL = @SQL + N'  (Ad.AdvertisementCount.IsEconomic = 1) AND ';
						SET @SQL = @SQL + N' (1 = CASE WHEN Vehicle.CarAttributes.CarAttributesId > 0 THEN Vehicle.CarAttributes.IsEconomic 
												ELSE Ad.AdvertisementCount.IsEconomic END) AND ';
				END
				ELSE IF(@economicState = 2)
				BEGIN
					-- SET @SQL = @SQL + N'  (Ad.AdvertisementCount.Isluxary = 1) and ';
					-- Vehicle.CarModel.ModelYearType = 1 = MEAN ENGLISH YEAR - NEED DISPLAY RECORD >= 2000 YEAR
					--SET @SQL = @SQL + N' (Ad.AdvertisementCount.Isluxary = 1 AND (Vehicle.CarModel.ModelYearType = 0 OR ' + 
					--						'(Vehicle.CarModel.ModelYearType = 1 AND Ad.CarAd.ModelYear >= 2000))) AND '
					SET @SQL = @SQL + N' ((1 = CASE WHEN Vehicle.CarAttributes.CarAttributesId > 0 THEN Vehicle.CarAttributes.IsLuxary ELSE Ad.AdvertisementCount.Isluxary END) ' 
								+ 'AND (Vehicle.CarModel.ModelYearType = 0 OR ' 
								+ '(Vehicle.CarModel.ModelYearType = 1 AND Ad.CarAd.ModelYear >= 2000))) AND '
				END 
				ELSE IF(@economicState = 3)
				BEGIN
					-- SET @SQL = @SQL + N'  (Ad.CarAd.LowConsumption = 1) and ';
					SET @SQL = @SQL + N' (1 = CASE WHEN Vehicle.CarAttributes.CarAttributesId > 0 THEN Vehicle.CarAttributes.IsLowConsumption 
												ELSE Ad.AdvertisementCount.LowConsumption END) AND ';
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
				-- SET @SQL = @SQL + N'  (Ad.CarAd.LowConsumption = ' + CAST(@isLowConsumption AS  NVARCHAR(10)) + N') and ';
				SET @SQL = @SQL 
					+ N' (' + CAST(@isLowConsumption AS  NVARCHAR(10)) 
					+ N' = CASE WHEN Vehicle.CarAttributes.CarAttributesId > 0 THEN Vehicle.CarAttributes.IsLowConsumption 
									ELSE Ad.AdvertisementCount.LowConsumption END) AND ';
		END

		-- start rayan filter
		IF(@isRayan = 1)
		BEGIN
				SET @SQL = @SQL + N' (
										((ISNULL(Ad.AdvertisementCount.IsImported, 0) = 0 AND ISNULL(Ad.AdvertisementCount.IsMontage, 0) = 0)
											OR (ISNULL(Ad.AdvertisementCount.IsMontage, 0) = 1))
										AND Ad.AdvertisementCount.Milage >= 0 
										AND Ad.AdvertisementCount.Milage <= 100000
										AND Ad.AdvertisementCount.ModelYear >= 1393
										AND ISNULL(Vehicle.CarModel.IsNeedToSendFinanceSMS, 0) = 1
										AND ISNULL(Ad.CarAd.OwnedByCorpProfileID, 0) = 0
									) AND ';
		END

		IF(@adType = 23)
		BEGIN
				SET @SQL = @SQL + N' (ISNULL(Ad.CarAd.IsAdClassProvidedByPayment, 0) = 1) AND ';
		END
		-- end rayan filter

		SET @SQL = @SQL + ' (1 = 1))';

		SET  @TSql = @SQL;
		SET @SQL += ' SELECT @cnt = COUNT(*) FROM CTE ';  	 	
		
		PRINT @TSql
		PRINT '--------------------'
		EXECUTE sp_executesql @SQL, N'@cnt int OUTPUT', @cnt=@TCount OUTPUT;
		PRINT 'Count-' + cast(@TCount as nvarchar(10))

		IF(@TCount>0)
		BEGIN
			SET  @TSql += ' SELECT *,'+   
			CAST (@TCount as nvarchar(15)) + ' AS TotalRecord,0 as SimilarAds FROM CTE '+  
			' ORDER BY ' + @sort + 
			' OFFSET(' + cast(@PageOffset as nvarchar(10)) +') ROWS' +
			' FETCH NEXT ' + cast(@pageSize as nvarchar(10)) + ' ROWS ONLY';	
			PRINT @TSql
			PRINT '--------TCOUNT----------'

			EXECUTE  sp_executesql  @TSql
		END 


	IF(@TCount <= 0)
	BEGIN
		IF (@brandId > 0)
		BEGIN
			 SET @SQL = 'WITH CTE AS '
				 + '(select  Ad.CarAd.CarModelID,
				 Ad.CarAd.ModelYear,
				 Ad.CarAd.RegisteredByUserID,
				 Ad.CarAd.Price as AdPrice,
				 Ad.CarAd.IsHide as IsHide,
				 Ad.CarAd.NoShow as NoShow,
				 Ad.CarAd.Milage as AdMilage,
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
				 Ad.AdvertisementCount.CarType_Fa as CarType_Fa,
				 Ad.CarAd.CarAdID as Id,
				 Ad.CarAd.ModifiedDate as ModifiedDate,
				 Ad.CarAd.DownPayment as DownPayment,
				 Ad.CarAd.UserArea as UserArea,
				 Ad.CarAd.MonthlyPayment as MonthlyPayment,
				 Ad.CarAd.DownPaymentSecondary as DownPaymentSecondary,
				 Ad.CarAd.NumberOfMonth as NumberOfMonth,
				 Ad.CarAd.NumberOfInstallment as NumberOfInstallment,
				 Ad.CarAd.DeliveryInDays as DeliveryInDays,
				 Ad.AdClass.BadgeEnabled as IsBadgeEnabled,
				 Ad.AdClass.AdClassID as AdClassId,
				 Ad.CarAd.IsPersonal as IsPersonal,
				 --Ad.CarAd.BarteringItemsCount as BarteringItemsCount,
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
				dbo.GetCarAdImageCount(Ad.AdvertisementCount.CarAdID) as TotalAdImages,
				Ad.CarAd.IsTurboAd as IsTurboAd,
				Ad.CarAd.IsAdminCheckedAsTurboAd as IsAdminCheckedAsTurboAd,
				suc.URLCode as IdShortCode,
				Ad.CarAd.ShowPriceForInstallment as ShowPriceForInstallment,
			  Ad.CarAd.ShowMonthlyPaymentForInstallment as ShowMonthlyPaymentForInstallment
			FROM Ad.AdvertisementCount WITH (NOLOCK)
					INNER JOIN Ad.CarAd WITH (NOLOCK) on Ad.AdvertisementCount.CarAdId = Ad.CarAd.CarAdID	AND Ad.CarAd.IsActive = 1 
									AND Ad.CarAd.CarSpecialCaseID <> 2 AND Ad.CarAd.isApprovedByAdmin = 1 
									AND (ISNULL(Ad.CarAd.IsTurboAd, 0) = 0 OR (ISNULL(Ad.CarAd.IsTurboAd, 0) = 1 AND DATEDIFF(HOUR, Ad.CarAd.CreatedDate, GETDATE()) > 48))
					INNER JOIN Ad.AdClass on Ad.CarAd.AdClassID = Ad.AdClass.AdClassID
					LEFT JOIN Ad.CarAdImage WITH (NOLOCK) on Ad.CarAd.PrefferedCarAdImageID = Ad.CarAdImage.CarAdImageID 
					LEFT JOIN Clients.CorporateProfile ON Ad.CarAd.OwnedByCorpProfileID = Clients.CorporateProfile.CorporateProfileID 
					LEFT JOIN Clients.Corporation ON Clients.Corporation.CorporationID = Clients.CorporateProfile.CorporationID
					LEFT JOIN Vehicle.CarSpecialCase on Ad.CarAd.CarSpecialCaseID = Vehicle.CarSpecialCase.CarSpecialCaseID
					LEFT JOIN Vehicle.CarBodyType on Ad.AdvertisementCount.CarBodyTypeId = Vehicle.CarBodyType.CarBodyTypeID
					LEFT JOIN dbo.ShortURLCode suc WITH(NOLOCK) ON suc.RespectiveId = Ad.CarAd.CarAdID AND suc.PageId = 1
			WHERE ';

			IF(@sort = 'AdPrice ASC')
			BEGIN
					SET @SQL = @SQL + ' (Ad.CarAd.Price > 0) and ' ;
			END
			-- exclude "draft ads" and "cartex" ads from ad list when it's sorted by cheapest (4) said Naghmeh - 29Jul2019
			IF (@sortNumber = 4)
			BEGIN 
				SET @SQL = @SQL + ' (Ad.AdvertisementCount.Milage <> -1 and Ad.AdvertisementCount.Milage <> -4) and ';
			END
			-- ADDED FOR NOT SHOW NoShow PRICE IN CAR-SEARCH - 19Jun2018
			--IF(@sort = 'AdPrice DESC')
			--IF(@sort = 'CASE WHEN (AdPrice <= 0 or IsInstallmentSale != 0) THEN -5 ELSE AdPrice END DESC,BumpDate DESC,ModifiedDate DESC'
			--	OR @sort = 'CASE WHEN (AdPrice <= 0 or IsInstallmentSale != 0) THEN 9999999999999 ELSE AdPrice END ASC,BumpDate DESC,ModifiedDate DESC')
			--BEGIN
			--		SET @SQL = @SQL + ' ISNULL(Ad.CarAd.NoShow, 0) = 0 and ';
			--END

			SET @SQL = @SQL + ' (Ad.AdvertisementCount.CarBrandId = ' + cast(@brandId as nvarchar(10)) + ' or ' + cast(@brandId as nvarchar(10)) + ' = 0) and 
					(Ad.AdvertisementCount.CarModelId = ' + cast(@modelId as nvarchar(10)) + ' or ' + cast(@modelId as nvarchar(10)) + ' = 0) and 
					(Ad.AdvertisementCount.CarTrimId = ' + cast(@trimId as nvarchar(10)) + ' or ' + cast(@trimId as nvarchar(10)) + ' = 0))';
			SET  @TSql = @SQL;				
			SET @SQL += ' SELECT @cnt=COUNT(*) FROM CTE ';		

			-- PRINT @TSql
			EXECUTE sp_executesql @SQL, N'@cnt int OUTPUT',@cnt= @TCount OUTPUT;

			IF(@TCount>0)
			BEGIN
				SET @TSql +=  ' SELECT *,'+   
								--'(SELECT count(1) FROM CTE) AS TotalRecord,1 as SimilarAds FROM CTE '+  
								'(SELECT count(1) FROM CTE) AS TotalRecord,0 as SimilarAds FROM CTE '+  
								' ORDER BY ' + @sort +						
								' OFFSET(' + cast(@PageOffset as nvarchar(10)) +') ROWS' +
								' FETCH NEXT ' + cast(@pageSize as nvarchar(10)) + ' ROWS ONLY';
				PRINT @TSql
				PRINT '--------------------'

				EXECUTE  sp_executesql  @TSql
			END

			IF(@TCount <= 0)
				BEGIN
					 SET @SQL = 'WITH CTE AS '
								 + '(select  Ad.CarAd.CarModelID,
								 Ad.CarAd.ModelYear,
								 Ad.CarAd.RegisteredByUserID,
								 Ad.CarAd.Price as AdPrice,
								 Ad.CarAd.IsHide as IsHide,
								 Ad.CarAd.NoShow as NoShow,
								 Ad.CarAd.Milage as AdMilage,
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
								 Ad.AdvertisementCount.CarType_Fa as CarType_Fa,
								 Ad.CarAd.CarAdID as Id,
								 Ad.CarAd.ModifiedDate as ModifiedDate,
								 Ad.CarAd.DownPayment as DownPayment,
								 Ad.CarAd.UserArea as UserArea,
								 Ad.CarAd.MonthlyPayment as MonthlyPayment,
								 Ad.CarAd.DownPaymentSecondary as DownPaymentSecondary,
								 Ad.CarAd.NumberOfMonth as NumberOfMonth,
								 Ad.CarAd.NumberOfInstallment as NumberOfInstallment,
								 Ad.CarAd.DeliveryInDays as DeliveryInDays,
								 Ad.AdClass.BadgeEnabled as IsBadgeEnabled,
								 Ad.AdClass.AdClassID as AdClassId,
								 Ad.CarAd.IsPersonal as IsPersonal,
								 --Ad.CarAd.BarteringItemsCount as BarteringItemsCount,
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
								  Ad.CarAd.BumpDate as BumpDate,
								 dbo.GetCarAdImageCount(Ad.AdvertisementCount.CarAdID) as TotalAdImages,
								Ad.CarAd.IsTurboAd as IsTurboAd,
								Ad.CarAd.IsAdminCheckedAsTurboAd as IsAdminCheckedAsTurboAd,
								suc.URLCode as IdShortCode
							FROM Ad.AdvertisementCount WITH (NOLOCK)
									 INNER JOIN Ad.CarAd WITH (NOLOCK) on Ad.AdvertisementCount.CarAdId = Ad.CarAd.CarAdID AND Ad.CarAd.IsActive = 1  
									 AND Ad.CarAd.CarSpecialCaseID <> 2 AND Ad.CarAd.isApprovedByAdmin = 1 
									 AND (ISNULL(Ad.CarAd.IsTurboAd, 0) = 0 OR (ISNULL(Ad.CarAd.IsTurboAd, 0) = 1 AND DATEDIFF(HOUR, Ad.CarAd.CreatedDate, GETDATE()) > 48))
									 INNER JOIN Ad.AdClass on Ad.CarAd.AdClassID = Ad.AdClass.AdClassID
									 LEFT JOIN Ad.CarAdImage WITH (NOLOCK) on Ad.CarAd.PrefferedCarAdImageID = Ad.CarAdImage.CarAdImageID 
									 LEFT JOIN Clients.CorporateProfile ON Ad.CarAd.OwnedByCorpProfileID = Clients.CorporateProfile.CorporateProfileID 
									 LEFT JOIN Clients.Corporation ON Clients.Corporation.CorporationID = Clients.CorporateProfile.CorporationID
									 LEFT JOIN Vehicle.CarSpecialCase on Ad.CarAd.CarSpecialCaseID = Vehicle.CarSpecialCase.CarSpecialCaseID
									 LEFT JOIN Vehicle.CarBodyType on Ad.AdvertisementCount.CarBodyTypeId = Vehicle.CarBodyType.CarBodyTypeID
									 LEFT JOIN dbo.ShortURLCode suc WITH(NOLOCK) ON suc.RespectiveId = Ad.CarAd.CarAdID AND suc.PageId = 1
							WHERE ';

						IF(@sort = 'AdPrice ASC')
						BEGIN
							SET @SQL = @SQL + ' (Ad.CarAd.Price > 0) and ' ;
						END

						-- exclude "draft ads" and "cartex" ads from ad list when it's sorted by cheapest (4) said Naghmeh - 29Jul2019
						IF (@sortNumber = 4)
						BEGIN 
							SET @SQL = @SQL + ' (Ad.AdvertisementCount.Milage <> -1 and Ad.AdvertisementCount.Milage <> -4) and ';
						END

						-- ADDED FOR NOT SHOW NoShow PRICE IN CAR-SEARCH - 19Jun2018
						--IF(@sort = 'AdPrice DESC')
						IF(@sort = 'CASE WHEN (AdPrice <= 0 or IsInstallmentSale != 0) THEN -5 ELSE AdPrice END DESC,BumpDate DESC,ModifiedDate DESC'
							OR @sort = 'CASE WHEN (AdPrice <= 0 or IsInstallmentSale != 0) THEN 9999999999999 ELSE AdPrice END ASC,BumpDate DESC,ModifiedDate DESC')
						BEGIN
								SET @SQL = @SQL + ' ISNULL(Ad.CarAd.NoShow, 0) = 0 and ';
						END

						SET @SQL = @SQL + ' (Ad.AdvertisementCount.CarBrandId = ' + cast(@brandId as nvarchar(10)) + ' or ' + cast(@brandId as nvarchar(10)) + ' = 0))';
						SET  @TSql = @SQL;
						SET @SQL += ' SELECT @cnt=COUNT(*) FROM CTE ';   

						EXECUTE sp_executesql @SQL, N'@cnt int OUTPUT',@cnt=@TCount OUTPUT;
						IF(@TCount>0)
						BEGIN
							SET @TSql +=	' SELECT *,'+   
											--'(SELECT count(1) FROM CTE) AS TotalRecord,2 as SimilarAds FROM CTE '+  
											'(SELECT count(1) FROM CTE) AS TotalRecord,0 as SimilarAds FROM CTE '+  
											' ORDER BY ' + @sort + 									
											' OFFSET(' + cast(@PageOffset as nvarchar(10)) +') ROWS' +
											' FETCH NEXT ' + cast(@pageSize as nvarchar(10)) + ' ROWS ONLY';
							PRINT @TSql
							PRINT '--------------------'

							EXECUTE  sp_executesql  @TSql
						END
   	 		    END
 	     END
	END
END

