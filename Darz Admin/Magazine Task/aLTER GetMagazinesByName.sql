ALTER PROCEDURE [dbo].[GetMagazinesByName]  
 @name nvarchar(500)   
AS  
BEGIN  
 SET TRANSACTION ISOLATION LEVEL SNAPSHOT;  
    SET NOCOUNT ON;  
 SELECT * FROM Magazines WHERE Name = @name    
END  

SELECT * FROM Magazines



SP_HELPTEXT [GetAllMuseumOrGetMuseumById]

SELECT * FROM Museum