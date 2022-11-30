ALTER PROCEDURE [dbo].[MotorcycleAdCount_GetAllRightNavigations]
(
	@brandId int = 0,
	@modelId int =0,
	@provinceId int =0,
	@fuelId  int =0,
	@typeId int =0,
	@colorId int =-1,
	@transmissionType tinyint=NULL,
	@fromYear smallint =0,
	@toYear smallint =0,
	@fromMilage int =-1,
	@toMilage int =-1,
	@fromPrice bigint=0,
	@toPrice bigint =0,
	@hasPic bit=0,
	@carType int=-3,
	@sort int =0,
	@displacementFrom int = 0,
	@displacementTo int = 0,
	@motoryclePriceType int = 1,
	@cityId int = 0
)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.

	SET TRANSACTION ISOLATION LEVEL SNAPSHOT;
	SET NOCOUNT ON;

	-----------------------------------------------------------------------------------------------------------------------

	CREATE TABLE #MileageRangeTemp(Id int,MinValue int,MaxValue int ,Title_Fa nvarchar(100));
	
	INSERT INTO #MileageRangeTemp (Id, MinValue,MaxValue,Title_Fa)
			  SELECT 1,0,0,N'صفر'
	UNION ALL SELECT 2,0,10,N'زير 10 هزار كيلومتر'
	UNION ALL SELECT 3,10,30,N'از 10 تا 30 هزار كيلومتر'
	UNION ALL SELECT 4,30,50,N'از 30 تا 50 هزار كيلومتر'
	UNION ALL SELECT 5,50,100,N'از 50 تا 100 هزار كيلومتر'
	UNION ALL SELECT 6,100,0,N'بالاتر از 100 هزار كيلومتر'

	-----------------------------------------------------------------------------------------------------------------------

	CREATE TABLE #CarTypeTemp(Id int,Title nvarchar(100));

	INSERT INTO #CarTypeTemp (Id, Title)
	SELECT 0,'New'
	UNION ALL SELECT -1,'Pre-Order'
	UNION ALL SELECT 1,'Used'
	UNION ALL SELECT -4,'Card-Index'
	
	-----------------------------------------------------------------------------------------------------------------------

	SELECT * INTO #temp
	FROM Ad.MotorcycleAdCount a
	WHERE (@brandId = 0 OR a.MotorcycleBrandId=@brandId) AND (@modelId =0 OR a.MotorcycleModelId =@modelId)
	AND (@fromYear =0  OR a.ModelYear >= @fromYear) AND (@toYear =0  OR a.ModelYear <= @toYear)
	AND (@displacementFrom =0  OR a.Displacement >= @displacementFrom) AND (@displacementTo =0  OR a.Displacement <= @displacementTo)
	AND (@fromPrice =0  OR a.Price >= @fromPrice) AND (@toPrice =0  OR a.Price <= @toPrice)
	
	AND (
		(@fromMilage=-1 AND @toMilage=-1) OR 
				(
					(@fromMilage=0 AND @toMilage=-1 AND a.Milage =0) 
					OR (@fromMilage > 0 AND @toMilage=-1 AND a.Milage  > @fromMilage)  
					OR (@toMilage > -1 and @fromMilage = -1  AND a.Milage  <= @toMilage)
					OR (@toMilage > -1 and @fromMilage > -1  AND a.Milage > @fromMilage AND  a.Milage  <= @toMilage)
					--OR (@fromMilage <> -1 AND @fromMilage <> 0  And (@toMilage = -1 OR @toMilage = 0) AND a.Milage  > @fromMilage) 
					--OR ((@fromMilage = -1 OR @toMilage = 0) AND @toMilage <> -1 And @toMilage <> 0 AND a.Milage  <= @toMilage) 
				)
		 )
	
	AND (@transmissionType IS NULL OR (a.TransmissionType IS NOT NULL AND a.TransmissionType=@transmissionType)) AND (@hasPic=0 OR a.PrefferedMotorcycleAdImageID > 0)
	AND (@hasPic=0 OR a.PrefferedMotorcycleAdImageID > 0) AND (@typeId =0 OR (a.MotorcycleTypeId IS NOT NULL AND a.MotorcycleTypeId=@typeId))
	AND (@carType = -3 OR (((@carType=-1 OR @carType=0) AND a.Milage=@carType) OR a.Milage > 0))
	AND (@provinceId =0 OR (a.ProvinceId IS NOT NULL AND a.ProvinceId=@provinceId))
	AND (@cityId =0 OR (a.CityId IS NOT NULL AND a.CityId=@cityId))
	AND (@colorId =-1 OR a.ColorID=@colorId)
	AND (@fuelId=0 OR a.MotorcycleFuelTypeId=@fuelId) 
	AND ((@fromPrice=0 AND  @toPrice =0) OR (@fromPrice > 0 OR @toPrice > 0) AND a.Price > 0)
	AND (@sort=0 OR ((@sort =7 OR @sort=8) AND a.Milage > 1))
	AND (
			@motoryclePriceType = 0 OR @motoryclePriceType = 1
			OR (@motoryclePriceType = 2 AND ISNULL(IsInstallmentSale, 0) = 1)
			OR (@motoryclePriceType = 3 AND ISNULL(IsInstallmentSale, 0) = 0)
		)
	-----------------------------------------------------------------------------------------------------------------------
	
	-- Province
	SELECT 
		p.ProvinceId as Id,p.Province as Title, p.Province_Fa as Title_Fa, 
		(CAST(p.ProvinceID as nvarchar(20)) + ',' +p.Province) as IdTitle,
		COUNT(p.ProvinceId) as Count
	FROM #temp p
	GROUP BY ProvinceId,Province,Province_Fa
	Order By Count DESC

	-----------------------------------------------------------------------------------------------------------------------

	-- City
	SELECT 
		p.CityId as IdNew,p.City as Title, p.City_Fa as Title_Fa, 
		(CAST(p.CityId as nvarchar(20)) + ',' +p.City) as IdTitle,
		COUNT(p.CityId) as Count
	FROM #temp p
	GROUP BY CityId,City,City_Fa
	Order By Count DESC

	-----------------------------------------------------------------------------------------------------------------------

	---- Motorcycletype
	SELECT 
		p.MotorcycleTypeId as Id,p.MotorcycleType as Title, p.MotorcycleType_Fa as Title_Fa, 
		(CAST(p.MotorcycleTypeId as nvarchar(20)) + ',' +p.MotorcycleType) as IdTitle,
		COUNT(p.MotorcycleTypeId) as Count
	FROM #temp p
	GROUP BY MotorcycleTypeId,MotorcycleType,MotorcycleType_Fa
	Order By Count DESC

	---- MotorcycleBrand
	SELECT p.MotorcycleBrandId as Id,p.Brand as Title, p.Brand_Fa as Title_Fa, (CAST(p.MotorcycleBrandId as nvarchar(20)) + ',' +p.Brand) as IdTitle,
	COUNT(p.MotorcycleBrandId) as Count
	FROM #temp p
	WHERE p.MotorcycleBrandId <> 31	-- NO NEED TO DISPLAY OTHER BRAND
	GROUP BY MotorcycleBrandId,Brand,Brand_Fa
	Order By Count DESC

	-- colorList
	SELECT p.ColorID as Id,p.Color as Title, p.Color_Fa as Title_Fa, (CAST(p.ColorID as nvarchar(20)) + ',' +p.Color) as IdTitle,
	COUNT(p.ColorID) as Count
	FROM #temp p
	GROUP BY  p.ColorID,p.Color,p.Color_Fa
	Order By Count DESC

	-- fuelList
	SELECT p.MotorcycleFuelTypeId as Id,p.Fuel as Title, p.Fuel_Fa as Title_Fa, (CAST(p.MotorcycleFuelTypeId as nvarchar(20)) + ',' +p.Fuel) as IdTitle,
	COUNT(p.MotorcycleFuelTypeId) as Count
	FROM #temp p
	GROUP BY  p.MotorcycleFuelTypeId,p.Fuel,p.Fuel_Fa
	Order By Count DESC

	-- modelList
	SELECT p.MotorcycleModelId as ModelId,p.Model as Title,p.Model AS NAME, p.Model_Fa as Title_Fa, (CAST(p.MotorcycleModelId as nvarchar(20)) + ',' +p.Model) as IdTitle,
	COUNT(p.MotorcycleModelId) as Count
	FROM #temp p
	GROUP BY  p.MotorcycleModelId,p.Model,p.Model_Fa
	Order By Count DESC
	
	-- transmissionTypeList
	SELECT p.TransmissionType as Id,(Select Name From Vehicle.TransmissionTypes where Id=p.TransmissionType) as Title, 
	p.TranmissionType_Fa as Title_Fa, 
	(CAST(p.TransmissionType as nvarchar(20)) + ',' +(Select Name From Vehicle.TransmissionTypes where Id=p.TransmissionType)) as IdTitle,
	COUNT(p.TransmissionType) as Count
	FROM #temp p
	GROUP BY  p.TransmissionType,p.TranmissionType_Fa
	Order By Count DESC

	-- StatusList
	SELECT DISTINCT p.MotorcycleMileageType_Fa as Title_Fa,(CASE WHEN (p.Milage > 0 OR p.Milage=-2) THEN 1 ELSE p.Milage END) as ModelId,t1.Count
	FROM #temp p
	INNER JOIN 
	(SELECT p.MotorcycleMileageType_Fa,COUNT(p.MotorcycleMileageType_Fa) as Count FROM #temp p 
		WHERE p.MotorcycleMileageType_Fa IS NOT NULL Group By p.MotorcycleMileageType_Fa) as t1 ON t1.MotorcycleMileageType_Fa=p.MotorcycleMileageType_Fa
	
	
	---- Mileage Range
	SELECT *
	FROM
	(SELECT p.Id as Id,p.Title_Fa as Title,p.Title_Fa as Title_Fa, (CAST(p.MinValue as nvarchar(20)) + ',' +CAST(p.MaxValue as nvarchar(20))) as IdTitle,
	(SELECT count(1) FROM #temp t Where (p.MinValue=0 AND p.MaxValue=0 AND t.Milage = 0) 
									 OR (p.MinValue = 0 AND p.MaxValue = 10 and t.Milage > 0  and t.Milage < = p.MaxValue * 1000  )
									 OR (p.MinValue=100 AND p.MaxValue=0 AND t.Milage > p.MinValue * 1000) 
									 OR (p.MinValue > 0 AND p.MinValue < 100 and p.MaxValue > 10  and p.MaxValue < 100 AND t.Milage >  p.MinValue * 1000 
											AND t.Milage < = p.MaxValue * 1000)
										) as Count
	From #MileageRangeTemp p) T1
	WHERE COUNT > 0

	-----------------------------------------------------------------------------------------------------------------------
	-- INSTALLMENT/ CASH	
	SELECT * FROM (
		SELECT 
			2 as Id,
			'installment' as Title, 
			'اقساطی' as Title_Fa, 
			'2,installment' as IdTitle,
			COUNT(*) as Count
		FROM #temp p
		WHERE ISNULL(IsInstallmentSale, 0) = 1
		UNION ALL
		SELECT 
			3 as Id,
			'cash' as Title, 
			'نقدی' as Title_Fa, 
			'3,cash' as IdTitle,
			COUNT(*) as COUNT
		FROM #temp p
		WHERE ISNULL(IsInstallmentSale, 0) = 0
	) t
	ORDER BY COUNT DESC
END

SELECT * FROM City where 


SP_HELPTEXT [City_GetAllFilter]

SELECT * FROM City


Exec [MotorcycleAdCount_GetAllRightNavigations]
		@cityId = 303
