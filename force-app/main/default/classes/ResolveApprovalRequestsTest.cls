@isTest
public with sharing class ResolveApprovalRequestsTest {

    // Create New Request and Test Error Response
    @isTest(SeeAllData=true)
    public static void executeTest() {
        // Get Current User Id
        String userId = UserInfo.getUserId();

        // Create Contact
        Contact con = TestDataFactory.createContact(false);
        con.Aus_Maklerportal__c = true;
        con.Gesch_ftsbeziehung__c = 'Interessent';
        insert(con);

        // Create an approval request for the account
        Approval.ProcessSubmitRequest req1 = new Approval.ProcessSubmitRequest();
        req1.setComments('Submitting request for approval.');
        req1.setObjectId(con.id);

        // Submit the approval request for the account
        Approval.ProcessResult result = Approval.process(req1);

        // Create Request Object
        List<ResolveApprovalRequest.Requests> requests = new List<ResolveApprovalRequest.Requests>();
        ResolveApprovalRequest.Requests req = new ResolveApprovalRequest.Requests();
        req.action = 'Approve';
        req.comments = 'Test Comments';
        req.recordId = con.Id;
        req.objName = 'Contact';
        req.nextApproverIds = new List<String>{userId};

        // Add req to requests
        requests.add(req);

        // Run Test
        Test.startTest();
        //ResolveApprovalRequest r = new ResolveApprovalRequest();
        ResolveApprovalRequest.execute(requests);
        Test.stopTest();
    }
}