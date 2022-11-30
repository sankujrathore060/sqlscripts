ALTER PROCEDURE [dbo].[SearchMotorcycleAd_New] 
(
	@pageIndex int,
	@pageSize int,
	@brandId int = 0,
	@modelId int = 0,
	@fromYear smallint = 0,
	@toYear smallint = 0,
	@fromMilage int = -1,
	@toMilage int = -1,
	@fromPrice bigint = 0,
	@toPrice bigint = 0,
	@transmissionType tinyint = 5,
	@hasPic bit = 0,
	@carType int = -3,
	@motorcycleType int = 0,
	@province int = 0,
	@color int = -1,
	@fuel int = 0, 
	@firstDate nvarchar(50) = '',
	@sort VARCHAR(500) = 'BumpDate DESC,ModifiedDate DESC',
	@fromDisplacement int = 0,
	@toDisplacement int = 0,
	@isInstallmentAds bit = 0,
	@isHeavyVehicle bit=0,
	@isDisplacementMax bit=0,
	@motoryclePriceType int = 1,
	@city int = 0
)
AS
BEGIN	
	SET TRANSACTION ISOLATION LEVEL SNAPSHOT;
	SET NOCOUNT ON;

	declare @SQL NVARCHAR(MAX) = '';
	declare @TSql nvarchar(max)='';
	declare @TCount int = 0;

	declare @PageOffset int = 0;

	set	@PageOffset = (@pageIndex * @pageSize);
		if (@PageOffset < 0)
	    	set @PageOffset = 0;

	-- check if first page call when user comes on car page.
	-- in first page we displays only 9 records with 3 random records.
	-- so we will deduct 3.
	if(@brandId = 0 and @modelId = 0 and @fromYear = 0 and @toYear = 0 and @fromMilage = 0 and @toMilage = 0 and @fromPrice= 0 and @toPrice = 0 and	@transmissionType= 5 and
	   @hasPic = 0 and @carType = -3 and @isInstallmentAds = 0 and @motorcycleType = 0  and @province = 0 and	@color = -1 and
	   @fuel = 0 and @sort = 'BumpDate DESC,ModifiedDate DESC')
	   begin
			set	@PageOffset = (@pageIndex * 12) - 3; --7
			if (@PageOffset < 0)
				set @PageOffset = 0;
	   end

    SET @SQL += 'WITH CTE AS '
			 + '(select   Ad.MotorcycleAdCount.MotorcycleModelId,
			 Ad.MotorcycleAdCount.ModelYear,
			 Ad.MotorcycleAdCount.Price as AdPrice,
			 Ad.MotorcycleAdCount.Milage as AdMilage,
			 Ad.MotorcycleAd.Description,
			 Ad.MotorcycleAd.IsInstallmentSale,			 
			 Ad.MotorcycleAdCount.Color_Fa as Color,
			 Ad.MotorcycleAdCount.Brand_Fa AS BrandName,
			 Ad.MotorcycleAdCount.Model_Fa AS ModelName, 
			 Ad.MotorcycleAdCount.Brand AS BrandNameEng,
			 Ad.MotorcycleAdCount.MotorcycleType_Fa AS MotorcycleType_Fa,
			 Ad.MotorcycleAdCount.Model AS ModelNameEng,
			 Ad.MotorcycleAdCount.MotorcycleAdId as Id,
			 Ad.MotorcycleAdCount.Displacement as Displacement,
			 Ad.MotorcycleAd.ModifiedDate as ModifiedDate,
			 Ad.AdClass.BadgeEnabled as IsBadgeEnabled,
			 Ad.AdClass.AdClassID as AdClassId,
			 Ad.MotorcycleAd.DownPayment as DownPayment,
			 Ad.MotorcycleAd.UserArea as UserArea,
			 Ad.MotorcycleAd.MonthlyPayment as MonthlyPayment,
			 Ad.MotorcycleAd.DownPaymentSecondary as DownPaymentSecondary,
			 Ad.MotorcycleAd.NumberOfMonth as NumberOfMonth,
			 Ad.MotorcycleAd.NumberOfInstallment as NumberOfInstallment,
			 Ad.MotorcycleAd.DeliveryInDays as DeliveryInDays,
			 Ad.MotorcycleAd.IsPersonal as IsPersonal,
			 Ad.MotorcycleAdImage.ImageFileURL as ImageUrl,
			 Clients.Corporation.Title_Fa AS Corporation,
			 Clients.CorporateProfile.IsSecret as IsSecret,			
			 Vehicle.MotorcycleType.LogoURL as MotorcycleTypeImageUrl,			 
			 Ad.MotorcycleAdCount.Province_Fa as Province,
			 Ad.MotorcycleAdCount.City_Fa as City,
			 Ad.MotorcycleAd.BumpDate as BumpDate,
			 suc.URLCode as IdShortCode
			 from Ad.MotorcycleAdCount
				 INNER JOIN Ad.MotorcycleAd on Ad.MotorcycleAdCount.MotorcycleAdId = Ad.MotorcycleAd.MotorcycleAdId and Ad.MotorcycleAd.IsDeleted = 0		
				 INNER JOIN Ad.AdClass on Ad.MotorcycleAd.AdClassID = Ad.AdClass.AdClassID 
				 LEFT JOIN dbo.ShortURLCode suc WITH(NOLOCK) ON suc.RespectiveId = Ad.MotorcycleAd.MotorcycleAdId AND suc.PageId = 2';

		if(@hasPic = 0)
			 begin
			 	set @SQL = @SQL + 'LEFT JOIN Ad.MotorcycleAdImage on Ad.MotorcycleAd.PrefferedMotorcycleAdImageID = Ad.MotorcycleAdImage.MotorcycleAdImageID ' ;
			 end
		else
			begin
				set @SQL = @SQL + 'INNER JOIN Ad.MotorcycleAdImage on Ad.MotorcycleAd.PrefferedMotorcycleAdImageID = Ad.MotorcycleAdImage.MotorcycleAdImageID ' ;
			end

		set @SQL = @SQL + ' LEFT JOIN Clients.CorporateProfile ON Ad.MotorcycleAd.OwnedByCorpProfileID = Clients.CorporateProfile.CorporateProfileID 
				 LEFT JOIN Clients.Corporation ON Clients.Corporation.CorporationID = Clients.CorporateProfile.CorporationID 																		   				 
			     LEFT JOIN Vehicle.MotorcycleType on Ad.MotorcycleAdCount.MotorcycleTypeId = Vehicle.MotorcycleType.MotorcycleTypeId
			where ';

			if(@brandId != 0)
			 begin
			   set @SQL = @SQL + ' (Ad.MotorcycleAdCount.MotorcycleBrandId = ' + cast(@brandId as nvarchar(10)) + ') and ';
			 end

			if(@modelId !=0)
			 begin
				set @SQL = @SQL + ' (Ad.MotorcycleAdCount.MotorcycleModelId = ' + cast(@modelId as nvarchar(10)) + ') and ';
			 end

			if(@fromYear != 0)
			begin
			    set @SQL = @SQL + ' (Ad.MotorcycleAdCount.ModelYear >= ' + cast(@fromYear as nvarchar(50)) + ') and ';
			end

			if(@toYear != 0)
			begin
			    set @SQL = @SQL + ' (Ad.MotorcycleAdCount.ModelYear <= ' + cast(@toYear as nvarchar(50)) + ') and ';
			end

			--if(@fromMilage != 0)
			--begin
			--	set @SQL = @SQL + ' (Ad.MotorcycleAdCount.Milage >= ' + cast(@fromMilage as nvarchar(10))+ ') and ';
			--end

			--if(@toMilage != 0)
			--begin
			--	set @SQL = @SQL + ' (Ad.MotorcycleAdCount.Milage <= ' + cast(@toMilage as nvarchar(10))+ ') and ';
			--end

			if(@fromMilage =0 and @toMilage=-1)
				begin
				set @SQL = @SQL + ' (Ad.MotorcycleAdCount.Milage =0) and ';
				end
			else if(@fromMilage > 0 and @toMilage=-1)
				begin
				set @SQL = @SQL + ' (Ad.MotorcycleAdCount.Milage > ' + cast(@fromMilage as nvarchar(50))+ ') and ';
				end
			else
			begin
				if(@fromMilage != -1 and @fromMilage !=0)
				begin
					set @SQL = @SQL + ' (Ad.MotorcycleAdCount.Milage > ' + cast(@fromMilage as nvarchar(50))+ ') and ';
				end

				if(@toMilage != -1 and @toMilage !=0)
				begin
					set @SQL = @SQL + ' (Ad.MotorcycleAdCount.Milage <= ' + cast(@toMilage as nvarchar(50))+ ') and ';
				end
			end
			
			if(@isHeavyVehicle!=0 and @isDisplacementMax!=0)
			begin
				if(@fromDisplacement != 0)
				begin
					set @SQL = @SQL + ' (Ad.MotorcycleAdCount.Displacement > ' + cast(@fromDisplacement as nvarchar(50))+ ') and ';
				end
			end
			else
			begin
			if(@fromDisplacement != 0)
			begin
				set @SQL = @SQL + ' (Ad.MotorcycleAdCount.Displacement >= ' + cast(@fromDisplacement as nvarchar(50))+ ') and ';
			end
				if(@toDisplacement != 0)
			begin
				set @SQL = @SQL + ' (Ad.MotorcycleAdCount.Displacement <= ' + cast(@toDisplacement as nvarchar(50))+ ') and ';
			end
			end

			if(@isInstallmentAds != 0)
			begin
				set @SQL = @SQL + ' (Ad.MotorcycleAdCount.IsInstallmentSale = 1) and ';
			end

			if(@fromPrice != 0)
			begin
				set @SQL = @SQL + ' (Ad.MotorcycleAdCount.Price >= ' + cast(@fromPrice as nvarchar(50))+ ') and ';
			end

			if(@toPrice != 0)
			begin
			  set @SQL = @SQL + ' (Ad.MotorcycleAdCount.Price <= ' + cast(@toPrice as nvarchar(50))+ ') and ';
			end

			if(@toPrice > 0 or @fromPrice > 0 or @sort = 'AdPrice ASC' or @sort = 'AdPrice DESC')
				 begin
					set @SQL = @SQL + ' (Ad.MotorcycleAdCount.Price > 0) and ' ;
				 end

		    if(@transmissionType != 5)
			begin
				set @SQL = @SQL + ' (Ad.MotorcycleAdCount.TransmissionType = ' + cast(@transmissionType as nvarchar(10))+ ') and ';
			end

			if(@hasPic != 0)
			begin
				set @SQL = @SQL + ' (Ad.MotorcycleAdCount.PrefferedMotorcycleAdImageID > 0) and ';
			end			

			if(@sort = 'AdMilage ASC' or @sort = 'AdMilage DESC')
				 begin
					set @SQL = @SQL + ' (Ad.MotorcycleAdCount.Milage > 1) and ' ;
				 end

			if(@carType != -3)
			begin
					set @SQL = @SQL + '(((Ad.MotorcycleAd.Milage = ' + cast(@carType as nvarchar(10)) + ' and (' + cast(@carType as nvarchar(10)) + ' = -1 or ' 
										+ cast(@carType as nvarchar(10))  + ' = 0)) '
						 + 'or (Ad.MotorcycleAd.Milage > 0 and ' + cast(@carType as nvarchar(10))  + ' = 1)) or ' + cast(@carType as nvarchar(10)) + ' = -3) and ';
			end

			if(@motorcycleType != 0)
			begin
				set @SQL = @SQL + ' (Ad.MotorcycleAdCount.MotorcycleTypeId = ' + cast(@motorcycleType as nvarchar(10)) + ') and ';
			end
			
			if(@province != 0)
			begin
				set @SQL = @SQL + ' (Ad.MotorcycleAdCount.ProvinceId = ' +cast(@province as nvarchar(10))+ ') and ';
			end

			if(@city != 0)
			begin
				set @SQL = @SQL + ' (Ad.MotorcycleAdCount.CityId = ' +cast(@city as nvarchar(10))+ ') and ';
			end

			if(@color != -1)
			begin
				set @SQL = @SQL + ' (Ad.MotorcycleAdCount.ColorID = ' +cast(@color as nvarchar(10))+ ') and ';
			end							

			if(@fuel != 0)
			begin
				set @SQL = @SQL + ' (Ad.MotorcycleAdCount.MotorcycleFuelTypeId = ' +cast(@fuel as nvarchar(10))+ ') and ';
			end

			IF(@firstDate != '' and @sort = 'BumpDate DESC,ModifiedDate DESC')
			BEGIN
				 SET @SQL = @SQL + ' ((Ad.MotorcycleAd.BumpDate <= N''' +cast(@firstDate as nvarchar(100))+ ''') OR (Ad.MotorcycleAd.ModifiedDate <= N''' 
				 			+cast(@firstDate as nvarchar(100))+ ''')) and ';
			END

			if(@motoryclePriceType = 2)
			begin
				set @SQL = @SQL + ' (ISNULL(Ad.MotorcycleAdCount.IsInstallmentSale, 0) = 1) and ';
			end
			else if(@motoryclePriceType = 3)
			begin
				set @SQL = @SQL + ' (ISNULL(Ad.MotorcycleAdCount.IsInstallmentSale, 0) = 0) and ';
			end

			set @SQL = @SQL + ' (1 = 1))';

	SET  @TSql = @SQL;
	
	SET @SQL += ' SELECT @cnt=COUNT(*) FROM CTE ';  
	print @Sql	 	
	EXECUTE sp_executesql @SQL, N'@cnt int OUTPUT', @cnt=@TCount OUTPUT;

	IF(@TCount>0)
	begin
		set  @TSql += ' SELECT *,'+   
		cast (@TCount as nvarchar(15)) + ' AS TotalRecord,0 as SimilarAds FROM CTE '+  
		' ORDER BY ' + @sort + 
		' OFFSET(' + cast(@PageOffset as nvarchar(10)) +') ROWS' +
		' FETCH NEXT ' + cast(@pageSize as nvarchar(10)) + ' ROWS ONLY';	
		print @TSql
		EXECUTE  sp_executesql  @TSql
	end 

	IF(@TCount <= 0)
	BEGIN
		IF (@brandId > 0)
		BEGIN

			 SET @SQL = 'WITH CTE AS '
				 + '(select  Ad.MotorcycleAdCount.MotorcycleModelId,
				Ad.MotorcycleAdCount.ModelYear,
				Ad.MotorcycleAdCount.Price as AdPrice,
				Ad.MotorcycleAdCount.Milage as AdMilage,
				Ad.MotorcycleAd.Description,			 
				Ad.MotorcycleAdCount.Color_Fa as Color,
				Ad.MotorcycleAdCount.Brand_Fa AS BrandName,
				Ad.MotorcycleAdCount.Model_Fa AS ModelName, 
				Ad.MotorcycleAdCount.Brand AS BrandNameEng,
				Ad.MotorcycleAdCount.Model AS ModelNameEng,
				Ad.MotorcycleAdCount.MotorcycleAdId as Id,
				Ad.MotorcycleAd.ModifiedDate as ModifiedDate,
				Ad.AdClass.BadgeEnabled as IsBadgeEnabled,
				Ad.AdClass.AdClassID as AdClassId,
				Ad.MotorcycleAd.DownPayment as DownPayment,
				Ad.MotorcycleAdCount.Displacement as Displacement,
				Ad.MotorcycleAd.UserArea as UserArea,
				Ad.MotorcycleAd.MonthlyPayment as MonthlyPayment,
				Ad.MotorcycleAd.DownPaymentSecondary as DownPaymentSecondary,
				Ad.MotorcycleAd.NumberOfMonth as NumberOfMonth,
				Ad.MotorcycleAd.NumberOfInstallment as NumberOfInstallment,
				Ad.MotorcycleAd.DeliveryInDays as DeliveryInDays,
				Ad.MotorcycleAd.IsPersonal as IsPersonal,			 
				Ad.MotorcycleAdImage.ImageFileURL as ImageUrl,
				Clients.Corporation.Title_Fa AS Corporation,			
				Clients.CorporateProfile.IsSecret as IsSecret,
				Vehicle.MotorcycleType.LogoURL as MotorcycleTypeImageUrl,
				Ad.MotorcycleAdCount.Province_Fa as Province,
				Ad.MotorcycleAdCount.City_Fa as City,
				Ad.MotorcycleAd.BumpDate as BumpDate,
				suc.URLCode as IdShortCode
				from Ad.MotorcycleAdCount
					 INNER JOIN Ad.MotorcycleAd on Ad.MotorcycleAdCount.MotorcycleAdId = Ad.MotorcycleAd.MotorcycleAdID	
					 INNER JOIN Ad.AdClass on Ad.MotorcycleAd.AdClassID = Ad.AdClass.AdClassID
					 LEFT JOIN Ad.MotorcycleAdImage on Ad.MotorcycleAd.PrefferedMotorcycleAdImageID = Ad.MotorcycleAdImage.MotorcycleAdImageID 
					 LEFT JOIN Clients.CorporateProfile ON Ad.MotorcycleAd.OwnedByCorpProfileID = Clients.CorporateProfile.CorporateProfileID 
					 LEFT JOIN Clients.Corporation ON Clients.Corporation.CorporationID = Clients.CorporateProfile.CorporationID 											
							   					 
					 LEFT JOIN Vehicle.MotorcycleType on Ad.MotorcycleAdCount.MotorcycleTypeId = Vehicle.MotorcycleType.MotorcycleTypeId
					 LEFT JOIN dbo.ShortURLCode suc WITH(NOLOCK) ON suc.RespectiveId = Ad.MotorcycleAd.MotorcycleAdId AND suc.PageId = 2
				where ';
								
			IF(@sort = 'AdPrice ASC')
				 BEGIN
					SET @SQL = @SQL + ' (Ad.MotorcycleAd.Price > 0) and ' ;
				 END

			SET @SQL = @SQL + ' (Ad.MotorcycleAdCount.MotorcycleBrandId = ' + cast(@brandId as nvarchar(10)) + ' or ' + cast(@brandId as nvarchar(10)) + ' = 0) and
					(Ad.MotorcycleAdCount.MotorcycleModelId = ' + cast(@modelId as nvarchar(10)) + ' or ' + cast(@modelId as nvarchar(10)) + ' = 0))';

			SET  @TSql = @SQL;				
			SET @SQL += ' SELECT @cnt=COUNT(*) FROM CTE ';		
			print @SQL
			EXECUTE sp_executesql @SQL, N'@cnt int OUTPUT',@cnt= @TCount OUTPUT;
			
			IF(@TCount>0)
			BEGIN
				SET @TSql +=  ' SELECT *,'+   
								'(SELECT count(1) FROM CTE) AS TotalRecord,1 as SimilarAds FROM CTE '+  
								' ORDER BY ' + @sort +						
								' OFFSET(' + cast(@PageOffset as nvarchar(10)) +') ROWS' +
								' FETCH NEXT ' + cast(@pageSize as nvarchar(10)) + ' ROWS ONLY';
						
				print @TSql
				EXECUTE  sp_executesql  @TSql
			END

			IF(@TCount <= 0)
				BEGIN
					 SET @SQL = 'WITH CTE AS '
								 + '(select  Ad.MotorcycleAdCount.MotorcycleModelId,
							Ad.MotorcycleAdCount.ModelYear,
							Ad.MotorcycleAdCount.Price as AdPrice,
							Ad.MotorcycleAdCount.Milage as AdMilage,
							Ad.MotorcycleAd.Description,			 
							Ad.MotorcycleAdCount.Color_Fa as Color,
							Ad.MotorcycleAdCount.Brand_Fa AS BrandName,
							Ad.MotorcycleAdCount.Model_Fa AS ModelName, 
							Ad.MotorcycleAdCount.Brand AS BrandNameEng,
							Ad.MotorcycleAdCount.Model AS ModelNameEng,
							Ad.MotorcycleAdCount.MotorcycleAdId as Id,
							Ad.MotorcycleAd.ModifiedDate as ModifiedDate,
							Ad.AdClass.BadgeEnabled as IsBadgeEnabled,
							Ad.AdClass.AdClassID as AdClassId,
							Ad.MotorcycleAdCount.Displacement as Displacement,
							Ad.MotorcycleAd.DownPayment as DownPayment,
							Ad.MotorcycleAd.UserArea as UserArea,
							Ad.MotorcycleAd.MonthlyPayment as MonthlyPayment,
							Ad.MotorcycleAd.DownPaymentSecondary as DownPaymentSecondary,
							Ad.MotorcycleAd.NumberOfMonth as NumberOfMonth,
							Ad.MotorcycleAd.NumberOfInstallment as NumberOfInstallment,
							Ad.MotorcycleAd.DeliveryInDays as DeliveryInDays,
							Ad.MotorcycleAd.IsPersonal as IsPersonal,			 
							Ad.MotorcycleAdImage.ImageFileURL as ImageUrl,
							Clients.Corporation.Title_Fa AS Corporation,	
							Clients.CorporateProfile.IsSecret as IsSecret,		
							Vehicle.MotorcycleType.LogoURL as MotorcycleTypeImageUrl,			 
							Ad.MotorcycleAdCount.Province_Fa as Province,
							Ad.MotorcycleAdCount.City_Fa as City,
							Ad.MotorcycleAd.BumpDate as BumpDate,
							suc.URLCode as IdShortCode
							from Ad.MotorcycleAdCount
									 INNER JOIN Ad.MotorcycleAd on Ad.MotorcycleAdCount.MotorcycleAdId = Ad.MotorcycleAd.MotorcycleAdID	
									 INNER JOIN Ad.AdClass on Ad.MotorcycleAd.AdClassID = Ad.AdClass.AdClassID
									 LEFT JOIN Ad.MotorcycleAdImage on Ad.MotorcycleAd.PrefferedMotorcycleAdImageID = Ad.MotorcycleAdImage.MotorcycleAdImageID 
									 LEFT JOIN Clients.CorporateProfile ON Ad.MotorcycleAd.OwnedByCorpProfileID = Clients.CorporateProfile.CorporateProfileID 
									 LEFT JOIN Clients.Corporation ON Clients.Corporation.CorporationID = Clients.CorporateProfile.CorporationID 																		   									 
									 LEFT JOIN Vehicle.MotorcycleType on Ad.MotorcycleAdCount.MotorcycleTypeId = Vehicle.MotorcycleType.MotorcycleTypeId
									 LEFT JOIN dbo.ShortURLCode suc WITH(NOLOCK) ON suc.RespectiveId = Ad.MotorcycleAd.MotorcycleAdId AND suc.PageId = 2
								where ';
								
						IF(@sort = 'AdPrice ASC')
							 BEGIN
								SET @SQL = @SQL + ' (Ad.MotorcycleAd.Price > 0) and ' ;
							 END

						SET @SQL = @SQL + ' (Ad.MotorcycleAdCount.MotorcycleBrandId = ' + cast(@brandId as nvarchar(10)) + ' or ' + cast(@brandId as nvarchar(10)) + ' = 0))';
						SET  @TSql = @SQL;
						SET @SQL += ' SELECT @cnt=COUNT(*) FROM CTE ';   
						print @SQL
						EXECUTE sp_executesql @SQL, N'@cnt int OUTPUT',@cnt=@TCount OUTPUT;

						IF(@TCount>=0)
							BEGIN
								set @TSql +=	' SELECT *,'+   
												'(SELECT count(1) FROM CTE) AS TotalRecord,2 as SimilarAds FROM CTE '+  
												' ORDER BY ' + @sort + 									
												' OFFSET(' + cast(@PageOffset as nvarchar(10)) +') ROWS' +
												' FETCH NEXT ' + cast(@pageSize as nvarchar(10)) + ' ROWS ONLY';
print @TSql
								EXECUTE  sp_executesql  @TSql
							END
   	 		    END
 	     END
	END
END