CREATE PROCEDURE [dbo].[GetMagazineBodyImageByMagazineId]  
@magazineId int  
AS  
BEGIN  
 Select * from MagazineBodyImage where MagazineId = @magazineId   
END 