CREATE PROCEDURE [dbo].[BackOfficeRolesMashinchi_GetAll]
AS
BEGIN
    SET TRANSACTION ISOLATION LEVEL SNAPSHOT;

    SET NOCOUNT ON;

    SELECT
        *
    FROM
        [Clients].[BackOfficeRoles] WHERE Name LIKE 'Mashin%';
END;