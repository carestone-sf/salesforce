@isTest
public with sharing class ers_QueryNRecordsTest {

    static testMethod void testQueryNRecordsForSpecifiedType() {

        TestDataFactory.createAccount(true, 'Test1', 'Type1');
        TestDataFactory.createAccount(true, 'Test2', 'Type2');

        ers_QueryNRecords.QueryParameters testRequest = new ers_QueryNRecords.QueryParameters();
        testRequest.objectApiName = 'Account';
        testRequest.fieldsToQuery = 'Name, AccountNumber, Website, Type, Description';
        testRequest.numberOfRecords = 3;

        List<ers_QueryNRecords.QueryParameters> testRequestList = new List<ers_QueryNRecords.QueryParameters>();
        testRequestList.add(testRequest);

        List<ers_QueryNRecords.QueryResults> testResponseList = ers_QueryNRecords.getNRecords(testRequestList);
        System.assert(testResponseList[0].recordString.contains('"Type":"Type2"'));

    }

}