CREATE PROCEDURE [dbo].[ArtworkImages_InsertOrUpdate]
    @Id INT = 0,
    @ArtworkId INT = NULL,
    @FileName NVARCHAR(500) = NULL,
    @Picture NVARCHAR(MAX) = NULL,
    @PictureHeight INT = 0,
    @PictureWidth INT = 0,
    @ModifiedDate DATETIME,
    @rowguid UNIQUEIDENTIFIER,
    @StatementType TINYINT = 0
AS
BEGIN
    IF @StatementType = 1
    BEGIN
        INSERT INTO [dbo].[ArtworkImages] ([ArtworkId], [FileName], [Picture],
				[PictureHeight], [PictureWidth], [ModifiedDate], [rowguid])
        VALUES (
            @ArtworkId, @FileName, @Picture, @PictureHeight, @PictureWidth,
            @ModifiedDate, @rowguid
        );
    END;
    ELSE
    BEGIN
        UPDATE
            [dbo].[ArtworkImages]
        SET
            [ArtworkId] = @ArtworkId,
            [FileName] = @FileName,
            [Picture] = @Picture,
            [PictureHeight] = @PictureHeight,
            [PictureWidth] = @PictureWidth,
            [ModifiedDate] = @ModifiedDate,
            [rowguid] = @rowguid
        WHERE
            Id = @Id;
    END;
END;