---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- User_CheckCellNumberExists '091252525252'
-- ***********************************************************************************************
-- SP NAME: User_CheckCellNumberExists
-- DESCRIPTION: CHECK USER WITH CELLNUMBER EXISTS OR NOT
-- CREATED: VIPUL KAVA - 13Aug2021
-- MODIFICATION LOG:
--		* ADDED IsActive CONDITION - 13Feb2019 - VIPUL KAVA
-- ***********************************************************************************************
CREATE PROCEDURE User_CheckCellNumberExists (@CellNumber NVARCHAR(50) = NULL, @IsActive BIT = 0)
AS
BEGIN
    SET TRANSACTION ISOLATION LEVEL SNAPSHOT;
    SET NOCOUNT ON;

    SELECT TOP 1
           *
    FROM
           [ApplicationUser] WITH (NOLOCK)
    WHERE
           PhoneNumber = @CellNumber
    ORDER BY
           ModifyDate DESC;
END;
