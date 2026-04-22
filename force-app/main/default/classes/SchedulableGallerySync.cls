global class SchedulableGallerySync implements Schedulable, Database.AllowsCallouts {

    global void execute(SchedulableContext sc) {
        syncAllGalleries();
    }

    @InvocableMethod(label='Google Drive Galerie synchronisieren')
    public static void syncAllGalleries() {

        List<Id> galleryIds = new List<Id>();

        for (Gallery__c g : [
            SELECT Id
            FROM Gallery__c
            WHERE GoogleDriveFolderId__c != null
        ]) {
            galleryIds.add(g.Id);
        }

        if (!galleryIds.isEmpty()) {
            syncGalleriesFuture(galleryIds);
        }
    }

    // FUTURE WITH IDS ONLY
    @future(callout=true)
    public static void syncGalleriesFuture(List<Id> galleryIds) {

        List<Gallery__c> galleries = [
            SELECT Id, Name, GoogleDriveFolderId__c
            FROM Gallery__c
            WHERE Id IN :galleryIds
        ];

        ffhttp_GoogleDriveFiles files = getGoogleDriveClient().files();

        for (Gallery__c gallery : galleries) {

            if (gallery.GoogleDriveFolderId__c == null) {
                continue;
            }

            List<GalleryPhoto__c> newPhotos = new List<GalleryPhoto__c>();

            // === ROOT LEVEL ===
            ffhttp_GoogleDriveFiles.ListRequest listRequest = files.listRequest();
            listRequest.setFields('items(id,title,mimeType,webContentLink,alternateLink,thumbnailLink,fileExtension)');
            listRequest.setQ('\'' + gallery.GoogleDriveFolderId__c + '\' in parents');

            ffhttp_GoogleDriveModelFile.ItemList items =
                (ffhttp_GoogleDriveModelFile.ItemList) listRequest.execute();

            for (ffhttp_GoogleDriveModelFile item :
                 (List<ffhttp_GoogleDriveModelFile>) items.getItems()) {

                if (item.getMimeType() == 'application/vnd.google-apps.folder') {

                    processSubfolder(gallery, item, newPhotos, files);

                } else {
                    newPhotos.add(buildPhoto(gallery, item, null));
                }
            }

            // Replace existing
            delete [
                SELECT Id
                FROM GalleryPhoto__c
                WHERE Gallery__c = :gallery.Id
            ];

            if (!newPhotos.isEmpty()) {
                insert newPhotos;
            }
        }
    }

    private static void processSubfolder(
        Gallery__c gallery,
        ffhttp_GoogleDriveModelFile folder,
        List<GalleryPhoto__c> photoCollector,
        ffhttp_GoogleDriveFiles files
    ) {

        ffhttp_GoogleDriveFiles.ListRequest subRequest = files.listRequest();
        subRequest.setFields('items(id,title,mimeType,webContentLink,alternateLink,thumbnailLink,fileExtension)');
        subRequest.setQ('\'' + folder.getId() + '\' in parents');

        ffhttp_GoogleDriveModelFile.ItemList subItems =
            (ffhttp_GoogleDriveModelFile.ItemList) subRequest.execute();

        for (ffhttp_GoogleDriveModelFile fileItem :
             (List<ffhttp_GoogleDriveModelFile>) subItems.getItems()) {

            if (fileItem.getMimeType() != 'application/vnd.google-apps.folder') {
                photoCollector.add(buildPhoto(gallery, fileItem, folder.getTitle()));
            }
        }
    }

    private static GalleryPhoto__c buildPhoto(
        Gallery__c gallery,
        ffhttp_GoogleDriveModelFile file,
        String subfolderName
    ) {

        GalleryPhoto__c photo = new GalleryPhoto__c();

        String fullTitle = file.getTitle();
        if (fullTitle.length() > 80) {
            fullTitle = fullTitle.substring(0, 80);
        }

        String extension = '.' + file.getFileExtension();
        if (!String.isBlank(file.getFileExtension()) &&
            !fullTitle.endsWith(extension)) {
            fullTitle += extension;
        }

        photo.Name = fullTitle;
        photo.Gallery__c = gallery.Id;
        photo.FileUrl__c = file.getWebContentLink();
        photo.PreviewUrl__c = file.getAlternateLink();
        photo.ThumbnailUrl__c = 'https://drive.google.com/thumbnail?authuser=0&sz=w640&id=' + file.getId();
        photo.BigThumbnailUrl__c = 'https://drive.google.com/thumbnail?authuser=0&sz=w1920&id=' + file.getId();
        photo.Subfolder__c = subfolderName;

        return photo;
    }

    // ===== CONNECTOR =====

    public static ConnectorService connectorService;
    public static ffhttp_GoogleDrive client;

    public static ConnectorService getConnectorService() {

        if (connectorService == null) {

            Connector__c c = [
                SELECT TokenType__c, RefreshToken__c, RefreshTokenRequested__c,
                       Name, Id, AccessToken__c, AccessTokenRequested__c,
                       AccessTokenExpiry__c, Active__c,
                       ConnectorType__r.TokenEndpoint__c,
                       ConnectorType__r.Scope__c,
                       ConnectorType__r.ScopeRequired__c,
                       ConnectorType__r.RedirectUri__c,
                       ConnectorType__r.Name,
                       ConnectorType__r.Id,
                       ConnectorType__r.ExtraUrlParameters__c,
                       ConnectorType__r.DeveloperName__c,
                       ConnectorType__r.ClientSecret__c,
                       ConnectorType__r.ClientId__c,
                       ConnectorType__r.CallbackURL__c,
                       ConnectorType__r.AuthorizationEndpoint__c
                FROM Connector__c
                WHERE ConnectorType__r.Name = 'Google Drive'
                LIMIT 1
            ];

            connectorService = new ConnectorService(c);
        }

        return connectorService;
    }

    public static ffhttp_GoogleDrive getGoogleDriveClient() {

        if (client == null) {

            ConnectorService cs = getConnectorService();

            ffhttp_Client.ICredentials credentials =
                new ffhttp_Client.AccessTokenCredentials(
                    cs.connector.TokenType__c,
                    cs.getAccessToken()
                );

            client = new ffhttp_GoogleDrive(credentials);
        }

        return client;
    }
}