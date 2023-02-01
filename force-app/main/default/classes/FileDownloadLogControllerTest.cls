@IsTest
public class FileDownloadLogControllerTest {
    @isTest
    private static void wasFileDownloadLogCreated(){
        Contact con =TestDataFactory.createContact(true);
        ImmobilienDMSDatei__c dmsDatei = TestDataFactory.createImmobilienDMSDatei(true);

        List<FileDownloadLog__c> logslist =[SELECT id FROM FileDownloadLog__c];
        System.assertEquals(0, logslist.size());

        FileDownloadLogController.createFileDownloadLog(con.id, dmsDatei.id);

        logslist =[SELECT id FROM FileDownloadLog__c];
        System.assertEquals(1, logslist.size());
    }
}