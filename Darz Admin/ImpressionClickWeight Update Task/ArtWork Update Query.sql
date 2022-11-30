---- Update Artwork_ImpressionClickCount
------------------------------------------------------------------------------
UPDATE ImpressionClickCount_TypeWeight
	SET TypeName = 'Searching_For_Artists_Artworks_Click', [Weight] = 'A', Point = 3.00
	WHERE MainTypeName = 'Artwork_ImpressionClickCount_TypeName' AND TypeName = 'Searching_For_Artwork';

UPDATE ImpressionClickCount_TypeWeight
	SET TypeName = 'Artist_Page_Artworks_Tab_Artowrk_Click_IV', [Weight] = 'B', Point = 2.00
	WHERE MainTypeName = 'Artwork_ImpressionClickCount_TypeName' AND TypeName = 'Artist_Artworks_Tab_Artowrks_Click_IV';

UPDATE ImpressionClickCount_TypeWeight
	SET TypeName = 'Artist_Page_Artworks_Tab_Artwork_Click_IV_Next_Previous', [Weight] = 'B', Point = 2.00
	WHERE MainTypeName = 'Artwork_ImpressionClickCount_TypeName' AND TypeName = 'Artworks_IV_Next_Previous';

UPDATE ImpressionClickCount_TypeWeight
	SET TypeName = 'Artist_Page_Artworks_Tab_Artwork_Pass_Impression', [Weight] = 'D', Point = 0.50
	WHERE MainTypeName = 'Artwork_ImpressionClickCount_TypeName' AND TypeName = 'Artist_Artworks_Tab_Artworks_Impression';

UPDATE ImpressionClickCount_TypeWeight
	SET TypeName = 'Artist_Page_Auction_Tab_Artwork_Pass_Impression', [Weight] = 'D', Point = 0.50
	WHERE MainTypeName = 'Artwork_ImpressionClickCount_TypeName' AND TypeName = 'Artist_Auction_Tab_Artworks_Impression';

UPDATE ImpressionClickCount_TypeWeight
	SET TypeName = 'Artist_Page_Auction_Tab_Artwork_IV_Click', [Weight] = 'B', Point = 2.00
	WHERE MainTypeName = 'Artwork_ImpressionClickCount_TypeName' AND TypeName = 'Auctions_Artworks_Detail_IV';

UPDATE ImpressionClickCount_TypeWeight
	SET TypeName = 'Artists_Gallery_Page_Overview_Tab_When_Artist_Assigend_to_Current_Show_Pass_Impression', [Weight] = 'C', Point = 1.00
	WHERE MainTypeName = 'Artwork_ImpressionClickCount_TypeName' AND TypeName = 'Gallery_Detail_Overview_Tab';

UPDATE ImpressionClickCount_TypeWeight
	SET TypeName = 'Artists_Gallery_Page_Artworks_Tab_Artists_Artwork_Pass_Impression', [Weight] = 'E', Point = 0.25
	WHERE MainTypeName = 'Artwork_ImpressionClickCount_TypeName' AND TypeName = 'Gallery_Detail_Artwork_Tab';

UPDATE ImpressionClickCount_TypeWeight
	SET TypeName = 'Artworks_List_Artwork_Assigend_To_Artist_Pass_Impression', [Weight] = 'E', Point = 0.25
	WHERE MainTypeName = 'Artwork_ImpressionClickCount_TypeName' AND TypeName = 'Artworks_List_Impression';

UPDATE ImpressionClickCount_TypeWeight
	SET TypeName = 'Artwork_List_Artists_Artwork_Click_IV', [Weight] = 'B', Point = 2.00
	WHERE MainTypeName = 'Artwork_ImpressionClickCount_TypeName' AND TypeName = 'Artworks_List_Click_IV';

UPDATE ImpressionClickCount_TypeWeight
	SET TypeName = 'Show_List_Artist_Assigned_To_Show_Pass_Impression', [Weight] = 'D', Point = 0.50
	WHERE MainTypeName = 'Artwork_ImpressionClickCount_TypeName' AND TypeName = 'Show_Detail_Impression';

UPDATE ImpressionClickCount_TypeWeight
	SET TypeName = 'Artfair_List_Artists_Gallery_Assigned_To_Artfair_Pass_Impression', [Weight] = 'E', Point = 0.25
	WHERE MainTypeName = 'Artwork_ImpressionClickCount_TypeName' AND TypeName = 'Artfair_Detail';

UPDATE ImpressionClickCount_TypeWeight
	SET TypeName = 'Auction_List_Artists_Artworks_Pass_Impression', [Weight] = 'E', Point = 0.25
	WHERE MainTypeName = 'Artwork_ImpressionClickCount_TypeName' AND TypeName = 'Auctions_Artworks_List_Impression';

UPDATE ImpressionClickCount_TypeWeight
	SET TypeName = 'Biennale_List_Artist_Assigend_To_Biennale_Pass_Impression', [Weight] = 'E', Point = 0.25
	WHERE MainTypeName = 'Artwork_ImpressionClickCount_TypeName' AND TypeName = 'Biennale_Detail';

UPDATE ImpressionClickCount_TypeWeight
	SET TypeName = 'Museum_List_Artist_Assigend_To_Museum_Pass_Impression', [Weight] = 'E', Point = 0.25
	WHERE MainTypeName = 'Artwork_ImpressionClickCount_TypeName' AND TypeName = 'Museum_Detail';

UPDATE ImpressionClickCount_TypeWeight
	SET TypeName = 'Auction_List_Artist_Assigend_To_Auction_Pass_Impression', [Weight] = 'E', Point = 0.25
	WHERE MainTypeName = 'Artwork_ImpressionClickCount_TypeName' AND TypeName = 'Auction_Detail_Impression';

UPDATE ImpressionClickCount_TypeWeight
	SET TypeName = 'Museum_Page_Artworks_Collection_Artists_Artworks_Click_IV', [Weight] = 'B', Point = 2.00
	WHERE MainTypeName = 'Artwork_ImpressionClickCount_TypeName' AND TypeName = 'Museum_Event_Detail';



