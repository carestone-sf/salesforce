public without sharing class ProvisionController {

    @AuraEnabled(cacheable=true)
    public static List<Provision__c> getProvisionen() {
        Id userId = UserInfo.getUserId();
        Id profileId = UserInfo.getProfileId();
        User usr = [SELECT ContactId, AccountId FROM User WHERE Id = :userId];
        Id conId = usr.ContactId;
        List<Provision__c> provs = [SELECT Wert_Maklerprovision__c, Wert_Verk_ufer_Beratungsprovision_m_R__c, Provisionssumme__c, GutschriftBestaetigt__c, Rechnungsvorlage_verschickt_am__c FROM Provision__c WHERE Makler__c = :conId];
        return provs;
    }
}