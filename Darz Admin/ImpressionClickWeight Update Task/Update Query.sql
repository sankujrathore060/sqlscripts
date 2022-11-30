-- Update Gallery_ImpressionClickCount
---------------------------------------------------------------------------
UPDATE ImpressionClickCount_TypeWeight
	SET TypeName = 'Searching_For_Gallery_Click', [Weight] = 'A', Point = 3.00
	WHERE MainTypeName = 'Gallery_ImpressionClickCount_TypeName' AND TypeName = 'Searching_For_Gallery';

UPDATE ImpressionClickCount_TypeWeight
	SET TypeName = 'Searching_For_Artists_Of_Gallery_Click', [Weight] = 'B', Point = 2.00
	WHERE MainTypeName = 'Gallery_ImpressionClickCount_TypeName' AND TypeName = 'Searching_For_Artist_Of_Gallery';

UPDATE ImpressionClickCount_TypeWeight
	SET TypeName = 'Gallery_Page_Tabs_Click', [Weight] = 'B', Point = 2.00
	WHERE MainTypeName = 'Gallery_ImpressionClickCount_TypeName' AND TypeName = 'Gallery_Detail_Tabs';

UPDATE ImpressionClickCount_TypeWeight
	SET TypeName = 'Gallery_Page_Artist_Tab_Artist_Click', [Weight] = 'B', Point = 2.00
	WHERE MainTypeName = 'Gallery_ImpressionClickCount_TypeName' AND TypeName = 'Gallery_Detail_Artist_Tab_Artist_Click';

UPDATE ImpressionClickCount_TypeWeight
	SET TypeName = 'Gallery_Page_Artworks_Tab_Artowrk_Click_IV', [Weight] = 'B', Point = 2.00
	WHERE MainTypeName = 'Gallery_ImpressionClickCount_TypeName' AND TypeName = 'Gallery_Detail_Artworks_Tab_Artowrks_Click_IV';

UPDATE ImpressionClickCount_TypeWeight
	SET TypeName = 'Gallery_Page_Artists_Tabs_Artist_Click', [Weight] = 'B', Point = 2.00
	WHERE MainTypeName = 'Gallery_ImpressionClickCount_TypeName' AND TypeName = 'Gallery_Detail_Artist_Tab_Click';

UPDATE ImpressionClickCount_TypeWeight
	SET TypeName = 'Gallery_Page_Shows_Tab_Show_Click', [Weight] = 'B', Point = 2.00
	WHERE MainTypeName = 'Gallery_ImpressionClickCount_TypeName' AND TypeName = 'Gallery_Detail_Shows_Tab_Click';

UPDATE ImpressionClickCount_TypeWeight
	SET TypeName = 'Gallery_Page_Artfairs_Tab_Artfair_Click', [Weight] = 'B', Point = 2.00
	WHERE MainTypeName = 'Gallery_ImpressionClickCount_TypeName' AND TypeName = 'Gallery_Detail_Artfair_Tab_Click';

UPDATE ImpressionClickCount_TypeWeight
	SET TypeName = 'Gallery_Page_Shows_Tab_Show_Click', [Weight] = 'B', Point = 2.00
	WHERE MainTypeName = 'Gallery_ImpressionClickCount_TypeName' AND TypeName = 'Gallery_Detail_Shows_Tab_Show_Click';
	
UPDATE ImpressionClickCount_TypeWeight
	SET TypeName = 'Gallery_Page_Artists_Tabs_Pass_Impression', [Weight] = 'C', Point = 1.00
	WHERE MainTypeName = 'Gallery_ImpressionClickCount_TypeName' AND TypeName = 'Gallery_Detail_Artist_Tab_Impression';

UPDATE ImpressionClickCount_TypeWeight
	SET TypeName = 'Gallery_Page_Artfair_Tab_Pass_Impression', [Weight] = 'C', Point = 1.00
	WHERE MainTypeName = 'Gallery_ImpressionClickCount_TypeName' AND TypeName = 'Gallery_Detail_Artfair_Tab_Impression';

UPDATE ImpressionClickCount_TypeWeight
	SET TypeName = 'Gallery_Page_Artworks_Tab_Pass_Impression', [Weight] = 'C', Point = 1.00
	WHERE MainTypeName = 'Gallery_ImpressionClickCount_TypeName' AND TypeName = 'Gallery_Detail_Artworks_Tab_Artwork_Impression';

UPDATE ImpressionClickCount_TypeWeight
	SET TypeName = 'Gallery_Page_Shows_Tab_Pass_Impression', [Weight] = 'C', Point = 1.00
	WHERE MainTypeName = 'Gallery_ImpressionClickCount_TypeName' AND TypeName = 'Gallery_Detail_Shows_Tab_Impression';

UPDATE ImpressionClickCount_TypeWeight
	SET TypeName = 'Gallery_List_Gallery_Click', [Weight] = 'B', Point = 2.00
	WHERE MainTypeName = 'Gallery_ImpressionClickCount_TypeName' AND TypeName = 'Gallery_List_Gallery_Click';

UPDATE ImpressionClickCount_TypeWeight
	SET TypeName = 'Gallery_List_Gallery_Pass_Impression', [Weight] = 'D', Point = 0.5
	WHERE MainTypeName = 'Gallery_ImpressionClickCount_TypeName' AND TypeName = 'Gallery_List_Impression';

UPDATE ImpressionClickCount_TypeWeight
	SET TypeName = 'Shows_List_Gallerys_Show_Click', [Weight] = 'A', Point = 3.00
	WHERE MainTypeName = 'Gallery_ImpressionClickCount_TypeName' AND TypeName = 'Show_Detail_Gallery_Show_Click';

UPDATE ImpressionClickCount_TypeWeight
	SET TypeName = 'Shows_List_Gallerys_Show_Pass_Impression', [Weight] = 'C', Point = 1.00
	WHERE MainTypeName = 'Gallery_ImpressionClickCount_TypeName' AND TypeName = 'Shows_List_Gallery_Shows_Impression';

UPDATE ImpressionClickCount_TypeWeight
	SET TypeName = 'Shows_List_Gallerys_Show_Pass_Impression', [Weight] = 'C', Point = 1.00
	WHERE MainTypeName = 'Gallery_ImpressionClickCount_TypeName' AND TypeName = 'Shows_List_Gallery_Shows_Impression';

UPDATE ImpressionClickCount_TypeWeight
	SET TypeName = 'Artists_List_Gallerys_Artist_Pass_Impression', [Weight] = 'D', Point = 0.5
	WHERE MainTypeName = 'Gallery_ImpressionClickCount_TypeName' AND TypeName = 'Artists_List_Gallery_Artists_Impression';

UPDATE ImpressionClickCount_TypeWeight
	SET TypeName = 'Artwork_List_Artwork_Assigend_To_Gallery_Pass_Impression', [Weight] = 'E', Point = 0.25
	WHERE MainTypeName = 'Gallery_ImpressionClickCount_TypeName' AND TypeName = 'Artwork_List_Gallery_Assigend_Artwork_List_Impression';

UPDATE ImpressionClickCount_TypeWeight
	SET TypeName = 'Artwork_List_Artwork_Assigend_To_Gallery_Click_IV', [Weight] = 'C', Point = 1.00
	WHERE MainTypeName = 'Gallery_ImpressionClickCount_TypeName' AND TypeName = 'Artwork_List_Gallery_Assigend_Artwork_Click';

UPDATE ImpressionClickCount_TypeWeight
	SET TypeName = 'Artfair_List_Gallery_Assigned_Pass_Impression', [Weight] = 'C', Point = 1.00
	WHERE MainTypeName = 'Gallery_ImpressionClickCount_TypeName' AND TypeName = 'Artfair_Detail_Gallery_Assigned';

UPDATE ImpressionClickCount_TypeWeight
	SET TypeName = 'Artfair_List_Gallerys_Artist_Assigned_To_Artfair_Pass_Impression', [Weight] = 'C', Point = 1.00
	WHERE MainTypeName = 'Gallery_ImpressionClickCount_TypeName' AND TypeName = 'Artfair_Detail_Artist_From_Gallery_Impression';

UPDATE ImpressionClickCount_TypeWeight
	SET TypeName = 'Auctions_List_Gallerys_Artist_Pass_Impression', [Weight] = 'D', Point = 0.50
	WHERE MainTypeName = 'Gallery_ImpressionClickCount_TypeName' AND TypeName = 'Auctions_List_Gallery_Artist_Impression';

UPDATE ImpressionClickCount_TypeWeight
	SET TypeName = 'Auctions_List_Artwork_Assigend_To_Gallery_Artwork_IV_Click', [Weight] = 'B', Point = 2.00
	WHERE MainTypeName = 'Gallery_ImpressionClickCount_TypeName' AND TypeName = 'Auctions_List_Gallery_Assigend_Artworks_Detail_IV';





	
	