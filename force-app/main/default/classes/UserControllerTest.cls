@isTest
public class UserControllerTest {

    @isTest
    static void testSavingUserSettings() {
        ContentVersion cv=new Contentversion();
        cv.title='ABC';
        cv.PathOnClient ='test';
        cv.versiondata=EncodingUtil.base64Decode('Unit Test Attachment Body');
        Id angebotRecordTypeId = Schema.getGlobalDescribe().get('ContentVersion').getDescribe().getRecordTypeInfosByName().get('Vertriebsportal').getRecordTypeId();
        cv.Typ__c = 'Angebot';
        cv.RecordTypeId = angebotRecordTypeId;
        insert cv;

        ContentVersion cv2=new Contentversion();
        cv2.title='ABC';
        cv2.PathOnClient ='test';
        cv2.versiondata=EncodingUtil.base64Decode('Unit Test Attachment Body');
        cv2.Typ__c = 'Angebot';
        cv2.RecordTypeId = angebotRecordTypeId;
        insert cv2;
        User u = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];
        UserController.saveUserSettings(u, cv.Id, cv2.Id);
    }

}