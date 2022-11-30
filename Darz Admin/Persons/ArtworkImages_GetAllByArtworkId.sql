ALTER PROCEDURE [dbo].[ArtworkImages_GetAllByArtworkId]  
	@ArtworkId int  
AS  
BEGIN  
 Select * from ArtworkImages WITH(NOLOCK) where ArtworkId = @ArtworkId  
END 
