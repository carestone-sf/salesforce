public without sharing class ImmoframeController {

    @AuraEnabled(cacheable=true)
    public static Immoframe_Konfiguration__c getImmoframeKonfiguration() {
        Id userId = UserInfo.getUserId();
        Id profileId = UserInfo.getProfileId();
        User usr = [SELECT ContactId, AccountId FROM User WHERE Id = :userId];
        Id conId = usr.ContactId;
        List<Immoframe_Konfiguration__c> imks = [SELECT Id, Name, URL__c, ServiceWohnungen__c, Pflegeapartments__c, Mikroapartments__c, Wohnimmobilien__c, Theme__c, Color__c, Lightcolor__c, Exposee__c, Grundriss__c, Factsheets__c, Transparent__c FROM Immoframe_Konfiguration__c WHERE Makler__c = :conId];
        Immoframe_Konfiguration__c imk;
        if (imks.size() > 0) {
            imk = imks[0];
        }

        return imk;
    }

    @AuraEnabled
    public static void insertImmoframeKonfiguration() {
        Id userId = UserInfo.getUserId();
        Id profileId = UserInfo.getProfileId();
        User usr = [SELECT ContactId, AccountId FROM User WHERE Id = :userId];
        Id conId = usr.ContactId;
        Immoframe_Konfiguration__c imk = new Immoframe_Konfiguration__c(Makler__c=conId);
        insert imk;
    }
}