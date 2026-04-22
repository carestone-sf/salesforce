// Update Accounts to Pool
List<Account> accs = [SELECT ParentId, Maklerbetreuer_Wirtschaftshaus_2__c, OwnerId FROM Account WHERE ParentId = null LIMIT 500];

for(Account acc:accs) {
    acc.OwnerId = '005b0000001V30PAAS';
    acc.ParentId = '001b000000f8WOVAA2';
    acc.Maklerbetreuer_Wirtschaftshaus_2__c = '003b0000002oyrDAAQ';
}

update accs;

// Put all pool accounts into a single pool
List<Account> accs = [SELECT ParentId, Maklerbetreuer_Wirtschaftshaus_2__c, OwnerId FROM Account WHERE ParentId = '001Vi000004X1hNIAS' OR ParentId = '001b000000dy78YAAQ'];

for(Account acc:accs) {
    acc.OwnerId = '005b0000001V30PAAS';
    acc.ParentId = '001b000000f8WOVAA2';
    acc.Maklerbetreuer_Wirtschaftshaus_2__c = '003b0000002oyrDAAQ';
}

update accs;


// Set from parent
List<Account> accs = [SELECT Name, Parent.Name, Parent.OwnerId, Parent.Maklerbetreuer_Wirtschaftshaus_2__c, Maklerbetreuer_Wirtschaftshaus_2__c,Maklerbetreuer_Wirtschaftshaus_2__r.Name, OwnerId FROM Account WHERE Maklerbetreuer_Wirtschaftshaus_2__r.OwnerId = '005b0000001V30PAAS' AND Maklerbetreuer_Wirtschaftshaus_2__r.Name != 'Sandro Pawils' AND Parent.Name != 'Poolmakler' AND (NOT Name LIKE 'CS Maklerbetreuer%')];

for(Account acc:accs) {
    acc.OwnerId = acc.Parent.OwnerId;
    acc.Maklerbetreuer_Wirtschaftshaus_2__c = acc.Parent.Maklerbetreuer_Wirtschaftshaus_2__c;
}

update accs;


//AI

List<Account> accs = [SELECT PotenzialanalyseStarten__c FROM Account WHERE ParentId = '0016700005mG0GVAA0' AND PotenzialanalyseStarten__c = false AND PotenzialanalyseErfasst__c = false LIMIT 500];

for(Account acc:accs) {
    acc.PotenzialanalyseStarten__c = true;
}

update accs;


List<Account> accs = [SELECT PotenzialanalyseErfasst__c FROM Account WHERE ParentId = '0016700005mG0GVAA0' AND PotenzialanalyseErfasst__c = true];

for(Account acc:accs) {
    acc.PotenzialanalyseErfasst__c = false;
}

update accs;