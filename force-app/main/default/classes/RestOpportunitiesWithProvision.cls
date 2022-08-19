@RestResource(urlMapping='/OpportunitiesWithProvision')
global with sharing class RestOpportunitiesWithProvision  {
    @HttpPost
    global static List<Opportunity> showOpportunities(Id accId, Id maklerId) {
        if(maklerId != null) {
            return getOpps(accId, maklerId);
        } 
        return getOpps(accId);
    }
    
    static List<Opportunity> getOpps(Id accId, Id maklerId) {
        List<Opportunity> oppsWithProvision = [SELECT Name, Potenzieller_Kunde__c, Potenzieller_Kunde__r.FirstName, Potenzieller_Kunde__r.LastName, Immobilie__r.Name, Appartement__r.Name, CreatedDate, Letztes_Phasenupdate_am__c, StageName, Kaufpreis__c, Reservierungsschein_vorhanden__c, Finanzierung_oder_Eigenkapitalnachweis__c, Nachweis_Barzahler__c, Risikobelehrung__c, Makler__r.FirstName, Makler__r.LastName, Notartermin__c, Beratungsprotokoll__c, KV_eingegangen__c, (SELECT Id, Provisionssumme__c, Provision_in__c, Makler__r.FirstName, Makler__r.LastName FROM Provisionen__r WHERE Makler__r.AccountId = : accId OR Makler__c = :maklerId) FROM Opportunity WHERE AccountId = :accId OR Immobilienberater__c = :maklerId OR TippgeberProvisionEmpfaenger__c = :maklerId OR Overhead_Empf_nger__c = :maklerId OR Maklerbetreuer_wirtschaftshaus__c = :maklerId];
        return oppsWithProvision;
    }
    
    static List<Opportunity> getOpps(Id accId) {
        List<Opportunity> oppsWithProvision = [SELECT Name, Potenzieller_Kunde__c, Potenzieller_Kunde__r.FirstName, Potenzieller_Kunde__r.LastName, Immobilie__r.Name, Appartement__r.Name, CreatedDate, Letztes_Phasenupdate_am__c, StageName, Kaufpreis__c, Reservierungsschein_vorhanden__c, Finanzierung_oder_Eigenkapitalnachweis__c, Nachweis_Barzahler__c, Risikobelehrung__c, Makler__r.FirstName, Makler__r.LastName, Notartermin__c, Beratungsprotokoll__c, KV_eingegangen__c, (SELECT Id, Provisionssumme__c, Provision_in__c, Makler__r.FirstName, Makler__r.LastName FROM Provisionen__r WHERE Makler__r.AccountId = : accId) FROM Opportunity WHERE AccountId = :accId];
        return oppsWithProvision;
    }
}