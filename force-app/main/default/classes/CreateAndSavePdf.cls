public with sharing class CreateAndSavePdf {

    @AuraEnabled
    public static Boolean getPDFprint(Id recordId){

        Boolean isSuccess= false;
        String digitaleVsaUserName = [SELECT Name FROM DigitaleVsa__c WHERE Id = :recordId].Name;
        String digitaleVsaFileName = String.valueOf(digitaleVsaUserName + '.pdf');

        
        List<ContentVersion> resultsContentVersions = [SELECT Id, contentDocumentId, Title FROM ContentVersion WHERE Title= :digitaleVsaFileName LIMIT 1];

        ContentVersion file = new ContentVersion();

        if(resultsContentVersions.isEmpty()){
            PageReference pdfPage = new PageReference('/apex/Digitale_VSA_PDF');
            pdfPage.getParameters().put('id', recordId);
            Blob pdfPageBlob;
            try{
                pdfPageBlob = pdfPage.getContentAsPDF();
            }catch(Exception error){
                System.debug(error.getMessage());
            }

            file = new ContentVersion();
            file.Title = digitaleVsaFileName;
            file.PathOnClient = recordId + '.pdf';
            file.VersionData = pdfPageBlob;            
            file.FirstPublishLocationId = recordId;
            file.Typ__c = 'Individuelle Unterlage'; 
        } else {  
            Id contentDocumentId = [SELECT ContentDocumentId FROM ContentVersion WHERE Id = :resultsContentVersions.get(0).Id].ContentDocumentId;
            file = new ContentVersion();
            file.PathOnClient = recordId + '.pdf';
            PageReference pdfPage = new PageReference('/apex/Digitale_VSA_PDF');
            pdfPage.getParameters().put('id', recordId);
            Blob pdfPageBlob;
            try{
                pdfPageBlob = pdfPage.getContentAsPDF();
               
            }catch(Exception error){
                System.debug('error blub');
            }
            file.VersionData = pdfPageBlob; 
            file.contentDocumentId = contentDocumentId;
            
        }
        try{
            insert file; 
            isSuccess=true;

        }catch(DMLexception e){
            System.debug('Exception' + e.getMessage());
        }
  
        return isSuccess;
    }
}
