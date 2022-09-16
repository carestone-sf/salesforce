public without sharing class AggregateVkcZahlungPaymentDataQueueable implements Queueable {
    
    Set<Id> opportunityIds = new Set<Id>();

    public AggregateVkcZahlungPaymentDataQueueable(Set<Id> opportunityIds) {
        this.opportunityIds = opportunityIds;
    }

    public void execute(QueueableContext ctx) {

        Map<Id,Property__c> mapImmobilienByIds = new Map<Id,Property__c>([SELECT Id FROM Property__c WHERE Id IN (SELECT Immobilie__c FROM Opportunity WHERE Id IN :this.opportunityIds)]);
        Map<Id,Appartment__c> mapTeilobjekteByIds = new Map<Id,Appartment__c>([SELECT Id FROM Appartment__c WHERE Id IN (SELECT Appartement__c FROM Opportunity WHERE Id IN :this.opportunityIds)]);

        List<Property__c> immobilien = new List<Property__c>();
        for(AggregateResult agRes : [SELECT SUM(OffenerBetrag__c) offen, SUM(AbgerechneterBetrag__c) abgerechnet, Immobilie__c immoId FROM Opportunity WHERE Immobilie__c IN :mapImmobilienByIds.keySet() AND Datum_Kaufpreisf_lligkeitsschreiben__c <= TODAY AND (HatVKCZahlungen__c = true OR Immobilie__r.Kaufpreiszahlung__c = 'Endfällig') GROUP BY Immobilie__c]) {
            Id immoId = (Id) agRes.get('immoId');
            Double offen = (Double) agRes.get('offen');
            Double abgerechnet = (Double) agRes.get('abgerechnet');

            Property__c immo = new Property__c(Id = immoId);
            immo.OffenerBetragEinmalzahlungen__c = offen;
            immo.AbgerechneteEinmalzahlungen__c = abgerechnet;
            immobilien.add(immo);
        }
        update immobilien;

        List<Appartment__c> teilobjekte = new List<Appartment__c>();
        for(AggregateResult agRes : [SELECT SUM(Bezahlt__c) bezahlt, Appartement__c teilobjektId FROM Opportunity WHERE Appartement__c IN :mapTeilobjekteByIds.keySet() AND HatVKCZahlungen__c = true GROUP BY Appartement__c]) {
            Id teilobjektId = (Id) agRes.get('teilobjektId');
            Double bezahlt = (Double) agRes.get('bezahlt');

            Appartment__c teilobjekt = new Appartment__c(Id = teilobjektId);
            teilobjekt.Bezahlt__c = bezahlt;
            teilobjekte.add(teilobjekt);
        }
        update teilobjekte;

    }
}
