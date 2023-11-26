public with sharing class BatchAggregateImmos implements Database.Batchable<SObject>, Schedulable {
    
    public Database.QueryLocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator([SELECT Id FROM Property__c WHERE Id IN (SELECT Property__c FROM Appartment__c)]);
    }

    public void execute(Database.BatchableContext bc, List<Property__c> scope) {
        for(Property__c property:scope) {
            BatchAggregateImmos.updateImmos(property.Id);
        }
    }

    public static void updateImmos(Id propertyId) {
        Map<Id, Property__c> properties = new Map<Id, Property__c>();

        for(AggregateResult agRes : [SELECT SUM(MaklerprovisionNetto__c) maklerprovisionNetto, SUM(MarketingzuschussNetto__c) marketingzuschussNetto, SUM(AdditionalBrokerCommission__c) incentivierungMaklerNetto, SUM(Additional_Costs__c) incentivierungKunde,  Property__c propertyId FROM Appartment__c WHERE Status__c = 'Sold' AND Property__c = :propertyId GROUP BY Property__c]) {
            Property__c property = properties.get(propertyId);

            if(property == null) {
                property = new Property__c(Id = propertyId);
            }
            property.MarketingzuschussNetto__c = (Decimal)agRes.get('marketingzuschussNetto');
            property.MaklerprovisionNetto__c = (Decimal)agRes.get('maklerprovisionNetto');
            property.IncentivierungMaklerNetto__c = (Decimal) agRes.get('incentivierungMaklerNetto');
            property.IncentivierungKundeIst__c = (Decimal) agRes.get('incentivierungKunde');
            properties.put(propertyId, property);
        }

        for(AggregateResult agRes : [SELECT SUM(Monthly_Rent__c) monatsMiete, SUM(Jahresmiete__c) jahresMiete, SUM(KaufpreisIst__c) kaufpreisIst, SUM(Purchase_Price__c) kaufpreisPlan, Property__c propertyId FROM Appartment__c WHERE Property__c = :propertyId GROUP BY Property__c]) {
            Property__c property = properties.get(propertyId);

            if(property == null) {
                property = new Property__c(Id = propertyId);
            }
            property.MonatsmieteBeiVerkauf__c = (Decimal) agRes.get('monatsMiete');
            property.VerkaufsvolumenIst__c = (Decimal) agRes.get('kaufpreisIst');
            property.Property_Price__c = (Decimal) agRes.get('kaufpreisPlan');
            properties.put(propertyId, property);
        }

        for(AggregateResult agRes : [SELECT SUM(Wert_Maklerprovision__c) maklerprovisionNetto, SUM(WertMarketingzuschuss__c) marketingzuschussNetto, Provision__r.Objekt__c propertyId FROM Gutschrift__c WHERE GutschriftStorniert__c = false AND Bezahlt__c = true AND Provision__r.Objekt__c = :propertyId GROUP BY Provision__r.Objekt__c]) {
            Property__c property = properties.get(propertyId);

            if(property == null) {
                property = new Property__c(Id = propertyId);
            }
            property.MarketingzuschussGezahltBrutto__c = ((Decimal)agRes.get('marketingzuschussNetto'))*1.19;
            property.MaklerprovisionGezahltBrutto__c = ((Decimal)agRes.get('maklerprovisionNetto'))*1.19;
            properties.put(propertyId, property);
        }

        update properties.values();
    }

    public void finish(Database.BatchableContext bc) {

    }
    
    public void execute(System.SchedulableContext ctx) {
        Database.executeBatch(new BatchAggregateImmos(), 1);
    }
}