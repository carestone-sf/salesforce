public without sharing class AccountPropertyVisibilityController {
    
    
    @AuraEnabled
    public static List<PropertyWithVisibility> getProperties(Id accountId){
        List<PropertyWithVisibility> properties = new List<PropertyWithVisibility>();

        for(Property__c property : getPublicPropertiesWithVisibility(accountId)) {
            PropertyWithVisibility propertyWithVisibility = new PropertyWithVisibility();
            propertyWithVisibility.propertyId = property.Id;
            propertyWithVisibility.propertyName = property.Name;
            propertyWithVisibility.isVisible = property.HiddenForAccounts__r.isEmpty();
            properties.add(propertyWithVisibility);
        }

        return properties;
    }

    @AuraEnabled
    public static void hideProperty(Id accountId, Id propertyId){
        insert new HiddenProperty__c(Account__c = accountId, Property__c = propertyId);
    }

    @AuraEnabled
    public static void unhideProperty(Id accountId, Id propertyId){
        delete [SELECT Id FROM HiddenProperty__c WHERE Account__c = :accountId AND Property__c = :propertyId];
    }

    private static List<Property__c> getPublicPropertiesWithVisibility(Id accountId){
        return [SELECT Id, Name, (SELECT Id FROM HiddenForAccounts__r WHERE Account__c = :accountId) FROM Property__c WHERE Is_Public__c = true ORDER BY Name ASC];
    }

    public class PropertyWithVisibility {
        @AuraEnabled public String propertyId {get;set;}
        @AuraEnabled public String propertyName {get;set;}
        @AuraEnabled public Boolean isVisible {get;set;}
    }
}
