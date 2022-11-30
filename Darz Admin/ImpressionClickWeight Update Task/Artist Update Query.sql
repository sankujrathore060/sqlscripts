---- Update Artist_ImpressionClickCount
------------------------------------------------------------------------------
UPDATE ImpressionClickCount_TypeWeight
	SET TypeName = 'Searching_For_Artist_Click', [Weight] = 'A', Point = 3.00
	WHERE MainTypeName = 'Artist_ImpressionClickCount_TypeName' AND TypeName = 'Searching_For_Artist';

UPDATE ImpressionClickCount_TypeWeight
	SET TypeName = 'Artist_Page_Tabs_Click', [Weight] = 'B', Point = 2.00
	WHERE MainTypeName = 'Artist_ImpressionClickCount_TypeName' AND TypeName = 'Artist_Detail_Tabs';

UPDATE ImpressionClickCount_TypeWeight
	SET TypeName = 'Artists_List_Artist_Pass_Artist_Impression', [Weight] = 'D', Point = 0.50
	WHERE MainTypeName = 'Artist_ImpressionClickCount_TypeName' AND TypeName = 'Artists_List_Impression';

UPDATE ImpressionClickCount_TypeWeight
	SET TypeName = 'Artists_List_Artist_Pass_Artist_Impression', [Weight] = 'D', Point = 0.50
	WHERE MainTypeName = 'Artist_ImpressionClickCount_TypeName' AND TypeName = 'Artists_List_Impression';

UPDATE ImpressionClickCount_TypeWeight
	SET TypeName = 'Artists_Gallery_Page_Artist_Tab_Artist_Click', [Weight] = 'B', Point = 2.00
	WHERE MainTypeName = 'Artist_ImpressionClickCount_TypeName' AND TypeName = 'Gallery_Detail_Artist_Tab_Click';

UPDATE ImpressionClickCount_TypeWeight
	SET TypeName = 'Artists_Gallery_Page_Artist_Tab_Artist_Pass_Impression', [Weight] = 'E', Point = 0.25
	WHERE MainTypeName = 'Artist_ImpressionClickCount_TypeName' AND TypeName = 'Gallery_Detail_Artist_Tab_Artist_Impression';
