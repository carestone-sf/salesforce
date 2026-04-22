global class MockHttpResponseGeneratorFirebase implements HttpCalloutMock {
    global HTTPResponse respond(HTTPRequest req) {
        HttpResponse res = new HttpResponse();
        
        if (req.getEndpoint().contains('oauth2.googleapis.com/token')) {
            // Simulate a successful token response
            res.setStatusCode(200);
            res.setHeader('Content-Type', 'application/json');
            res.setBody('{"access_token":"FAKE_ACCESS_TOKEN","token_type":"Bearer","expires_in":3600}');
        } else if (req.getEndpoint().contains('fcm.googleapis.com')) {
            // Simulate a successful FCM message response
            res.setStatusCode(200);
            res.setHeader('Content-Type', 'application/json');
            res.setBody('{"name":"projects/carestone-connect/messages/abc123"}');
        } else {
            // Unknown endpoint
            res.setStatusCode(404);
            res.setBody('{"error":"Not Found"}');
        }
        
        return res;
    }
}