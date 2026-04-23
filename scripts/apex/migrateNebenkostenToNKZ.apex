// One-time migration: creates Nebenkostenzuschuss__c records from existing
// Appartment__c and Property__c Marketingzuschuss values (Netto/Brutto/USt).
//
// Safe to re-run: skips Opportunities that already have an active (non-storniert) NKZ.
// Run in Execute Anonymous. Review System.debug output before committing.

// --- 1. Unit-level migration (Appartment -> Opportunity -> NKZ) ---

Set<Id> oppsWithExistingNkz = new Set<Id>();
for (Nebenkostenzuschuss__c nkz : [
    SELECT Opportunity__c
    FROM Nebenkostenzuschuss__c
    WHERE Opportunity__c != null AND Storniert__c = false
]) {
    oppsWithExistingNkz.add(nkz.Opportunity__c);
}

List<Opportunity> oppsWithUnitGrants = [
    SELECT Id, Immobilie__c, Appartement__c,
           Potenzieller_Kunde__c, Makler__c,
           Appartement__r.MarketingzuschussNetto__c,
           Appartement__r.MarketingzuschussBrutto__c,
           Appartement__r.MarketingzuschussUSt__c
    FROM Opportunity
    WHERE Appartement__c != null
      AND (
          (Appartement__r.MarketingzuschussNetto__c != null AND Appartement__r.MarketingzuschussNetto__c > 0)
          OR (Appartement__r.MarketingzuschussBrutto__c != null AND Appartement__r.MarketingzuschussBrutto__c > 0)
          OR (Appartement__r.MarketingzuschussUSt__c != null AND Appartement__r.MarketingzuschussUSt__c > 0)
      )
];

List<Nebenkostenzuschuss__c> toInsert = new List<Nebenkostenzuschuss__c>();

for (Opportunity opp : oppsWithUnitGrants) {
    if (oppsWithExistingNkz.contains(opp.Id)) {
        System.debug('SKIP (existing NKZ): Opportunity ' + opp.Id);
        continue;
    }

    Nebenkostenzuschuss__c nkz = new Nebenkostenzuschuss__c();
    nkz.Name = 'Migration - Marketingzuschuss';
    nkz.Opportunity__c = opp.Id;
    nkz.Objekt__c = opp.Immobilie__c;
    nkz.Teilobjekt__c = opp.Appartement__c;
    nkz.Kunde__c = opp.Potenzieller_Kunde__c;
    nkz.Empfaenger__c = opp.Makler__c;
    nkz.Betrag__c = opp.Appartement__r.MarketingzuschussNetto__c;
    nkz.BetragInklUSt__c = opp.Appartement__r.MarketingzuschussBrutto__c;
    nkz.USt__c = opp.Appartement__r.MarketingzuschussUSt__c;
    toInsert.add(nkz);
}

System.debug('Unit-level NKZ records to create: ' + toInsert.size());

// --- 2. Property-level migration (Property -> NKZ without Teilobjekt) ---
// Only for Properties that have a Marketingzuschuss but where no unit-level
// Opportunities were migrated above.

Set<Id> migratedPropertyIds = new Set<Id>();
for (Nebenkostenzuschuss__c nkz : toInsert) {
    if (nkz.Objekt__c != null) {
        migratedPropertyIds.add(nkz.Objekt__c);
    }
}
for (Nebenkostenzuschuss__c nkz : [
    SELECT Objekt__c FROM Nebenkostenzuschuss__c
    WHERE Objekt__c != null AND Storniert__c = false
]) {
    migratedPropertyIds.add(nkz.Objekt__c);
}

List<Property__c> propertiesWithGrants = [
    SELECT Id,
           MarketingzuschussNetto__c,
           MarketingzuschussBrutto__c,
           MarketingzuschussUSt__c
    FROM Property__c
    WHERE (
          (MarketingzuschussNetto__c != null AND MarketingzuschussNetto__c > 0)
          OR (MarketingzuschussBrutto__c != null AND MarketingzuschussBrutto__c > 0)
          OR (MarketingzuschussUSt__c != null AND MarketingzuschussUSt__c > 0)
      )
      AND Id NOT IN :migratedPropertyIds
];

for (Property__c prop : propertiesWithGrants) {
    Nebenkostenzuschuss__c nkz = new Nebenkostenzuschuss__c();
    nkz.Name = 'Migration - Marketingzuschuss (Objekt)';
    nkz.Objekt__c = prop.Id;
    nkz.Betrag__c = prop.MarketingzuschussNetto__c;
    nkz.BetragInklUSt__c = prop.MarketingzuschussBrutto__c;
    nkz.USt__c = prop.MarketingzuschussUSt__c;
    toInsert.add(nkz);
}

System.debug('Total NKZ records to create (incl. property-level): ' + toInsert.size());

if (!toInsert.isEmpty()) {
    insert toInsert;
    System.debug('Successfully inserted ' + toInsert.size() + ' Nebenkostenzuschuss records.');
} else {
    System.debug('No records to migrate.');
}
