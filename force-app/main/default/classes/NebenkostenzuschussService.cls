public without sharing class NebenkostenzuschussService {

    public class NebenkostenzuschussException extends Exception {}

    public static Nebenkostenzuschuss__c createFromOpportunity(Id opportunityId) {
        List<Nebenkostenzuschuss__c> results = createFromOpportunities(new List<Id>{ opportunityId });
        return results.isEmpty() ? null : results[0];
    }

    public static List<Nebenkostenzuschuss__c> createFromOpportunities(List<Id> opportunityIds) {
        if (opportunityIds == null || opportunityIds.isEmpty()) {
            return new List<Nebenkostenzuschuss__c>();
        }

        Set<Id> uniqueIds = new Set<Id>(opportunityIds);
        uniqueIds.remove(null);

        if (uniqueIds.isEmpty()) {
            return new List<Nebenkostenzuschuss__c>();
        }

        Map<Id, Opportunity> opportunities = new Map<Id, Opportunity>([
            SELECT Id, Immobilie__c, Appartement__c, Potenzieller_Kunde__c, Makler__c
            FROM Opportunity
            WHERE Id IN :uniqueIds
        ]);

        Set<Id> existingOppIds = new Set<Id>();
        for (Nebenkostenzuschuss__c existing : [
            SELECT Opportunity__c
            FROM Nebenkostenzuschuss__c
            WHERE Opportunity__c IN :uniqueIds
              AND Storniert__c = false
        ]) {
            existingOppIds.add(existing.Opportunity__c);
        }

        List<Nebenkostenzuschuss__c> toInsert = new List<Nebenkostenzuschuss__c>();

        for (Id oppId : uniqueIds) {
            Opportunity opp = opportunities.get(oppId);
            if (opp == null) {
                throw new NebenkostenzuschussException(
                    'Opportunity nicht gefunden: ' + oppId
                );
            }

            if (existingOppIds.contains(oppId)) {
                throw new NebenkostenzuschussException(
                    'Es existiert bereits ein aktiver Nebenkostenzuschuss fuer diese Opportunity: ' + oppId
                );
            }

            if (opp.Appartement__c == null) {
                throw new NebenkostenzuschussException(
                    'Opportunity hat kein Teilobjekt (Appartement): ' + oppId
                );
            }

            Nebenkostenzuschuss__c nkz = new Nebenkostenzuschuss__c();
            nkz.Opportunity__c = opp.Id;
            nkz.Objekt__c = opp.Immobilie__c;
            nkz.Teilobjekt__c = opp.Appartement__c;
            nkz.Kunde__c = opp.Potenzieller_Kunde__c;
            nkz.Empfaenger__c = opp.Makler__c;
            toInsert.add(nkz);
        }

        if (!toInsert.isEmpty()) {
            insert toInsert;
        }

        return toInsert;
    }
}
