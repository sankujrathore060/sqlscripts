ALTER PROCEDURE [dbo].[DeleteMagazineBodyImage]   
@Id int   
AS  
BEGIN  
Delete from MagazineBodyImage where Id = @Id  
END 