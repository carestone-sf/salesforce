/**
 * Created by frederikwitte on 19.04.20.
 */

trigger Provisionsverhandlung on Provisionsverhandlung__c (after insert, after update) {
    if(Trigger.isUpdate || Trigger.isInsert) {
        List<Id> maklerAccountIds = new List<Id>();
        for(Provisionsverhandlung__c provisionsverhandlung:Trigger.new) {
            Provisionsverhandlung__c oldProvisionsverhandlung;
            if(Trigger.isUpdate) {
                oldProvisionsverhandlung = Trigger.oldMap.get(provisionsverhandlung.Id);
            }
            if(Trigger.isInsert
                    || (oldProvisionsverhandlung != null && provisionsverhandlung.Verkaufsprovision__c != oldProvisionsverhandlung.Verkaufsprovision__c)
                    || (oldProvisionsverhandlung != null && provisionsverhandlung.Grundprovision__c != oldProvisionsverhandlung.Grundprovision__c)) {
                maklerAccountIds.add(provisionsverhandlung.Account__c);
            }
        }
        List<Opportunity> opps = [SELECT Abrechnung_ber__c, Makler__c,Immobilienberater__c, AccountIdAbrechnungUeber__c, Grundprovision_Provisionsverhandlung__c, Verkaufsprovision_Provisionsverhandlung__c, Immobilie__c, AccountId, AccountIdImmobilienberater__c
                                    FROM Opportunity
                                    WHERE (AccountId IN :maklerAccountIds OR AccountIdImmobilienberater__c IN :maklerAccountIds OR AccountIdAbrechnungUeber__c IN :maklerAccountIds)
                                        AND StageName != 'Geschlossene und gewonnene'
                                        AND StageName != 'Geschlossen und verloren'
                                        AND StageName != 'VKC ausgelaufen'
                                        AND StageName != 'Reservierung abgelehnt'];
        Map<Id, Opportunity> updateOpps = new Map<Id, Opportunity>();
        for(Opportunity opp:opps) {
            for(Provisionsverhandlung__c provisionsverhandlung:Trigger.new) {
                if(opp.Abrechnung_ber__c != null && opp.AccountIdAbrechnungUeber__c == provisionsverhandlung.Account__c && opp.Immobilie__c == provisionsverhandlung.Immobilie__c) {
                    opp.Grundprovision_Provisionsverhandlung__c = provisionsverhandlung.Grundprovision__c;
                    updateOpps.put(opp.Id, opp);
                } else if(opp.AccountId == provisionsverhandlung.Account__c && opp.Immobilie__c == provisionsverhandlung.Immobilie__c) {
                    opp.Grundprovision_Provisionsverhandlung__c = provisionsverhandlung.Grundprovision__c;
                    updateOpps.put(opp.Id, opp);
                }
                if(opp.Abrechnung_ber__c != null && opp.Makler__c == opp.Immobilienberater__c && opp.AccountIdAbrechnungUeber__c == provisionsverhandlung.Account__c && opp.Immobilie__c == provisionsverhandlung.Immobilie__c) {
                    opp.Verkaufsprovision_Provisionsverhandlung__c = provisionsverhandlung.Verkaufsprovision__c;
                    updateOpps.put(opp.Id, opp);
                } else if(opp.AccountIdImmobilienberater__c == provisionsverhandlung.Account__c && opp.Immobilie__c == provisionsverhandlung.Immobilie__c) {
                    opp.Verkaufsprovision_Provisionsverhandlung__c = provisionsverhandlung.Verkaufsprovision__c;
                    updateOpps.put(opp.Id, opp);
                }
            }
        }
        update updateOpps.values();
    }

}