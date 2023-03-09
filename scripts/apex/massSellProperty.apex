Id propertyId = 'a0L6700000QQYTDEA5';
Id customerId = '0036700003ilAhzAAE';
Id accountId = '001b000000f8WOVAA2';
Id pawilsId = '003b0000002oyrDAAQ';


List<Appartment__c> apps = [SELECT Id, Purchase_Price__c FROM Appartment__c WHERE Status__c = 'Available' AND Property__c = :propertyId AND Id NOT IN (SELECT Appartement__c FROM Opportunity) LIMIT 30];

List<Opportunity> opps = new List<Opportunity>();
for(Appartment__c app : apps) {
    opps.add(new Opportunity(
        StageName = 'Geschlossene und gewonnene',
        CloseDate = Date.today().addMonths(1),
        Appartement__c = app.Id,
        Potenzieller_Kunde__c = customerId,
        AccountId = accountId,
        Makler__c = pawilsId,
        Immobilienberater__c = pawilsId,
        Maklerbetreuer_WirtschaftsHaus__c = pawilsId,
        KfwWunsch__c = 'Bestand',
        Beurkundeter_Kaufpreis__c = app.Purchase_Price__c,
        Immobilie__c = propertyId
    ));
}

insert opps;