ALTER PROCEDURE [dbo].[proc_GetMuseumsByName] 
	@Name VARCHAR(255)
AS
BEGIN
    SET TRANSACTION ISOLATION LEVEL SNAPSHOT;

    SET NOCOUNT ON;

    SELECT
        m.Id,
        m.[Name],
        m.NameFa,
        m.Logo,
        m.Description AS MuseumDescription,
        m.DescriptionFa AS MuseumDescriptionFa,
        m.VisitorInformation,
        m.VisitorInformationFa,
        m.Programs,
        m.ProgramsFa,
        m.LogoImageHeight,
        m.LogoImageWidth,
        m.[Image] AS PosterImageUri,
        m.ImageHeight AS PosterImageHeight,
        m.ImageWidth AS PosterImageWidth,
        m.[Address],
        m.AddressFa,
        m.Phone,
        m.SecondPhoneNumber,
        m.Website,
        m.Introduction,
        m.IntroductionFa,
        m.Latitude,
        m.Longitude,
        m.WorkingHour,
        m.IsPermanent,
        c.CityCode,
        co.CountryCode,
		m.DayOffText,
		m.DayOffTextFa,
		m.IsDayOffTextDisplayInWebsite,
		m.OpenTimeFriday,
		m.CloseTimeFriday

    FROM
        Museum AS m
        LEFT JOIN City c ON c.Id = m.CityId
        LEFT JOIN Country co ON co.Id = m.CountryId
    -- left join MuseumEvents as me on m.Id = me.MuseumId  
    WHERE
        (
            CHARINDEX('-', @Name) > 0
            AND dbo.RemoveNonUrlChar(m.Name) LIKE REPLACE(@Name, '-', ' ')
            OR dbo.RemoveNonUrlChar(m.Name) = @Name
        )
		AND m.VerificationStatus = 2;
END;