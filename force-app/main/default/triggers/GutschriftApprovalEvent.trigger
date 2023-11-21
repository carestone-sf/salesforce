trigger GutschriftApprovalEvent on GutschriftApproval__e (after insert) {
    List<Provision__c> provsToUpdate = new List<Provision__c>();
    Map<Id, Provision__c> provs = new Map<Id,Provision__c>([SELECT Id, GutschriftBestaetigt__c, GutschriftAbgelehnt__c FROM Provision__c WHERE Genehmigung__c = true AND GutschriftBestaetigt__c = false AND GutschriftAbgelehnt__c = false]);

    for (GutschriftApproval__e event : Trigger.New) {
        if(event.ProvisionId__c != null && (event.Approved__c == true || event.Rejected__c == true)) {
            Provision__c prov = provs.get(event.ProvisionId__c);
            if (event.Approved__c == true) {
                prov.GutschriftBestaetigt__c = true;
            }
            else {
                prov.GutschriftAbgelehnt__c = true;
            }
            provsToUpdate.add(prov);
        }
    }
    update provsToUpdate;
}