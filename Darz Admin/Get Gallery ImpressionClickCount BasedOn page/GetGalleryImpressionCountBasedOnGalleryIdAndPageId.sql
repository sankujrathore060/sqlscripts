--PageTypeName	Weight	Point	Real_ImpressionCount Total_ImpressionCount	Real_ClickCount	Total_ClickCount Total_Count	
--DateOfRecord	IpAddress

--SELECT * FROM dbo.Gallery_ImpressionClickCount WHERE	GalleryId = 16
--SELECT * FROM dbo.ImpressionClickCount_TypeWeight

SELECT 
	SUM(ISNULL(gicc.ImpressionCount, 0)) AS Total_ImpressionCount, 
	SUM(ISNULL(gicc.ClickCount, 0)) AS Total_ClickCount,
	SUM(ISNULL(gicc.ImpressionCount, 0) + ISNULL(gicc.ClickCount, 0)) AS Total_Count,
	GalleryId,
	PageId
INTO 
#tmpClickCount
FROM 
	dbo.Gallery_ImpressionClickCount AS gicc
	INNER JOIN dbo.ImpressionClickCount_TypeWeight AS icc 
	ON icc.TypeId = gicc.TypeId AND icc.MainTypeName = 'Gallery_ImpressionClickCount_TypeName'
	GROUP BY GalleryId,PageId
	ORDER BY GalleryId DESC

SELECT 
	TypeName AS PageTypeName, [Weight], 
	Point, ImpressionCount AS Real_ImpressionCount,
	ClickCount AS Real_ClickCount, RecordDate AS DateOfRecord, IpAddress, GalleryId, PageId
INTO #tmpAllRecord
FROM 
	dbo.Gallery_ImpressionClickCount AS gicc
	INNER JOIN dbo.ImpressionClickCount_TypeWeight AS icc 
	ON icc.TypeId = gicc.TypeId AND icc.MainTypeName = 'Gallery_ImpressionClickCount_TypeName'

SELECT *
FROM
#tmpClickCount tcc
INNER JOIN #tmpAllRecord tar ON tcc.GalleryId = tar.GalleryId AND tcc.PageId = tar.PageId

DROP TABLE #tmpClickCount
DROP TABLE #tmpAllRecord

