@isTest
public with sharing class CreateAndSavePdfTest {

    @TestVisible private static Boolean isSuccess;

        @testSetup
        static void makeData() {
                     
            DigitaleVsa__c digitaleVsa = TestDataFactory.createDigitaleVsa(true);
            DigitaleVsa__c recordId = [SELECT Id FROM DigitaleVsa__c LIMIT 1];           
            ContentVersion file = new ContentVersion();
            Blob b=Blob.valueOf('Unit Test Attachment Body');           
            file.VersionData =  EncodingUtil.base64Decode('Unit Test Attachment Body');
            file.Title = 'Test File';
            file.PathOnClient = recordId + 'pdf';
            file.Typ__c = 'Individuelle Unterlage'; 
            try{
                insert file; 
                isSuccess=true;
    
            }catch(DMLexception e){
                System.debug('Exception' + e.getMessage());
            }
            System.debug('isSuccess');
            System.debug(isSuccess);
        }

        @isTest
        private static void testPdfCreate() {          

            List<ContentVersion> listOfContentVersions = [SELECT Id, contentDocumentId, Title FROM ContentVersion WHERE Title= :'Test File' LIMIT 1];
            
            if(listOfContentVersions.isEmpty() ){
                isSuccess = false;
                
            } else {
                isSuccess = true;
                
            }

            System.debug('isSuccess INSIDE TEST ');
            System.debug(isSuccess);

            Test.startTest();
            System.assertEquals(listOfContentVersions.size(),1);
            System.assertEquals(isSuccess, true, 'isSuccess is false');
            Test.stopTest();
          
        }

    
}
