@isTest
global class GoogleDriveGalleryMock implements HttpCalloutMock {

    global HTTPResponse respond(HTTPRequest req) {

        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        res.setStatusCode(200);

        String endpoint = req.getEndpoint() == null ? '' : req.getEndpoint();

        // Root folder list call
        if (endpoint.contains('root-folder-id')) {

            res.setBody(
            '{ "items": [' +
                '{ "id": "sub1", "title": "Haupttag", "mimeType": "application/vnd.google-apps.folder" }' +
            '] }'
            );
        }

        // Subfolder list call
        else if (endpoint.contains('sub1')) {

            res.setBody(
            '{ "items": [' +
                '{ "id": "img1", "title": "bild1", "mimeType": "image/jpeg",' +
                '"webContentLink": "https://file1",' +
                '"alternateLink": "https://preview1",' +
                '"thumbnailLink": "https://thumb1",' +
                '"fileExtension": "jpg" },' +

                '{ "id": "img2", "title": "bild2", "mimeType": "image/jpeg",' +
                '"webContentLink": "https://file2",' +
                '"alternateLink": "https://preview2",' +
                '"thumbnailLink": "https://thumb2",' +
                '"fileExtension": "jpg" }' +
            '] }'
            );
        }
        else {
            // Keep JSON valid for any unexpected request shape.
            res.setBody('{ "items": [] }');
        }

        return res;
    }
}