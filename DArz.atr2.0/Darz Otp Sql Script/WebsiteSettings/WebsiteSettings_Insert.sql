CREATE PROCEDURE [dbo].[WebsiteSettings_Insert]
(
    @IsTestNet AS BIT,
    @ShutDown AS BIT,
    @rowguid AS UNIQUEIDENTIFIER,
    @ModifiedDate AS DATETIME,
    @ShutDownMessage AS NVARCHAR(MAX) = NULL,
    @DisableType1Ad AS BIT = 0,
    @DisableDate AS NVARCHAR(100) = NULL,
    @DisableType1AdStart DATETIME = NULL,
    @DisableType1AdEnd DATETIME = NULL
)
AS
BEGIN
    SET NOCOUNT ON;

    INSERT [dbo].[WebsiteSettings] ([IsTestNet], [ShutDown], [rowguid], [ModifiedDate], [ShutDownMessage],
    [DisableType1Ad], [DisableDate], DisableType1AdStart, DisableType1AdEnd)
    VALUES (
        @IsTestNet, @ShutDown, @rowguid, @ModifiedDate, @ShutDownMessage, @DisableType1Ad, @DisableDate,
        @DisableType1AdStart, @DisableType1AdEnd
    );

    -- Return the new ID
    SELECT
        SCOPE_IDENTITY();
END;