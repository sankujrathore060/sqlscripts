ALTER PROCEDURE [dbo].[proc_GetMostSearchData] 
	@userId BIGINT = 0
AS
BEGIN
    SET TRANSACTION ISOLATION LEVEL SNAPSHOT;

    SELECT TOP (5)
           UserId,
           HeaderId AS Id,
           (CASE
                WHEN PartId = 1 THEN
                   (
                       SELECT (CASE
                                   WHEN (FirstName IS NULL AND LastName IS NULL AND Nickname IS NOT NULL) THEN
                                       LTRIM(RTRIM(Nickname))
                                   ELSE
                                       LTRIM(RTRIM(FirstName)) + ' ' + LTRIM(RTRIM(LastName))
                               END
                              )
                       FROM
                              Artist
                       WHERE
                              Id = HeaderId
                   )
                WHEN PartId = 2 THEN
                   (SELECT Name FROM Gallery WITH(NOLOCK) WHERE Id = HeaderId)
                WHEN PartId = 3 THEN
                   (SELECT Title FROM vw_Artwork WITH(NOLOCK) WHERE Id = HeaderId)
                WHEN PartId = 4 THEN
                   (
                       SELECT
                           ah.Name + '_' + dbo.fn_DateFormat(ActualDate)
                       FROM
                           AuctionHouse ah WITH(NOLOCK)
                           INNER JOIN AuctionEvent ae WITH(NOLOCK) ON ah.Id = ae.AuctionHouse
                           INNER JOIN AuctionEventArtwork aer WITH(NOLOCK) ON aer.AuctionEventId = ae.Id
                           INNER JOIN ArtWork a WITH(NOLOCK) ON a.Id = aer.ArtworkId
                       WHERE
                           ae.Id = HeaderId
                           AND a.VerificationStatus = 2
                       GROUP BY
                           ae.Id,
                           ActualDate,
                           [Name]
                   )
				 WHEN PartId IN (8,9) THEN
				 (
					Name
				 )
            END
           ) AS [Name],
           (CASE
                WHEN PartId = 1 THEN
                   (
                       SELECT (CASE
                                   WHEN (FirstNameFa IS NULL AND LastNameFa IS NULL AND NicknameFa IS NOT NULL) THEN
                                       LTRIM(RTRIM(NicknameFa))
                                   ELSE
                                       LTRIM(RTRIM(FirstNameFa)) + ' ' + LTRIM(RTRIM(LastNameFa))
                               END
                              )
                       FROM
                              Artist WITH(NOLOCK)
                       WHERE
                              Id = HeaderId
                   )
                WHEN PartId = 2 THEN
                   (SELECT NameFa FROM Gallery WITH(NOLOCK) WHERE Id = HeaderId)
                WHEN PartId = 3 THEN
                   (SELECT TitleFa FROM vw_Artwork WITH(NOLOCK) WHERE Id = HeaderId)
                WHEN PartId = 4 THEN
                   (
                       SELECT
                           ah.NameFa + '_' + dbo.fn_DateFaFormat(ActualDateFa)
                       FROM
                           AuctionHouse ah WITH(NOLOCK)
                           INNER JOIN AuctionEvent ae WITH(NOLOCK) ON ah.Id = ae.AuctionHouse
                           INNER JOIN AuctionEventArtwork aer WITH(NOLOCK) ON aer.AuctionEventId = ae.Id
                           INNER JOIN ArtWork a WITH(NOLOCK) ON a.Id = aer.ArtworkId
                       WHERE
                           ae.Id = HeaderId
                           AND a.VerificationStatus = 2
                       GROUP BY
                           ae.Id,
                           ActualDateFa,
                           NameFa
                   )
				WHEN PartId = 8 THEN
					(
					 SELECT TitleFa FROM vw_GalleryShows WHERE Id = HeaderId
					)
				WHEN PartId = 9 THEN
					(
					 SELECT TitleFa FROM vw_MuseumShows WHERE Id = HeaderId
					)
            END
           ) AS NameFa,
           [FirstName],
           [LastName],
           [NickName],
           [Count],
           PartId
    INTO
           #temp
    FROM
  MostSearchRecords
    WHERE
           UserId = @userId
    ORDER BY
           [Count] DESC;



    SELECT
        t.*,
        Picture,
        Medium,
        ArtistId,
        CreationYear,
        CreationYearFa
        --CASE
        --    WHEN (Height <> 0.000 AND Height <> -1 AND (Width = 0.000 OR Width = -1) AND (Depth = 0.000 OR Depth = -1)) THEN
        --        CAST(CONVERT(DOUBLE PRECISION, ROUND(Height, 1)) AS VARCHAR)
        --    WHEN ((Height = 0.000 OR Height = -1) AND Width <> 0.000 AND Width <> -1 AND (Depth = 0.000 OR Depth = -1)) THEN
        --        CAST(CONVERT(DOUBLE PRECISION, ROUND(Width, 1)) AS VARCHAR)
        --    WHEN ((Height = 0.000 OR Height = -1) AND (Width = 0.000 OR Width = -1) AND Depth <> 0.000 AND Depth <> -1) THEN
        --        CAST(CONVERT(DOUBLE PRECISION, ROUND(Depth, 1)) AS VARCHAR)
        --    WHEN (Height <> 0.000 AND Width <> 0.000 AND Height <> -1 AND Width <> -1 AND (Depth = 0.000 OR Depth = -1)) THEN
        --        CONCAT(
        --              CONVERT(DOUBLE PRECISION, ROUND(Height, 1)),
        --              ' &times; ',
        --              CONVERT(DOUBLE PRECISION, ROUND(Width, 1))
        --              )
        --    WHEN ((Height = 0.000 OR Height = -1) AND Width <> 0.000 AND Depth <> 0.000 AND Width <> -1 AND Depth <> -1) THEN
        --        CONCAT(
        --              CONVERT(DOUBLE PRECISION, ROUND(Width, 1)),
        --              ' &times; ',
        --              CONVERT(DOUBLE PRECISION, ROUND(Depth, 1))
        --              )
        --    WHEN (Height <> 0.000 AND Height <> -1 AND (Width = 0.000 OR Width = -1) AND Depth <> 0.000 AND Depth <> -1) THEN
        --        CONCAT(
        --              CONVERT(DOUBLE PRECISION, ROUND(Height, 1)),
        --              ' &times; ',
        --              CONVERT(DOUBLE PRECISION, ROUND(Depth, 1))
        --              )
        --    WHEN (Height <> 0.000 AND Width <> 0.000 AND Depth <> 0.000 AND Height <> -1 AND Width <> -1 AND Depth <> -1) THEN
        --        CONCAT(
        --                  CONVERT(DOUBLE PRECISION, ROUND(Height, 1)),
        --                  ' &times; ',
        --                  CONVERT(DOUBLE PRECISION, ROUND(Width, 1)),
        --                  ' &times; ',
        --                  CONVERT(DOUBLE PRECISION, ROUND(Depth, 1))
        --              )
        ----when (Height = 0.000 and Width = 0.000 and Depth = 0.000)        
        ----then '- &times; - &times; -'      
        --END AS Size
    INTO
        #mainTbl
    FROM
        vw_Artwork a WITH(NOLOCK)
        RIGHT JOIN #temp t ON t.Id = a.Id;


    SELECT
        *
    FROM
        #mainTbl;
END;