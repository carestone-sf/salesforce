public without sharing class ContentDocumentLinkTriggerHandler implements ITrigger {

    public List<SObject> insertList = new List<SObject>();
    public List<SObject> updateList = new List<SObject>();

    Map<Id, Gutschrift__c> mapGutschriftenByIds;
    Map<Id, MaBVRechnung__c> mapMaBVRechnungenByIds;

    public void bulkBefore() {

    }
    
    public void bulkAfter() {
        if(Trigger.isInsert) {
            createMapsForOpportunityFileLinking();
        }
    }

    public void beforeInsert(SObject so) {
        
    }

    public void beforeUpdate(SObject oldSo, SObject so) {
        
    }

    public void beforeDelete(SObject so) {

    }

    public void afterInsert(SObject so) {
        ContentDocumentLink cdl = (ContentDocumentLink) so;

        attachOpportunityRelevantFilesToOpportunity(cdl);
    }

    public void afterUpdate(SObject oldSo, SObject so) {
        
    }

    public void afterDelete(SObject so) {

    }


    public void andFinally() {
        // TODO: Check what happens if file is already linked to the opportunity
        insertList.sort();
        Database.insert(insertList, true);

        updateList.sort();
        Database.update(updateList, true);
    }

    /** FEATURE: Gutschrift and MaBV related files should also be related to the parent opportunity  */

    /**
     * Caches data and creates maps required to access the related opportunities
     */
    public void createMapsForOpportunityFileLinking() {
        Set<Id> mabvIds = new Set<Id>();
        Set<Id> gutschriftIds = new Set<Id>();
        for(ContentDocumentLink cdl : (List<ContentDocumentLink>) Trigger.new) {
            SObjectType soType = cdl.LinkedEntityId.getSObjectType();
            
            if(soType == MaBVRechnung__c.getSObjectType()) {
                mabvIds.add(cdl.LinkedEntityId);
            } else if (soType == Gutschrift__c.getSObjectType()) {
                gutschriftIds.add(cdl.LinkedEntityId);
            }
        }
            
        if(!gutschriftIds.isEmpty()) {
            mapGutschriftenByIds = new Map<Id, Gutschrift__c> ([SELECT Id, Opportunity__c FROM Gutschrift__c WHERE Id IN :gutschriftIds]);
        }
        if(!mabvIds.isEmpty()) {
            mapMaBVRechnungenByIds = new Map<Id, MaBVRechnung__c> ([SELECT Id, MaBVRechnungMaster__r.Opportunity__c FROM MaBVRechnung__c WHERE Id IN :mabvIds]);
        }
    }

    /**
     * This method checks if the file has been published to an Opportunity related object and if so, creates a CDL to the Opportunity record.   
     * 
     * @param cv ContentVersion record
     */
    public void attachOpportunityRelevantFilesToOpportunity(ContentDocumentLink cdl) {
        SObjectType soType = cdl.LinkedEntityId.getSObjectType();

        Id opportunityId;
        if(soType == MaBVRechnung__c.getSObjectType()) {
            opportunityId = mapMaBVRechnungenByIds.get(cdl.LinkedEntityId).MaBVRechnungMaster__r.Opportunity__c;
        } else if (soType == Gutschrift__c.getSObjectType()) {
            opportunityId = mapGutschriftenByIds.get(cdl.LinkedEntityId).Opportunity__c;
        }

        if(opportunityId != null) {
            insertList.add(new ContentDocumentLink(
                ContentDocumentId = cdl.ContentDocumentId,
                LinkedEntityId = opportunityId,
                ShareType = 'V',
                Visibility = 'AllUsers'
            ));
        }
    }
}