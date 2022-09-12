public with sharing class AggregateRatePaymentDataQueueable implements Queueable {

    Set<Id> rateIds = new Set<Id>();
    Set<Id> opportunityIds = new Set<Id>();

    public AggregateRatePaymentDataQueueable(Set<Id> rateIds, Set<Id> opportunityIds) {
        this.rateIds = rateIds;
        this.opportunityIds = opportunityIds;
    }

    public void execute(QueueableContext ctx) {
        Map<Id,MaBVRate__c> mabvRateByIds = new Map<Id,MaBVRate__c>();
        Map<Id,Opportunity> opportunitiesByIds = new Map<Id,Opportunity>();

        for(AggregateResult agRes : [SELECT COUNT(Id) num, MaBVRechnungMaster__r.MaBVRate__c rate, IstBezahlt__c istBezahlt FROM MaBVRechnung__c WHERE MaBVRechnungMaster__r.MaBVRate__c IN :this.rateIds AND Storniert__c = false GROUP BY MaBVRechnungMaster__r.MaBVRate__c, IstBezahlt__c]) {
            Id rateId = (Id) agRes.get('rate');
            Integer count = (Integer) agRes.get('num');
            Boolean istBezahlt = (Boolean) agRes.get('istBezahlt');

            String field = istBezahlt ? 'GezahlteRechnungen__c' : 'OffeneRechnungen__c';

            MaBVRate__c rate = mabvRateByIds.containsKey(rateId) ? mabvRateByIds.get(rateId) : new MaBVRate__c(Id = rateId);
            rate.put(field, count);
            mabvRateByIds.put(rateId, rate);             
        }

        for(AggregateResult agRes : [SELECT SUM(RateGesamtInEuro__c) total, SUM(Bezahlt__c) bezahlt, SUM(OffenerBetragNeu__c) offen, MaBVRechnungMaster__r.MaBVRate__c rate, IstBezahlt__c istBezahlt FROM MaBVRechnung__c WHERE MaBVRechnungMaster__r.MaBVRate__c IN :this.rateIds AND Storniert__c = false GROUP BY MaBVRechnungMaster__r.MaBVRate__c, IstBezahlt__c]) {
            Id rateId = (Id) agRes.get('rate');
            Double total = (Double) agRes.get('total');
            Double bezahlt = (Double) agRes.get('bezahlt');
            Double offen = (Double) agRes.get('offen');
            Boolean istBezahlt = (Boolean) agRes.get('istBezahlt');


            MaBVRate__c rate = mabvRateByIds.containsKey(rateId) ? mabvRateByIds.get(rateId) : new MaBVRate__c(Id = rateId);
            rate.SummeGezahlterRechnungen__c = rate.SummeGezahlterRechnungen__c != null ? rate.SummeGezahlterRechnungen__c += bezahlt : bezahlt;
            rate.SummeOffenerRechnungen__c = rate.SummeOffenerRechnungen__c != null ? rate.SummeOffenerRechnungen__c += offen : offen;
            
            mabvRateByIds.put(rateId, rate);        
        }

        for(AggregateResult agRes : [SELECT SUM(RateGesamtInEuro__c) total, SUM(Bezahlt__c) bezahlt, SUM(OffenerBetragNeu__c) offen, MaBVRechnungMaster__r.Opportunity__c opp, IstBezahlt__c istBezahlt FROM MaBVRechnung__c WHERE MaBVRechnungMaster__r.Opportunity__c IN :this.opportunityIds AND Storniert__c = false GROUP BY MaBVRechnungMaster__r.Opportunity__c, IstBezahlt__c]) {
            Id opportunityId = (Id) agRes.get('opp');
            Double total = (Double) agRes.get('total');
            Double bezahlt = (Double) agRes.get('bezahlt');
            Double offen = (Double) agRes.get('offen');
            Boolean istBezahlt = (Boolean) agRes.get('istBezahlt');
            
            Opportunity opportunity = opportunitiesByIds.containsKey(opportunityId) ? opportunitiesByIds.get(opportunityId) : new Opportunity(Id = opportunityId);
            opportunity.AbgerechneterBetragMaBV__c = opportunity.AbgerechneterBetragMaBV__c != null ? opportunity.AbgerechneterBetragMaBV__c += total : total;
            opportunity.OffenerBetragMaBV__c = opportunity.OffenerBetragMaBV__c != null ? opportunity.OffenerBetragMaBV__c += offen : offen;
            opportunitiesByIds.put(opportunityId, opportunity);
        }

        update opportunitiesByIds.values();

        update mabvRateByIds.values();
    }
}
