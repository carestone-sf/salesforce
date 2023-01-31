

List<Property__c> immos = [SELECT Id, (SELECT Id, RateNummer__c FROM MaBV_Raten__r) FROM Property__c WHERE Id IN (SELECT Immobilie__c FROM MaBVRate__c)];

for(Property__c immo : immos) {
    for(MaBVRate__c rate : immo.MaBV_Raten__r) {
        String fieldName = 'Rate' + rate.RateNummer__c + '__c';
        immo.put(fieldName, rate.Id);
    }
}

update immos;


List<Property__c> properties = new List<Property__c>();
for (AggregateResult agRes : [SELECT SUM(WertKumulierteProvisionExtern__c) provExtern, Immobilie__c FROM Opportunity WHERE WertKumulierteProvisionExtern__c != null AND WertKumulierteProvisionExtern__c != 0 AND Immobilie__c != null GROUP BY Immobilie__c]) {
    properties.add(new Property__c(Id = (Id) agRes.get('Immobilie__c'), SummeWertKumulierteProvisionExtern__c = (Double) agRes.get('provExtern')));
}
update properties;




// Deliverability auf No Access stellen 
List<Account> accs = [SELECT Id, ParentId FROM Account WHERE CreatedDate <= 2022-01-01T00:00:00Z AND PotenzialanalyseErfasst__c = false 
AND Parent.Name LIKE '%CS Maklerbetreuer%' AND Alle_gewonnenen_Verkaufschancen__c < 1 
AND Carestone_Vertriebsvereinbarung__c = false AND ParentId != '0016700005mG0GVAA0' LIMIT 200];
for(Account acc : accs) {
    acc.ParentId = '0016700005mG0GVAA0';
}
update accs;