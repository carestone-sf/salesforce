public without sharing class OpportunityController {
    @AuraEnabled(cacheable=true)
    public static MaBVOverview getMabvInvoices(Id oppId) {
        MaBVOverview mo = new MaBVOverview();
        mo.mabvInvoices = [SELECT Id, OffenerBetragNeu__c, (SELECT Id, Betrag__c, Zahldatum__c FROM ZahlungenMaBVRechnungen__r), MaBVRechnungMaster__r.Opportunity__r.Beurkundeter_Kaufpreis__c, MaBVRechnungMaster__r.MaBVRate__r.Name, RateGesamtInEuro__c, Rechnungsdatum__c, Name, ZahlungszielInTagen__c, Leistung__c FROM MaBVRechnung__c WHERE MaBVRechnungMaster__r.Opportunity__c = :oppId AND Storniert__c = false ORDER BY RateNummer__c ASC];
        mo.opp = [SELECT Id, beurkundeter_Kaufpreis__c FROM Opportunity WHERE Id = :oppId];

        return mo;
    }

    public class MaBVOverview {
        @AuraEnabled
        public Opportunity opp{get;set;}

        @AuraEnabled
        public List<MaBVRechnung__c> mabvInvoices{get;set;}

        public MaBVOverview() {
            this.mabvInvoices = new List<MaBVRechnung__c>();
        }
    }
}