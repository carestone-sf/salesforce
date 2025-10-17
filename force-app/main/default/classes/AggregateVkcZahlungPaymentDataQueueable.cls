public without sharing class AggregateVkcZahlungPaymentDataQueueable implements Queueable {
    
    Set<Id> opportunityIds = new Set<Id>();

    public AggregateVkcZahlungPaymentDataQueueable(Set<Id> opportunityIds) {
        this.opportunityIds = opportunityIds;
    }

    public void execute(QueueableContext ctx) {
        Map<Id,Property__c> mapImmobilienByIds = new Map<Id,Property__c>([SELECT Id FROM Property__c WHERE Id IN (SELECT Immobilie__c FROM Opportunity WHERE Id IN :this.opportunityIds)]);
        Map<Id,Appartment__c> mapTeilobjekteByIds = new Map<Id,Appartment__c>([SELECT Id FROM Appartment__c WHERE Id IN (SELECT Appartement__c FROM Opportunity WHERE Id IN :this.opportunityIds)]);

        updateImmobilien(mapImmobilienByIds.keySet());
        updateImmobilien2(mapImmobilienByIds.keySet());

        List<Appartment__c> teilobjekte = new List<Appartment__c>();
        for(AggregateResult agRes : [SELECT SUM(Bezahlt__c) bezahlt, Appartement__c teilobjektId FROM Opportunity WHERE Appartement__c IN :mapTeilobjekteByIds.keySet() AND HatVKCZahlungen__c = true AND (IsWon = true OR StageName = 'Notartermin hat stattgefunden') GROUP BY Appartement__c]) {
            Id teilobjektId = (Id) agRes.get('teilobjektId');
            Double bezahlt = (Double) agRes.get('bezahlt');

            Appartment__c teilobjekt = new Appartment__c(Id = teilobjektId);
            teilobjekt.Bezahlt__c = bezahlt;
            teilobjekte.add(teilobjekt);
        }
        update teilobjekte;
    }

    public static void updateImmobilien(Set<Id> immoIds) {
        List<Property__c> immobilien = new List<Property__c>();
        for(AggregateResult agRes : [SELECT SUM(OffenerBetrag__c) offen, SUM(AbgerechneterBetrag__c) abgerechnet, Immobilie__c immoId FROM Opportunity WHERE Immobilie__c IN :immoIds AND (Datum_Kaufpreisf_lligkeitsschreiben__c <= TODAY OR Kaufpreis_bezahlt__c = true) AND (HatVKCZahlungen__c = true OR Immobilie__r.Kaufpreiszahlung__c = 'Endfällig') AND (IsWon = true OR StageName = 'Notartermin hat stattgefunden') GROUP BY Immobilie__c]) {
            Id immoId = (Id) agRes.get('immoId');
            Double offen = (Double) agRes.get('offen');
            Double abgerechnet = (Double) agRes.get('abgerechnet');

            Property__c immo = new Property__c(Id = immoId);
            immo.OffenerBetragEinmalzahlungen__c = offen;
            immo.AbgerechneteEinmalzahlungen__c = abgerechnet;
            immobilien.add(immo);
        }
        update immobilien;
    }

    public static void updateImmobilien2(Set<Id> immoIds) {
        List<Property__c> immobilien = new List<Property__c>();
        for(AggregateResult agRes : [SELECT Immobilie__c immoId, SUM(IncentivierungGesamt__c) incentivierungGesamt FROM Opportunity WHERE incentivierunggesamt__c != 0 AND (IsWon = true OR StageName = 'Notartermin hat stattgefunden') GROUP BY Immobilie__c]) {
            Id immoId = (Id) agRes.get('immoId');
            Double incentivierungGesamt = (Double) agRes.get('incentivierungGesamt');

            Property__c immo = new Property__c(Id = immoId);
            immo.IncentivierungIST__c = incentivierungGesamt;
            immobilien.add(immo);
        }
        update immobilien;
    }
}