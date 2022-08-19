trigger ContentVersion on ContentVersion (before insert) {
    Id finanzierungsanfragenRecordTypeId = Schema.getGlobalDescribe().get('ContentVersion').getDescribe().getRecordTypeInfosByName().get('Finanzierungsanfragen').getRecordTypeId();
    if(Trigger.isInsert && Trigger.isBefore) {

        for(ContentVersion cv:Trigger.new) {
            if(cv.Typ__c != null && cv.Typ__c != 'Individuelle Unterlage' && cv.RecordTypeId == finanzierungsanfragenRecordTypeId) {
                String title = cv.Typ__c;
                if(title.length() > 255) {
                    title = title.substring(0,255);
                }
                cv.Title = title;
            }
        }
    }
}