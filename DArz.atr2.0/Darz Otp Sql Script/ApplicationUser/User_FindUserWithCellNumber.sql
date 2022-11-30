---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

-- User_FindUserWithCellNumber
-- ***********************************************************************************************
-- SP NAME: User_FindUserWithCellNumber
-- DESCRIPTION: find user infomartion with cell number and password
-- CREATED: VIPUL KAVA - 13Aug2021
-- ***********************************************************************************************CREATE PROCEDURE [dbo].[User_FindUserWithCellNumber](	@CellNumber as nvarchar(265),	@Password as nvarchar(100))ASBEGIN			SET NOCOUNT ON;
		SET TRANSACTION ISOLATION LEVEL SNAPSHOT;			SELECT 
			u.*,
			u.PhoneNumber as PhoneNumber,
			u.UserID as Id
		FROM 
			[ApplicationUser] u WITH (NOLOCK)
		WHERE 
			u.PhoneNumber = @CellNumber 
			AND [Password] = @Password
END

