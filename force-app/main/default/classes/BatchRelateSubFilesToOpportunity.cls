public with sharing class BatchRelateSubFilesToOpportunity implements Database.Batchable<SObject> {
    
    public static final Set<String> relevantObjects = new Set<String> {
        'Gutschrift__c', 'MaBVRechnung__c'
    };


    public Database.QueryLocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator([SELECT Id FROM ContentDocument]);
    }

    public void execute(Database.BatchableContext bc, List<SObject> scope) {

        Set<Id> contentDocumentIds = new Set<Id>();
        for(ContentDocument cd : (List<ContentDocument>) scope) {
            contentDocumentIds.add(cd.Id);
        }

        Set<Id> gutschriftIds = new Set<Id>();
        Set<Id> mabvRechnungenIds = new Set<Id>();
        Map<Id,Id> mapContentDocumentIdsByLinkedEntityIds = new Map<Id,Id>();
        for(ContentDocumentLink cdl : [SELECT Id, LinkedEntityId, ContentDocumentId FROM ContentDocumentLink WHERE ContentDocumentId IN :contentDocumentIds]) {
            if(relevantObjects.contains(cdl.LinkedEntityId.getSObjectType().getDescribe().getName())) {
                mapContentDocumentIdsByLinkedEntityIds.put(cdl.LinkedEntityId, cdl.ContentDocumentId);

                if(cdl.LinkedEntityId.getSObjectType() == Gutschrift__c.getSObjectType()) {
                    gutschriftIds.add(cdl.LinkedEntityId);
                } else if (cdl.LinkedEntityId.getSObjectType() == MaBVRechnung__c.getSObjectType()) {
                    mabvRechnungenIds.add(cdl.LinkedEntityId);
                }
            }
        }

        List<ContentDocumentLink> oppLinks = new List<ContentDocumentLink>();
        if(!gutschriftIds.isEmpty()) {
            List<Gutschrift__c> linkedEntities = [SELECT Id, Opportunity__c FROM Gutschrift__c WHERE Id IN :gutschriftIds];
            for(Gutschrift__c li : linkedEntities) {
                oppLinks.add(new ContentDocumentLink(
                    LinkedEntityId = li.Opportunity__c,
                    ContentDocumentId = mapContentDocumentIdsByLinkedEntityIds.get(li.Id),
                    ShareType = 'V'
                ));
            }
        } 
        if(!mabvRechnungenIds.isEmpty()) {
            List<MaBVRechnung__c> linkedEntities = [SELECT Id, MaBVRechnungMaster__r.Opportunity__c FROM MaBVRechnung__c WHERE Id IN :maBVRechnungenIds];
            for(MaBVRechnung__c li : linkedEntities) {
                oppLinks.add(new ContentDocumentLink(
                    LinkedEntityId = li.MaBVRechnungMaster__r.Opportunity__c,
                    ContentDocumentId = mapContentDocumentIdsByLinkedEntityIds.get(li.Id),
                    ShareType = 'V'
                ));
            }
        }

        Database.insert(oppLinks, false);
    }

    public void finish(Database.BatchableContext bc) {

    }
}
