@isTest
public with sharing class DeleteDownloadLogsOlderThanYearBatchTest {
    @isTest
    private static void testIfLogsOlderThanYearWillBeDeleted(){
        Account bautraeger = TestDataFactory.createBautraeger(true);
        Property__c p = TestDataFactory.createProperty(true, bautraeger.Id);
        ImmobilienDMSDatei__c dmsDatei = TestDataFactory.createImmobilienDMSDatei(true, p.Id, 'Dokumente');
        Contact con=TestDataFactory.createContact(true);

        List<FileDownloadLog__c> logs =new List<FileDownloadLog__c>();
        for(integer i=0;i<100;i++){                        
            FileDownloadLog__c fdl =TestDataFactory.createFileDownloadLog(false,con.id);
            logs.add(fdl);    
        }
        insert logs;

        for(FileDownloadLog__c log :logs){           
            Test.setCreatedDate(log.id,DeleteDownloadLogsOlderThanYearBatch.CURRENT_DATE_MINUS_YEAR.addDays(-10)); 
        }
        List<FileDownloadLog__c> fdllist=[
            SELECT id 
            FROM FileDownloadLog__c 
            WHERE createdDate <: DeleteDownloadLogsOlderThanYearBatch.CURRENT_DATE_MINUS_YEAR
        ];


        Test.startTest();
        Database.executeBatch(new DeleteDownloadLogsolderThanYearBatch());
        Test.stopTest();

        fdllist=[
            SELECT id 
            FROM FileDownloadLog__c 
            WHERE createdDate <: DeleteDownloadLogsOlderThanYearBatch.CURRENT_DATE_MINUS_YEAR
        ];

        System.assertEquals(0, fdllist.size());
    }
    @isTest
    private static void testIfLogsYoungerThanYearWillNotBeDeleted(){
        Account bautraeger = TestDataFactory.createBautraeger(true);
        Property__c p = TestDataFactory.createProperty(true, bautraeger.Id);
        ImmobilienDMSDatei__c dmsDatei = TestDataFactory.createImmobilienDMSDatei(true, p.Id, 'Dokumente');
        Contact con=TestDataFactory.createContact(true);

        List<FileDownloadLog__c> logs =new List<FileDownloadLog__c>();
        for(integer i=0;i<100;i++){                        
            FileDownloadLog__c fdl =TestDataFactory.createFileDownloadLog(false,con.id);
            logs.add(fdl);    
        }
        insert logs;

        List<FileDownloadLog__c> fdllist=[
            SELECT id 
            FROM FileDownloadLog__c 
        ];
        Test.startTest();
        Database.executeBatch(new DeleteDownloadLogsolderThanYearBatch());
        Test.stopTest();
        fdllist=[
            SELECT id 
            FROM FileDownloadLog__c 
        ];
    }
}