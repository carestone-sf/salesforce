public with sharing class ContentVersionTriggerHandler implements ITrigger {
    
    public static Id finanzierungsanfragenRecordTypeId = Schema.getGlobalDescribe().get('ContentVersion').getDescribe().getRecordTypeInfosByName().get('Finanzierungsanfragen').getRecordTypeId();

    public void bulkBefore() {

    }

    public void bulkAfter() {
        
    }

    public void beforeInsert(SObject so) {
        ContentVersion cv = (ContentVersion) so;

        if(cv.RecordTypeId == finanzierungsanfragenRecordTypeId) {
            setTitleToType(cv);
        }
    }

    public void beforeUpdate(SObject oldSo, SObject so) {
        
    }

    public void beforeDelete(SObject so) {

    }

    public void afterInsert(SObject so) {
        
    }

    public void afterUpdate(SObject oldSo, SObject so) {
        
    }

    public void afterDelete(SObject so) {

    }

    /**
     * This method sets the file title to the file type, if not explicitly individual
     * 
     * @param cv ContentVersion record
     */
    public void setTitleToType(ContentVersion cv) {
        if(cv.Typ__c != null && cv.Typ__c != 'Individuelle Unterlage') {
            String title = cv.Typ__c;
            if(title.length() > 255) {
                title = title.substring(0,255);
            }
            cv.Title = title;
        }
    }

    public void andFinally() {
        
    }
}