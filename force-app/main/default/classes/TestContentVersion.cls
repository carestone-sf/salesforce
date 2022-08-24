@IsTest
public with sharing class TestContentVersion {

    public static testMethod void testMaBVRechnungCreation() {
        Id finanzierungsanfragenRecordTypeId = Schema.getGlobalDescribe().get('ContentVersion').getDescribe().getRecordTypeInfosByName().get('Finanzierungsanfragen').getRecordTypeId();

        ContentVersion cv=new Contentversion();
        cv.title='Rechnung';
        cv.PathOnClient ='Rechnung';
        cv.versiondata=EncodingUtil.base64Decode('Unit Test Attachment Body');
        cv.Typ__c = 'Personalausweis';
        cv.RecordTypeId = finanzierungsanfragenRecordTypeId;
        insert cv;

        cv = [SELECT Title FROM ContentVersion];
        System.assertEquals('Personalausweis', cv.Title);


        // get code coverage for update methods
        cv.Description = 'Test';
        update cv;
    }
}