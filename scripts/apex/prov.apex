Opportunity opp = [SELECT Id, Notartermin__c, Immobilie__c, Appartement__c, Potenzieller_Kunde__c, Provisionsbasis__c, OwnerId, MarketingzuschussNichtAusweisen__c, Maklerbetreuer_WirtschaftsHaus__c FROM Opportunity WHERE Id = '006Vi00000593gXIAQ'];
Contact con = [SELECT Id, Email FROM Contact WHERE Id = :opp.Maklerbetreuer_WirtschaftsHaus__c];
String schedule = 'month';
Provision__c prov = new Provision__c();
        prov.UniqueId__c = opp.Id + '-' + con.Id;
        if(schedule != null) {
            prov.UniqueId__c += '-' + schedule;
        }
        prov.Verkaufschance__c = opp.Id;
        prov.Makler__c = con.Id;
        prov.Objekt__c = opp.Immobilie__c;
        prov.Wohneinheit__c = opp.Appartement__c;
        prov.Kunde__c = opp.Potenzieller_Kunde__c;
        prov.Ausl_ser__c = con.Id;
        prov.E_Mail__c = con.Email;
        prov.Kaufpreis__c = opp.Provisionsbasis__c;
        prov.Maklerbetreuer__c = opp.OwnerId;
        prov.MarketingzuschussNichtAusweisen__c = opp.MarketingzuschussNichtAusweisen__c;
        Integer monthOpp = opp.Notartermin__c.month();
        if(schedule == 'month') {
            prov.ProvisionsvoraussetzungenErfuelltAm__c = opp.Notartermin__c;
        }
        
        prov.AnzahlEinheitenMonat__c = 1;
        prov.Provisionszeitraum__c = 'Monat';

        if(opp.Maklerbetreuer_WirtschaftsHaus__c == con.Id) {
            Decimal erfolgsabhaengigeProvision = 0.0025;
            prov.ErfolgsabhaengigeProvisionInProzent__c = erfolgsabhaengigeProvision*100;
            prov.Erfolgsabh_ngige_Provision_direkt__c = erfolgsabhaengigeProvision * opp.Provisionsbasis__c;
        }
        
        insert prov;






        // 1. Define your list of Opportunity IDs
List<Id> oppIds = new List<Id>{
    '006Vi000004RyU3IAK','006Vi000009r49xIAA','006Vi000009qm9qIAA',
    '006Vi000004V5QxIAK','006Vi000004VI6PIAW',
    '006Vi000004SRkXIAW','006Vi000004SBFzIAO','006Vi0000066HApIAM',
    '006Vi000004TW73IAG','006Vi000004VDbOIAW','006Vi000004VGXeIAO',
    '006Vi000004Rz3VIAS','006Vi000004S4UbIAK','006Vi000004Wf0vIAC',
    '006Vi000004VDJdIAO','006Vi000004TZkrIAG','006Vi000004S0xIIAS',
    '006Vi000005FxIUIA0','006Vi000004SSOrIAO','006Vi000004VLsHIAW',
    '006Vi000004SZwbIAG','006Vi000004ZG61IAG'
};

// 2. Query Opportunities with their Provisionen__r children
List<Opportunity> opps = [
    SELECT Id,
           Abweichende_Grundprovision__c,
           (SELECT Id, Kaufpreis__c, Makler__c, Wert_Maklerprovision__c, GutschriftBestaetigt__c
            FROM Provisionen__r)
    FROM Opportunity
    WHERE Id IN :oppIds AND Abweichende_Grundprovision__c != 4.5 LIMIT 1
];

// Prepare lists for bulk updates
List<Provision__c> provUpdates = new List<Provision__c>();
List<Opportunity> oppUpdates  = new List<Opportunity>();
    system.debug(opps.size());
// 3. Loop through each Opportunity and its child Provisionen__r
for (Opportunity opp : opps) {

    for (Provision__c prov : opp.Provisionen__r) {
        if(prov.Makler__c == '0036700003DFR5WAAX') {
            // a) Calculate 0.5% of Kaufpreis__c
            prov.Wert_Maklerprovision__c = prov.Kaufpreis__c * 0.005;
            prov.Maklerbetreuer__c = '0056700000CEw7lAAD';
            
            // b) First update: GutschriftBestaetigt__c = false
            prov.GutschriftBestaetigt__c = false;
            update prov;
            
            // c) Second update: GutschriftBestaetigt__c = true
            prov.GutschriftBestaetigt__c = true;
            update prov;
        }
    }
    
    // d) Queue the Opportunity for updating its Abweichende_Grundprovision__c
    opp.Abweichende_Grundprovision__c = 4.5;
    oppUpdates.add(opp);
}

// 4. Bulk-update all modified Opportunities
if (!oppUpdates.isEmpty()) {
    update oppUpdates;
}

System.debug('Provision updates and Opportunity updates completed.');
