CREATE PROCEDURE [dbo].[ArtworkFromMarket_GetAllPersianYears]
AS
BEGIN
		SET TRANSACTION ISOLATION LEVEL SNAPSHOT;

		;WITH cte AS (
		SELECT 
			ROW_NUMBER() OVER(ORDER BY [yearFa]) AS row,
			*
		FROM   (
					SELECT DISTINCT 
							--SUBSTRING(CONVERT(VARCHAR(10), CreationYearFa), 1, 3) + 
							--'0' AS [YearFa]
							(case when (len(CreationYearFa) < 4 ) then
							'0'+(SUBSTRING(CONVERT(VARCHAR(10), CreationYearFa), 1, 2) +'0')
							ELSE
							(SUBSTRING(CONVERT(VARCHAR(10), CreationYearFa), 1, 3) + '0')
							END 
							) AS [YearFa]
						--into #temp
					FROM   vw_ArtworkFromMarket
					WHERE  CreationYearFa IS NOT NULL and CreationYearFa > 0
					GROUP BY
							CreationYearFa
				) AS tbl
		)
		SELECT 
			ISNULL(c.YearFa, '') + '-' + 
			(case when (len(cast(c.YearFa as int)) < 4 ) then '0' +cast((cast(c.YearFa as int) + 9) as nvarchar)
				ELSE cast((cast(c.YearFa as int) + 9) as nvarchar) END)AS YearFa
		FROM   
			cte c
			LEFT JOIN cte c1 ON  (c.row + 1) = c1.row
		WHERE
			c.YearFa < 2000
		ORDER BY
			c.YearFa DESC
		--WHERE  c1.row IS NOT NULL
END