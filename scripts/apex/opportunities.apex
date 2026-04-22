// Update owner by account owner
List<Opportunity> opps = [SELECT Id, Account.OwnerId, OwnerId FROM Opportunity WHERE IsWon = TRUE AND Owner.IsActive = false AND Account.Owner.IsActive = true AND Notartermin__c = LAST_YEAR];

for(Opportunity opp:opps) {
    opp.OwnerId = opp.Account.OwnerId;
}

update opps;



///
SELECT Id, Bank__c FROM Opportunity WHERE Bank__c != null
SELECT Id, Kreditinstitut__c, Opportunity__c FROM Finanzierungsanfrage__c WHERE Kreditinstitut__c = null AND Opportunity__r.Bank__c != null
SELECT Id, Kreditinstitut__c, Opportunity__c FROM Finanzierungsanfrage__c WHERE Kreditinstitut__c != null AND Opportunity__r.Bank__c = null

SELECT Id, Bank__c FROM Opportunity WHERE Bank__r.RecordType.DeveloperName != 'Endkundenfinanzierer' AND Bank__c != null

List<Finanzierungsanfrage__c> fas = [SELECT Id, Kreditinstitut__c, Opportunity__r.Bank__c FROM Finanzierungsanfrage__c WHERE Kreditinstitut__c = null AND Opportunity__r.Bank__c != null];

for(Finanzierungsanfrage__c fa:fas) {
    fa.Kreditinstitut__c = fa.Opportunity__r.Bank__c;
}

update fas; 



SELECT Id, RecordTypeId FROM Account WHERE Id IN (SELECT Bank__c FROM Opportunity WHERE Bank__r.RecordType.DeveloperName != 'EndCustomerFinancier' AND Bank__c != null)



List<Finanzierungsanfrage__c> fas = [SELECT Id, Kreditinstitut__c, Opportunity__c FROM Finanzierungsanfrage__c WHERE Kreditinstitut__c != null AND Opportunity__r.Bank__c = null];
List<Opportunity> opps = new List<Opportunity>();

for(Finanzierungsanfrage__c fa:fas) {
    Opportunity opp = new Opportunity();
    opp.Bank__c = fa.Kreditinstitut__c;
    opp.Id = fa.Opportunity__c;
    opps.add(opp);
}

update opps; 