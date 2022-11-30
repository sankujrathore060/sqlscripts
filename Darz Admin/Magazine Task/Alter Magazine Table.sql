--SP_HELPTEXT [GetAllMagazines]

--USE DARZ

--ALTER TABLE Magazines 
--ADD Author NVARCHAR(50) NOT NULL DEFAULT '', Authorfa NVARCHAR(50) NOT NULL DEFAULT '', VerificationStatus SMALLINT DEFAULT 0

--ALTER TABLE Magazines 
--ADD [Date] DATETIME NOT NULL DEFAULT '', MagazineDate DATETIME NOT NULL DEFAULT ''



--ALTER TABLE Magazines 
--ADD CheckingType INT NOT NULL DEFAULT 0


--SELECT * FROM MagazineCategory
--SELECT * FROM Magazines

--SP_HELPTEXT [DeleteMagazine]

--SP_hELPTEXT [ChangeVerificationStatusGrid]

--SP_HELPTEXT [GetMagazinesByName]

--ALTER TABLE Magazines
--ADD Body NVARCHAR(MAX), BodyFa NVARCHAR(MAX), Tools NVARCHAR(MAX),
--	 ToolsFa NVARCHAR(MAX), MagazineCoverImageUri NVARCHAR(256),
--	 ReadingTime NVARCHAR(50), ReadingTimeFa NVARCHAR(50)  


--ALTER TABLE Magazines
--ADD ImageHeight INT, ImageWidth INT

--ALTER TABLE Magazines
--ADD Title NVARCHAR(50), TitleFa NVARCHAR(50), Section NVARCHAR(50),
--	Category INT, SubCategory INT  

--ALTER TABLE Magazines
--DROP COLUMN Tools, ToolsFa

--ALTER TABLE Magazines
--ADD Body NVARCHAR(MAX), BodyFa NVARCHAR(MAX)

SP_HELP mAGAZINES