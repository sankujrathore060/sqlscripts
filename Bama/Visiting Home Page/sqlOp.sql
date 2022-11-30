use bamainspection

SP_HELPTEXT [MotorcycleType_GetAll]

SELECT MotorcycleTypeId as Id,
			   Name as Title,
			   HomePageText as Title_Fa,
			   HomePageImage as ImageUrl,
			   cast(MotorcycleTypeId as varchar) + ',' + Name as IdTitle
			   FROM Vehicle.MotorcycleType
			   Where MotorcycleTypeId IN 
			   (SELECT Ad.MotorcycleAdCount.MotorcycleTypeId as Id
			   FROM Ad.MotorcycleAdCount
			   GROUP BY Ad.MotorcycleAdCount.MotorcycleTypeId, Ad.MotorcycleAdCount.MotorcycleType,Ad.MotorcycleAdCount.MotorcycleType_Fa)
			   Order By DisplayOrder

			   
SP_HELPTEXT [HomePage_GetAllBrands]

SP_HELPTEXT [HomePage_GetAllTrims]

SP_HELPTEXT [HomePage_GetAllModels]


SP_HELPTEXT [GetAllAdvertisementCountsOnly]

SP_HELPTEXT [GetTodaysTotalAdCount]

SP_HELPTEXT [CarPriceModelPrice_GetCount]

SP_HELPTEXT [JoinUsPostDetail_GetAll] 

SELECT * FROM JoinUs.PostDetail

SELECT * FROM JoinUs.Category

SP_HELPTEXT [JoinUsPostDetail_GetById]

SP_HELPTEXT [JoinUsSeekerDetail_Insert]


SP_HELPTEXT [HomePage_GetAllMotorcycleTypes]

SP_hELPTEXT [RightNavigation_GetAllHomePageBrands]

SP_HELPTEXT [RightNavigation_ExteriorColor]

SP_HELPTEXT [CarBodyStatus_GetAll]

SP_HELPTEXT [CarFuelType_GetAll]

SP_HELPTEXT [CarSpecialCase_GetAll]

SP_HELPTEXT [Company_getAll]

SP_HELPTEXT [RightNavigation_GetAllModels]

SP_HELPTEXT [GetAllAdvertisementCounts_Modified]

SELECT TOP 10
        adv.*,
        adc.DownPayment,
        adc.DownPaymentSecondary,
        adc.MonthlyPayment,
        adc.NumberOfMonth,
        adc.NumberOfInstallment,
        adc.DeliveryInDays,
        adc.ModelDriveType,
        adc.IsPersonal,
		ISNULL(vm.IsNeedToSendFinanceSMS, 0) AS IsNeedToSendFinanceSMS,
		ISNULL(adc.OwnedByCorpProfileID, 0) AS OwnedByCorpProfileID,
		ISNULL(adc.IsAdClassProvidedByPayment, 0) AS IsAdClassProvidedByPayment,
		ISNULL(adc.NoShow, 0) as NoShow,
		ISNULL(adc.IsHide, 0) as IsHide,
        vm.CompanyId,
        com.CompanyName,
        com.CompanyName_Fa,
        ISNULL(adv.CarTrimID, 0) AS CarTrimId,
		(SELECT COUNT(CarAdId) FROM Ad.CarBarter acb WITH(NOLOCK) WHERE acb.CarAdId = adc.CarAdID) AS BarteringItemsCount,

		-- Model_CarBodyTypeFa
		-- ISNULL(cbt.CarBodyTypeId, adv.CarBodyTypeId) AS Model_CarBodyTypeId,
		CASE WHEN ISNULL(vm.CarBodyTypeId, 0) <> 0 THEN ISNULL(vm.CarBodyTypeId, 0)
			WHEN ISNULL(adv.CarBodyTypeId, 0) <> 0 THEN ISNULL(adv.CarBodyTypeId, 0)
			ELSE 0
		END AS Model_CarBodyTypeId,
		-- ISNULL(cbt.Name, adv.CarBodyType) AS Model_CarBodyType,
		CASE WHEN ISNULL(vm.CarBodyTypeId, 0) <> 0 THEN cbt.Name
			WHEN ISNULL(adv.CarBodyTypeId, 0) <> 0 THEN adv.CarBodyType
			ELSE ''
		END AS Model_CarBodyType,
		-- ISNULL(cbt.Name_Fa, adv.CarBodyType_Fa)  AS Model_CarBodyTypeFa,	
		CASE WHEN ISNULL(vm.CarBodyTypeId, 0) <> 0 THEN cbt.Name_Fa
			WHEN ISNULL(adv.CarBodyTypeId, 0) <> 0 THEN adv.CarBodyType_Fa
			ELSE ''
		END AS Model_CarBodyTypeFa,
		
		-- Model_CylinderNumber
		-- ISNULL(vm.CylinderNumber, adv.CylinderNumber) AS Model_CylinderNumber
		CASE WHEN ISNULL(ca.CylinderNumber, 0) <> 0 THEN ISNULL(ca.CylinderNumber, 0)
			WHEN ISNULL(vm.CylinderNumber, 0) <> 0 THEN ISNULL(vm.CylinderNumber, 0)
			WHEN ISNULL(adv.CylinderNumber, 0) <> 0 THEN ISNULL(adv.CylinderNumber, 0)
			WHEN ISNULL(adc.CylinderNumber, 0) <> 0 THEN ISNULL(adc.CylinderNumber, 0)
			ELSE 0
		END AS Model_CylinderNumber,
		
		-- Model_DriveType
		CASE WHEN ISNULL(ct.DriveType, 0) <> 0 AND ISNULL(ct.DriveType, 0) <> 10 THEN ISNULL(ct.DriveType, 0) 			
			WHEN ISNULL(vm.DriveType, 0) <> 0 AND ISNULL(vm.DriveType, 0) <> 10 THEN ISNULL(vm.DriveType, 0)			
			WHEN ISNULL(adc.ModelDriveType, 0) <> 0 AND ISNULL(adc.ModelDriveType, 0) <> 10 THEN ISNULL(adc.ModelDriveType, 0)
			ELSE 0
		END AS ModelTrim_DriveType,

		-- Model_YearType
		vm.ModelYearType AS Model_YearType,

		-- Model_LowConsumption
		CASE WHEN ca.CarAttributesId > 0 THEN ca.IsLowConsumption
			ELSE adv.LowConsumption
		END AS Model_LowConsumption,

		-- Model_IsOffroad
		CASE WHEN ca.CarAttributesId > 0 THEN ca.IsOffroad
			ELSE adv.IsOffroad
		END AS Model_IsOffroad,

		-- Model_IsLuxary
		CASE WHEN ca.CarAttributesId > 0 THEN ca.IsLuxary
			ELSE adv.Isluxary
		END AS Model_IsLuxary,

		-- Model_IsEconomic
		CASE WHEN ca.CarAttributesId > 0 THEN ca.IsEconomic
			ELSE adv.IsEconomic
		END AS Model_IsEconomic
    FROM
        Ad.AdvertisementCount adv WITH(NOLOCK)
        INNER JOIN Ad.CarAd adc WITH(NOLOCK) ON adc.CarAdID = adv.CarAdId
                            AND adc.IsDeleted = 0 AND adc.IsActive = 1
							AND adc.CarSpecialCaseID <> 2 AND adc.isApprovedByAdmin = 1 AND ISNULL(adc.IsTurboAd, 0) = 0 -- and ISNULL(adc.IsFromIranIps, 0) = 1
        INNER JOIN Vehicle.CarModel vm WITH(NOLOCK) ON vm.CarModelID = adc.CarModelID
		LEFT JOIN Vehicle.CarTrim ct WITH(NOLOCK) ON ct.CarTrimID = adc.CarTrimID
        INNER JOIN dbo.Companies com WITH(NOLOCK) ON com.CompanyId = vm.CompanyId
		LEFT JOIN Vehicle.CarBodyType cbt WITH(NOLOCK) ON vm.CarBodyTypeId = cbt.CarBodyTypeID
		LEFT JOIN Vehicle.CarAttributes ca WITH(NOLOCK) ON ca.ModelId = vm.CarModelID AND ISNULL(ca.TrimId, 0) = ISNULL(adc.CarTrimID, 0);

SP_HELPTEXT [ManufacturingCountry_GetAllCarAds]

SP_HELPTEXT [ManufacturingCountry_GetAll]

SP_HELPTEXT [GetAllFiltered_Models]

SP_HELPTEXT [Province_GetAll]

SP_HELPTEXT [City_GetAllFilter]

SP_HELPTEXT [SearchMotorcycleAd_New]
