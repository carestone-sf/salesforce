@IsTest
public class FileDownloadLogControllerTest {
    @isTest
    private static void wasFileDownloadLogCreated(){
        Contact con = TestDataFactory.createContact(true);
        Account bautraeger = TestDataFactory.createBautraeger(true);
        Property__c p = TestDataFactory.createProperty(true, bautraeger.Id);
        ImmobilienDMSDatei__c dmsDatei = TestDataFactory.createImmobilienDMSDatei(true, p.Id, 'Dokumente');

        List<FileDownloadLog__c> logslist =[SELECT id FROM FileDownloadLog__c];
        System.assertEquals(0, logslist.size());

        FileDownloadLogController.createFileDownloadLog(dmsDatei.Id);

        logslist =[SELECT id FROM FileDownloadLog__c];
        System.assertEquals(1, logslist.size());
    }
}