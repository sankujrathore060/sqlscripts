CREATE PROCEDURE [dbo].[WebsiteSettings_Update]
(
    @Id AS TINYINT,
    @IsTestNet AS BIT,
    @ShutDown AS BIT,
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

    UPDATE
        [dbo].[WebsiteSettings]
    SET
        [IsTestNet] = @IsTestNet,
        [ShutDown] = @ShutDown,
        [ModifiedDate] = @ModifiedDate,
        [ShutDownMessage] = @ShutDownMessage,
        [DisableType1Ad] = @DisableType1Ad,
        [DisableDate] = @DisableDate,
        DisableType1AdStart = @DisableType1AdStart,
        DisableType1AdEnd = @DisableType1AdEnd
    WHERE
        Id = @Id; -- Return the ID
END;
