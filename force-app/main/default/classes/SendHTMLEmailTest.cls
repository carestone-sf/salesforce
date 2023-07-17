@isTest
public with sharing class SendHTMLEmailTest {


    @isTest
    public static void CanSendEmail () {

        SendHTMLEmail.Request testReq = new SendHTMLEmail.Request();
        testReq.HTMLbody = 'this is the body';
        testReq.Subject = 'this is the subject';
        testReq.SendTOthisOneEmailAddress = 'test@foo.com';
        testReq.SendCCthisOneEmailAddress = 'test@foo.com';
        testReq.SendBCCthisOneEmailAddress = 'test@foo.com';

        List<SendHTMLEmail.Request> reqList = new List<SendHTMLEmail.Request>();
        reqList.add(testReq);

        Test.startTest();
        List<SendHTMLEmail.Response> testResponseList = SendHTMLEmail.SendEmail(reqList);
        Test.stopTest();
        
        System.assertEquals(testResponseList[0].isSuccess,true);



    }

    @isTest
    public static void errorIfNoAddress () {

        SendHTMLEmail.Request testReq = new SendHTMLEmail.Request();
        testReq.HTMLbody = 'this is the body';
        testReq.Subject = 'this is the subject';
        //testReq.SendTOthisOneEmailAddress = 'test@foo.com';

        List<SendHTMLEmail.Request> reqList = new List<SendHTMLEmail.Request>();
        reqList.add(testReq);

        Test.startTest();
        List<SendHTMLEmail.Response> testResponseList = SendHTMLEmail.SendEmail(reqList);
        Test.stopTest();

        System.assertEquals(testResponseList[0].isSuccess,false);



    }

    @isTest
    public static void errorIfBothTemplateandBody () {

        SendHTMLEmail.Request testReq = new SendHTMLEmail.Request();
        testReq.HTMLbody = 'this is the body';
        testReq.templateID = 'temp';
        testReq.Subject = 'this is the subject';
        testReq.SendTOthisOneEmailAddress = 'test@foo.com';

        List<SendHTMLEmail.Request> reqList = new List<SendHTMLEmail.Request>();
        reqList.add(testReq);
        Boolean exceptionHit=false;

        Test.startTest();
        try {
            List<SendHTMLEmail.Response> testResponseList = SendHTMLEmail.SendEmail(reqList);
        
        } catch (SendHTMLEmail.FlowEmailActionException e) {
            exceptionHit=true;
        }
        Test.stopTest();
        System.assertEquals(true, exceptionHit);



    }

     @isTest
    public static void errorIfTemplateButNoContextRecord () {

        SendHTMLEmail.Request testReq = new SendHTMLEmail.Request();
        //testReq.HTMLbody = 'this is the body';
        testReq.templateID = 'temp';
        testReq.Subject = 'this is the subject';
        testReq.SendTOthisOneEmailAddress = 'test@foo.com';

        List<SendHTMLEmail.Request> reqList = new List<SendHTMLEmail.Request>();
        reqList.add(testReq);
		Boolean exceptionHit=false;

        Test.startTest();
        try {
            List<SendHTMLEmail.Response> testResponseList = SendHTMLEmail.SendEmail(reqList);
        
        } catch (SendHTMLEmail.FlowEmailActionException e) {
            exceptionHit=true;
        }
        Test.stopTest();
        System.assertEquals(true, exceptionHit);
       

    }

    @isTest
    public static void sendToListOfStrings () {

        SendHTMLEmail.Request testReq = new SendHTMLEmail.Request();
        testReq.HTMLbody = 'this is the body';
        testReq.Subject = 'this is the subject';
        testReq.SendTOthisStringCollectionOfEmailAddresses = new List<String>{'test@foo.com','test2@foo.com'};

        List<SendHTMLEmail.Request> reqList = new List<SendHTMLEmail.Request>();
        reqList.add(testReq);
		Boolean exceptionHit=false;

        Test.startTest();
        List<SendHTMLEmail.Response> testResponseList = SendHTMLEmail.SendEmail(reqList);
        Test.stopTest();

        Assert.areEqual(testResponseList[0].isSuccess,true);
    }

    @isTest
    public static void sendToListOfContacts () {

        SendHTMLEmail.Request testReq = new SendHTMLEmail.Request();
        testReq.HTMLbody = 'this is the body';
        testReq.Subject = 'this is the subject';
        testReq.SendTOtheEmailAddressesFromThisCollectionOfContacts = new List<Contact>(TestDataFactory.createContacts(true, 10));

        List<SendHTMLEmail.Request> reqList = new List<SendHTMLEmail.Request>();
        reqList.add(testReq);
		Boolean exceptionHit=false;

        Test.startTest();
        List<SendHTMLEmail.Response> testResponseList = SendHTMLEmail.SendEmail(reqList);
        Test.stopTest();

        Assert.areEqual(testResponseList[0].isSuccess,true);
    }

    @isTest
    public static void sendToListOfLeads () {

        SendHTMLEmail.Request testReq = new SendHTMLEmail.Request();
        testReq.HTMLbody = 'this is the body';
        testReq.Subject = 'this is the subject';
        testReq.SendTOtheEmailAddressesFromThisCollectionOfLeads = new List<Lead>(TestDataFactory.createLeads(true, 10));

        List<SendHTMLEmail.Request> reqList = new List<SendHTMLEmail.Request>();
        reqList.add(testReq);
		Boolean exceptionHit=false;

        Test.startTest();
        List<SendHTMLEmail.Response> testResponseList = SendHTMLEmail.SendEmail(reqList);
        Test.stopTest();

        Assert.areEqual(testResponseList[0].isSuccess,true);
    }

    @isTest
    public static void sendToListOfUsers () {

        SendHTMLEmail.Request testReq = new SendHTMLEmail.Request();
        testReq.HTMLbody = 'this is the body';
        testReq.Subject = 'this is the subject';
        testReq.SendTOtheEmailAddressesFromThisCollectionOfUsers = new List<User>(TestDataFactory.createStandardUsers(true, 10));

        List<SendHTMLEmail.Request> reqList = new List<SendHTMLEmail.Request>();
        reqList.add(testReq);
		Boolean exceptionHit=false;

        Test.startTest();
        List<SendHTMLEmail.Response> testResponseList = SendHTMLEmail.SendEmail(reqList);
        Test.stopTest();

        Assert.areEqual(testResponseList[0].isSuccess,true);
    }


}