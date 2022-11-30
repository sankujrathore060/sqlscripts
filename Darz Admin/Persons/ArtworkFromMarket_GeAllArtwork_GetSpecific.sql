CREATE PROCEDURE [dbo].[ArtworkFromMarket_GeAllArtwork_GetSpecific]
	@userId uniqueidentifier = null,
	@PageArtworkIDs varchar(max) = null,
	@FirstArtworkId int = 0
AS    
BEGIN    
		SET TRANSACTION ISOLATION LEVEL SNAPSHOT  
		SET NOCOUNT ON;

		SELECT DISTINCT			
			aw.Id,    
			aw.ArtistId,    
			CASE       
			when (aw.CreationYear <> 0 and aw.CreationYear <> -1)    
			then aw.CreationYear    
			ELSE NUll    
			End as CreationYear,
			CASE       
			when (aw.CreationYearFa <> 0 and aw.CreationYearFa <> -1 and aw.CreationYearFa <> -622)    
			then aw.CreationYearFa    
			ELSE NUll    
			End as CreationYearFa,    
			aw.Title,    
			aw.TitleFa,    
			aw.Category,    
			aw.Medium,    
			aw.MediumFa,    
			aw.Collaboration,    
			aw.CollaborationFa,    
			aw.IsAuctionRecord,    
			aw.Series,    
			aw.SeriesFa,    
			aw.Height,
			aw.Width,
			aw.depth,
			aw.Length,
			aw.SizeUnit,					
			aw.Picture,    
			aw.ImageHeight,    
			aw.ImageWidth,    
			f.Id as FavouriteId,    
			aw.ModifiedDate,    
			(CASE WHEN aw.VerificationStatus = 2    
			THEN 1    
			WHEN aw.VerificationStatus = 3    
			THEN 2    
			WHEN aw.VerificationStatus = 1    
			THEN 3    
			ELSE 4 END) as VerificationStatus,    
			LTRIM(RTRIM(a.NickName)) as NickName,    
			LTRIM(RTRIM(a.FirstName)) as FirstName,    
			LTRIM(RTRIM(a.LastName)) as LastName,    
			(CASE     
			WHEN (FirstName is null and LastName is null and Nickname is not null)     
			THEN LTRIM(RTRIM(Nickname))     
			ELSE LTRIM(RTRIM(FirstName)) +' '+ LTRIM(RTRIM(LastName)) END) as ArtistName,
			(CASE     
			WHEN (FirstNameFa is null and FirstNameFa is null and NicknameFa is not null)     
			THEN LTRIM(RTRIM(NicknameFa))     
			ELSE LTRIM(RTRIM(FirstNameFa)) +' '+ LTRIM(RTRIM(LastNameFa)) END) as ArtistNameFa,
			a.VerificationStatus AS Artist_VerificationStatus,
			aw.ArtworkEdition,
			aw.ArtworkEditionFa
		INTO #artworkResults
		FROM   
			vw_ArtworkFromMarket aw WITH(NOLOCK)
			INNER JOIN Artist as a WITH(NOLOCK) on aw.ArtistId = a.Id        
			LEFT JOIN Favourites f WITH(NOLOCK) on aw.Id = f.MainId and f.UserId = @UserId	
			LEFT JOIN TagArtwork awt with(nolock) on awt.ArtworkId = aw.Id
			LEFT JOIN Tags t with(nolock) on awt.TagId = t.TagId		
		WHERE  
			aw.VerificationStatus = 2 and a.VerificationStatus = 2
			AND aw.Id in (SELECT VALUE FROM Split(@pageArtworkIDs, ','))
		
		DECLARE @RecordCount INT    
		SELECT 
			@RecordCount = COUNT(*)
		FROM 
			#artworkResults

		SELECT 
			aw.*    
		FROM   
			#artworkResults aw
		WHERE aw.Id = @FirstArtworkId
		UNION ALL
		SELECT 
			aw.*    
		FROM   
			#artworkResults aw
		WHERE aw.Id <> @FirstArtworkId
		-- ORDER BY 			
		-- 	NEWID() ASC, 
		-- 	ISNULL(CreationYear, 0) DESC,			
		-- 	VerificationStatus, ModifiedDate DESC		

		DROP TABLE #artworkResults
END