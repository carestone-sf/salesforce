public without sharing class AnkuendigungController {

    @AuraEnabled(cacheable=true)
    public static Ankuendigung__c getAnkuendigung() {
        Id userId = UserInfo.getUserId();
        Id profileId = UserInfo.getProfileId();
        Profile pf = [SELECT Name FROM Profile WHERE Id = :profileId];
        User usr = [SELECT ContactId, AccountId FROM User WHERE Id = :userId];
        Id conId = usr.ContactId;
        Id accId = usr.AccountId;
        List<Contact> mbCons = [SELECT OwnerId FROM Contact WHERE Id IN (SELECT Maklerbetreuer_Wirtschaftshaus_2__c FROM Account WHERE Id = :accId)];
        Id mbOwnerId;
        if(mbCons.size() > 0) {
            mbOwnerId = mbCons[0].ownerId;
        }
        DateTime now = DateTime.now();
        List<Ankuendigung__c> ankuendigungen = [SELECT Id, Inhalt__c, Name FROM Ankuendigung__c WHERE OwnerId = :mbOwnerId AND AnzeigenVon__c <= :now AND AnzeigenBis__c >= :now];
        if(ankuendigungen.size() > 0) {
            return ankuendigungen[0];
        }

        return null;
    }

}