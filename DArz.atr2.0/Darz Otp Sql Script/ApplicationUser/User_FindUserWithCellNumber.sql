---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

-- User_FindUserWithCellNumber
-- ***********************************************************************************************
-- SP NAME: User_FindUserWithCellNumber
-- DESCRIPTION: find user infomartion with cell number and password
-- CREATED: VIPUL KAVA - 13Aug2021
-- ***********************************************************************************************
		SET TRANSACTION ISOLATION LEVEL SNAPSHOT;
			u.*,
			u.PhoneNumber as PhoneNumber,
			u.UserID as Id
		FROM 
			[ApplicationUser] u WITH (NOLOCK)
		WHERE 
			u.PhoneNumber = @CellNumber 
			AND [Password] = @Password
END
