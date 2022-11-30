ALTER PROCEDURE [dbo].[MotorcycleAdCount_GetRightNavigationCityList]
	-- Add the parameters for the stored procedure here
		
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	WITH CTE AS
	(SELECT adCount.CityId,COUNT(adCount.CityId) as Count
	FROM Ad.MotorcycleAdCount adCount
	WHERE ISNULL(adCount.CityId, '') <> ''
	GROUP BY adCount.CityId)

	SELECT 
		c.CityId as IdNew, 
		c.CityName as Title,
		c.CityName_Fa as Title_Fa,
		(CAST(c.CityId AS nvarchar(20)) +','+ c.CityName) as IdTitle,
		CTE.Count
	FROM 
		dbo.City c with(nolock)
		INNER JOIN CTE ON CTE.CityId = c.CityId
END


