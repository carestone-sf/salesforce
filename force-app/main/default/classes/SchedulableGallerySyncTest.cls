@isTest
private class SchedulableGallerySyncTest {

    @TestSetup
    static void setupData() {

        ConnectorType__c ct = new ConnectorType__c(
            Name = 'Google Drive',
            AuthorizationEndpoint__c = 'https://accounts.google.com/o/oauth2/auth',
            TokenEndpoint__c = 'https://accounts.google.com/o/oauth2/token',
            ClientId__c = 'test',
            ClientSecret__c = 'test',
            RedirectUri__c = 'https://test',
            ScopeRequired__c = true,
            Scope__c = 'https://www.googleapis.com/auth/drive'
        );
        insert ct;

        Connector__c c = new Connector__c(
            Name = 'Google Drive',
            ConnectorType__c = ct.Id,
            TokenType__c = 'Bearer',
            AccessToken__c = 'abc'
        );
        insert c;

        Gallery__c gallery = new Gallery__c(
            Name = 'Test Gallery',
            GoogleDriveFolderId__c = 'root-folder-id'
        );
        insert gallery;
    }

    @isTest
    static void testSyncGallery() {

        Test.setMock(HttpCalloutMock.class, new GoogleDriveGalleryMock());

        Test.startTest();

        SchedulableGallerySync.syncAllGalleries();

        Test.stopTest();

        List<GalleryPhoto__c> photos = [
            SELECT Name, Subfolder__c, FileUrl__c, PreviewUrl__c, ThumbnailUrl__c
            FROM GalleryPhoto__c
        ];

        System.assertEquals(2, photos.size());

        for (GalleryPhoto__c p : photos) {
            System.assertEquals('Haupttag', p.Subfolder__c);
            System.assertNotEquals(null, p.FileUrl__c);
            System.assertNotEquals(null, p.PreviewUrl__c);
            System.assertNotEquals(null, p.ThumbnailUrl__c);
        }
    }

    @isTest
    static void testSchedulableExecution() {

        Test.setMock(HttpCalloutMock.class, new GoogleDriveGalleryMock());

        Test.startTest();

        String jobId = System.schedule(
            'Gallery Sync Test',
            '0 0 0 1 1 ? 2099',
            new SchedulableGallerySync()
        );

        Test.stopTest();

        CronTrigger ct = [
            SELECT CronExpression, TimesTriggered
            FROM CronTrigger
            WHERE Id = :jobId
        ];

        System.assertEquals('0 0 0 1 1 ? 2099', ct.CronExpression);
    }
}