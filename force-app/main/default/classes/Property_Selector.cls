public with sharing class Property_Selector extends Selector {

    private static final String fromObject = 'Property__c ';

    public List<Schema.SObjectField> getSObjectFieldList() {
        return new List<Schema.SObjectField> {
            Property__c.Id,
            Property__c.Name
        };
    }

    Id accountId;
    
    public Property_Selector(Id accountId) {
        super();
        this.accountId = accountId;
        setConditionWithSharing(null);
    }

    public List<Property__c> getRecords() {
        return (List<Property__c>) query();
    }

    public Schema.SObjectType getSObjectType() {
        return Property__c.SObjectType;
    }

    public final String visibilityBaseCondition = 'Id NOT IN (SELECT Property__c FROM HiddenProperty__c WHERE Account__c = ' + String.escapeSingleQuotes(this.accountId) + ')';

    public Property_Selector setConditionWithSharing(String condition) {
        if (condition == null) {
            condition = visibilityBaseCondition;
        } else {
            condition = '(' + condition + ') AND ' + visibilityBaseCondition;
        }
        setCondition(visibilityBaseCondition);
        return this;
    }
}
