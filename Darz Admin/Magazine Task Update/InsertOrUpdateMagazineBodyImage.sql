ALTER PROCEDURE [dbo].[InsertOrUpdateMagazineBodyImage]
    @Id INT = 0,
    @MagazineId INT = NULL,
    @FileName NVARCHAR(200) = NULL,
    @BodyPicture NVARCHAR(256) = NULL,
    @BodyPictureHeight INT = 0,
    @BodyPictureWidth INT = 0,
    @ModifiedDate DATETIME,
    @rowguid UNIQUEIDENTIFIER,
    @StatementType TINYINT = 0,
    @BodyImageInfo NVARCHAR(50) = '',
    @Hyperlink NVARCHAR(MAX) = '',
	@BodyCode NVARCHAR(MAX) = ''
AS
BEGIN
		IF @StatementType = 1
		BEGIN
			INSERT INTO [dbo].[MagazineBodyImage] ([MagazineId], [FileName], [BodyPicture], [BodyPictureHeight],
								[BodyPictureWidth], [ModifiedDate], [rowguid], [BodyImageInfo], [HyperLink], [BodyCode])
					VALUES (@MagazineId, @FileName, @BodyPicture, @BodyPictureHeight, @BodyPictureWidth, @ModifiedDate, @rowguid,
						@BodyImageInfo, @Hyperlink, @BodyCode);

			SELECT @@IDENTITY;
		END
		BEGIN
				UPDATE	
					[dbo].[MagazineBodyImage]
				SET
					[BodyImageInfo] = @BodyImageInfo,
					[HyperLink] = @HyperLink,
					[BodyPictureWidth] = @BodyPictureWidth,
					BodyPictureHeight = @BodyPictureHeight,
					[ModifiedDate] = @ModifiedDate,
					BodyCode = @BodyCode
				WHERE	
					Id = @Id;
		END;
END;
