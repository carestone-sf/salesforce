@isTest
private class SchedulableDownloadIntranetDashboardTest {
    
    // Basic mock class to simulate an HTTP 200 response with PNG content
    private class MockHttpResponse implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setStatusCode(200);
            // Body can be any string; we just need a Blob in the final code
            // In real life, you could store base64-encoded PNG bytes or any dummy data
            res.setBody('Fake PNG data');
            return res;
        }
    }
    
    @isTest
    static void testDownloadPngAndInsertDocument() {
        
        // 1. Set up the mock
        Test.setMock(HttpCalloutMock.class, new MockHttpResponse());
        
        // 2. Schedule the job
        //    This is optional. We can directly call the job’s execute() 
        //    method inside Test.startTest/stopTest if we prefer not to schedule.
        String cronExp = '0 0 2 * * ?'; 
        String jobId   = System.schedule('Test Download PNG Job', cronExp, new SchedulableDownloadIntranetDashboard());
        
        // 3. Execute test
        Test.startTest();
        // When we call Test.stopTest(), scheduled jobs execute.
        Test.stopTest();
        
        // 4. Validate results
        // Make sure a document was inserted
        // Adjust the WHERE clause if you named the doc differently in your apex job
        List<Document> docs = [
            SELECT Id, Name, BodyLength 
            FROM Document
            WHERE Name LIKE 'dashboard_intranet'
        ];
        
        System.assertEquals(1, docs.size(), 'One Document should have been inserted.');
        System.assertEquals(
            true, 
            docs[0].BodyLength > 0, 
            'Inserted Document should have some blob content.'
        );
    }
}
