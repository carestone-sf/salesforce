// Use .apex files to store anonymous Apex.
// You can execute anonymous Apex in VS Code by selecting the
//     apex text and running the command:
//     SFDX: Execute Anonymous Apex with Currently Selected Text
// You can also execute the entire file by running the command:
//     SFDX: Execute Anonymous Apex with Editor Contents

string tempvar = 'Enter_your_name_here';
System.debug('Hello World!');
System.debug('My name is ' + tempvar);


MaBVRechnung__c mabvs = [SELECT Id FROM MaBVRechnung__c WHERE MahnungGenerieren__c = true];
for(MaBVRechnung__c mabv : mabvs) {
    mabv.Mahnstufe__c = 1;
}
update mabvs;


List<Appartment__c> updateList = new List<Appartment__c>();
for(Opportunity opp : [
    SELECT Id, Appartement__c, Potenzieller_Kunde__c, Makler__c, Datum_Kaufpreis_bezahlt__c, Notartermin__c, Finanzierung__c,
    Maklerbetreuer_WirtschaftsHaus__c, reserviert_bis__c, beurkundeter_Kaufpreis__c, Provisionsbasis__c, Beurkundung__c, KumulierteProvisionExtern__c, Kaufpreis_f_llig__c,
    Bezahlt__c
    FROM Opportunity WHERE Id IN ('0066700000wXrqJAAS')]) {
    
    Appartment__c apartment = new Appartment__c(Id = opp.Appartement__c);
    apartment.Customer__c = opp.Potenzieller_Kunde__c;
    apartment.Makler__c = opp.Makler__c;
    apartment.Kaufpreis_gezahlt_am__c = opp.Datum_Kaufpreis_bezahlt__c;
    apartment.Notartermin__c = opp.Notartermin__c;
    apartment.Finanzierung__c = opp.Finanzierung__c;
    apartment.Maklerbetreuer_WirtschaftsHaus_lookup__c = opp.Maklerbetreuer_WirtschaftsHaus__c;
    apartment.Reserviert_bis__c = opp.reserviert_bis__c;
    apartment.beurkundeter_Kaufpreis__c = opp.beurkundeter_Kaufpreis__c;
    apartment.Provisionsbasis__c = opp.Provisionsbasis__c;
    apartment.Beurkundung__c = opp.Beurkundung__c;
    apartment.Kumulierte_Provision_extern__c = opp.KumulierteProvisionExtern__c;
    apartment.KaufpreisFaellig__c = opp.Kaufpreis_f_llig__c;
    apartment.ReserviertFuer__c = opp.Id;
    if(opp.Bezahlt__c != 0) {
        apartment.Bezahlt__c = opp.Bezahlt__c;
    }
    updateList.add(apartment);
}

update updateList;



List<Property__c> immobilien = new List<Property__c>();
for(AggregateResult agRes : [SELECT SUM(OffenerBetrag__c) offen, SUM(AbgerechneterBetrag__c) abgerechnet, Immobilie__c immoId FROM Opportunity WHERE (Datum_Kaufpreisf_lligkeitsschreiben__c <= TODAY OR Kaufpreis_bezahlt__c = true) AND IsWon = true AND (HatVKCZahlungen__c = true OR Immobilie__r.Kaufpreiszahlung__c = 'Endfällig') GROUP BY Immobilie__c]) {
    Id immoId = (Id) agRes.get('immoId');
    Double offen = (Double) agRes.get('offen');
    Double abgerechnet = (Double) agRes.get('abgerechnet');

    Property__c immo = new Property__c(Id = immoId);
    immo.OffenerBetragEinmalzahlungen__c = offen;
    immo.AbgerechneteEinmalzahlungen__c = abgerechnet;
    immobilien.add(immo);
}
update immobilien;


List<Appartment__c> appToUpdate = new List <Appartment__c> ();
for(Opportunity opp : [SELECT Id, Appartement__c FROM Opportunity WHERE IsWon = true AND Kaufpreis_f_llig__c = true AND Appartement__r.KaufpreisFaellig__c = false]) {
    appToUpdate.add(new Appartment__c(Id = opp.Appartement__c, KaufpreisFaellig__c = true));
}
update appToUpdate;


Map<Id,Opportunity> oppMap = new Map<Id,Opportunity>([
    SELECT Id, Abrechnung_ber__c, Makler__c, Immobilie__c, Appartement__c,
    Maklerbetreuer_WirtschaftsHaus__c, Immobilienberater__c,
    Overhead_Empf_nger__c, TippgeberProvisionEmpfaenger__c, Provision_Thoben__c, 
    Potenzieller_Kunde__c, Provisionsbasis__c, OwnerId, MarketingzuschussNichtAusweisen__c,
    Wert_Verk_ufer_Beratungsprovision_m_R__c, Wert_Maklerprovision__c, WertMarketingzuschuss__c,
    WertErfolgsabhaengigeProvision__c
    FROM Opportunity WHERE Id = '0066700000wXigyAAC'
]);
GenerateProvision gPro = new GenerateProvision();
gPro.updateProvisionen(oppMap, oppMap, 'all');


List<Provision__c> provis = [SELECT Id, Verkaufschance__c FROM Provision__c WHERE Id IN ('a0Q6700000JWr0JEAT', 'a0Q6700000JWr0TEAT', 'a0Q6700000JWr0OEAT', 'a0Q6700000JWv6YEAT', 'a0Q6700000JWr0sEAD', 'a0Q6700000JWr0pEAD')];

Map<Id,Opportunity> oppMap = new Map<Id, Opportunity>([
    SELECT Id, Abrechnung_ber__c, Makler__c, Immobilie__c, Appartement__c,
    Maklerbetreuer_WirtschaftsHaus__c, Immobilienberater__c,
    Overhead_Empf_nger__c, TippgeberProvisionEmpfaenger__c, Provision_Thoben__c, 
    Potenzieller_Kunde__c, Provisionsbasis__c, OwnerId, MarketingzuschussNichtAusweisen__c,
    Wert_Verk_ufer_Beratungsprovision_m_R__c, Wert_Maklerprovision__c, WertMarketingzuschuss__c,
    WertErfolgsabhaengigeProvision__c, Wert_Provision_Thoben__c, AbrechnungUeberNurFuerGrundprovision__c,
    Wert_Tippprovision__c, Wert_Overhead__c
    FROM Opportunity 
    WHERE Id IN (SELECT Verkaufschance__c FROM Provision__c WHERE Id IN :provis)
]);
GenerateProvision gPro = new GenerateProvision();

for() {
    
}