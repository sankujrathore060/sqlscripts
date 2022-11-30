CREATE PROCEDURE [dbo].[ArtworkImages_DeleteById]  
@Id int  
AS  
BEGIN   
 DELETE FROM ArtworkImages
 WHERE Id = @Id 
END 