trigger Finanzierungsanfrage on Finanzierungsanfrage__c (before update) {
    if(Trigger.isBefore) {
        if(Trigger.isUpdate) {

        }
    }
}