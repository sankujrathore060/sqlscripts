CREATE PROCEDURE [dbo].[ArtworkFromMarket_GetYearParts]
AS  
BEGIN  
		SET TRANSACTION ISOLATION LEVEL SNAPSHOT;

		;WITH cte AS (  
			SELECT ROW_NUMBER() OVER(ORDER BY [year]) AS row,  
				*  
			FROM   (  
					SELECT DISTINCT   
							SUBSTRING(CONVERT(VARCHAR(10), CreationYear), 1, 3) +   
							'0' AS [year]   
					--into #temp  
					FROM  vw_ArtworkFromMarket  ar
					inner join Artist a on ar.ArtistId = a.Id
					WHERE  CreationYear IS NOT NULL and CreationYear > 0  and a.VerificationStatus = 2
					GROUP BY  
							CreationYear  
				) AS tbl  
		)  
		SELECT 
			ISNULL(c.year, '') + '-' + cast((cast(c.year as int) + 9) as nvarchar) AS YEAR  
		FROM   
			cte c  
			LEFT JOIN cte c1 ON  (c.row + 1) = c1.row
		WHERE
			c.year > 1700
		ORDER BY c.year DESC
		--WHERE  c1.row IS NOT NULL  
END  