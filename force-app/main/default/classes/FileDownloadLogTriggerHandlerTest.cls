@isTest
public with sharing class FileDownloadLogTriggerHandlerTest {
    @istest
    private static void testInsertingRecordsWithNumberOfRecordsThatNotExceedsLimit(){
        ImmobilienDMSDatei__c dmsDatei =TestDataFactory.createImmobilienDMSDatei(true);
        Contact con=TestDataFactory.createContact(true);

        List<FileDownloadLog__c> logs =new List<FileDownloadLog__c>();
        string errorMessage=null;
        for(integer i=0;i<FileDownloadLogTriggerHandler.FILE_DOWNLOAD_LOG_RECORDS_LIMIT_TEST;i++){    
            FileDownloadLog__c fdl =TestDataFactory.createFileDownloadLog(false,con.id,dmsDatei.id);
            logs.add(fdl);
        }
        try{ 
            insert logs;           
        }catch(exception ex){
            errorMessage= ex.getMessage();
        }finally{
            System.assertEquals(null,errorMessage);
        }      
        
    }
    @istest
    private static void testInsertingRecordsWithNumberOfRecordsThatExceedsLimitByOne(){
        ImmobilienDMSDatei__c dmsDatei =TestDataFactory.createImmobilienDMSDatei(true);
        Contact con=TestDataFactory.createContact(true);
        
        string errorMessage=null;
        List<FileDownloadLog__c> logs =new List<FileDownloadLog__c>();
        for(integer i=0;i<FileDownloadLogTriggerHandler.FILE_DOWNLOAD_LOG_RECORDS_LIMIT_TEST;i++){           
            FileDownloadLog__c fdl =TestDataFactory.createFileDownloadLog(false,con.id,dmsDatei.id);
            logs.add(fdl);
        }
        insert logs;
        try{              
            FileDownloadLog__c fdl =TestDataFactory.createFileDownloadLog(true,con.id,dmsDatei.id);
        }catch(exception ex){
            errorMessage= ex.getMessage();
        }finally{
            System.assert(errorMessage.contains(FileDownloadLogTriggerHandler.LIMIT_ERROR_MESSAGE));
        }      

    }
}