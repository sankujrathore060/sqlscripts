USE Bama;

-- DROP TABLE Mashinchi.PublicHoliday

CREATE TABLE Mashinchi.PublicHoliday
(
	PublicHolidayId INT IDENTITY(1,1),
	HolidayDate DATETIME NOT NULL,
	IsActive BIT,
	Description NVARCHAR(255),
	CreatedDate DATETIME NOT NULL,	

	CONSTRAINT PK_MashinchiPublicHoliday PRIMARY KEY (PublicHolidayId)
)
GO

INSERT INTO Mashinchi.PublicHoliday(HolidayDate, IsActive, CreatedDate)
 			VALUES('2021-02-25', 1, GETDATE()),
 					('2021-03-11', 1, GETDATE()),
					('2021-03-20', 1, GETDATE()),
					('2021-03-21', 1, GETDATE()),
					('2021-03-22', 1, GETDATE()),
					('2021-03-23', 1, GETDATE()),
					('2021-03-24', 1, GETDATE()),
					('2021-03-29', 1, GETDATE()),
					('2021-04-01', 1, GETDATE()),
					('2021-05-04', 1, GETDATE()),
					('2021-05-13', 1, GETDATE()),
					('2021-06-05', 1, GETDATE()),
					('2021-06-06', 1, GETDATE()),
					('2021-07-21', 1, GETDATE()),
					('2021-07-29', 1, GETDATE()),
					('2021-08-18', 1, GETDATE()),
					('2021-08-19', 1, GETDATE()),
					('2021-09-27', 1, GETDATE()),
					('2021-10-05', 1, GETDATE()),
					('2021-10-07', 1, GETDATE()),
					('2021-10-24', 1, GETDATE()),
					('2022-01-06', 1, GETDATE()),
					('2022-02-15', 1, GETDATE()),
					('2022-03-01', 1, GETDATE()),
					('2022-03-20', 1, GETDATE())
GO

SELECT * FROM Mashinchi.PublicHoliday

select getdate()

select * from Mashinchi.ServiceType