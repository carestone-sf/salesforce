

Map<Id,Id> mapContentDocumentIdsByLinkedEntityIds = new Map<Id,Id>();

for(ContentDocumentLink cdl : [SELECT Id, ContentDocumentId, LinkedEntityId FROM ContentDocumentLink WHERE LinkedEntityId IN (SELECT Id FROM MaBVRechnung__c WHERE Util_FilesMigratedToOpportunity__c = false) LIMIT 1000]) {
    mapContentDocumentIdsByLinkedEntityIds.put(cdl.LinkedEntityId, cdl.ContentDocumentId);
}

List<ContentDocumentLink> oppLinks = new List<ContentDocumentLink>();
List<MaBVRechnung__c> linkedEntities = [SELECT Id, MaBVRechnungMaster__r.Opportunity__c FROM MaBVRechnung__c WHERE Id IN :mapContentDocumentIdsByLinkedEntityIds.keySet()];
for(MaBVRechnung__c li : linkedEntities) {
    oppLinks.add(new ContentDocumentLink(
        LinkedEntityId = li.MaBVRechnungMaster__r.Opportunity__c,
        ContentDocumentId = mapContentDocumentIdsByLinkedEntityIds.get(li.Id),
        ShareType = 'V'
    ));

    li.Util_FilesMigratedToOpportunity__c = true;
}

Database.update(linkedEntities, false):
Database.insert(oppLinks, false);

/**
 * 
 */



Map<Id,Id> mapContentDocumentIdsByLinkedEntityIds = new Map<Id,Id>();

for(ContentDocumentLink cdl : [SELECT Id, ContentDocumentId, LinkedEntityId FROM ContentDocumentLink WHERE LinkedEntityId IN (SELECT Id FROM Gutschrift__c WHERE Util_FilesMigratedToOpportunity__c = false) LIMIT 1000]) {
    mapContentDocumentIdsByLinkedEntityIds.put(cdl.LinkedEntityId, cdl.ContentDocumentId);
}

List<ContentDocumentLink> oppLinks = new List<ContentDocumentLink>();
List<Gutschrift__c> linkedEntities = [SELECT Id, Opportunity__c FROM Gutschrift__c WHERE Id IN :mapContentDocumentIdsByLinkedEntityIds.keySet()];
for(Gutschrift__c li : linkedEntities) {
    oppLinks.add(new ContentDocumentLink(
        LinkedEntityId = li.Opportunity__c,
        ContentDocumentId = mapContentDocumentIdsByLinkedEntityIds.get(li.Id),
        ShareType = 'V'
    ));

    li.Util_FilesMigratedToOpportunity__c = true;
}

Database.update(linkedEntities, false):
Database.insert(oppLinks, false);