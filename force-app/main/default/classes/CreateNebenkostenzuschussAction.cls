public without sharing class CreateNebenkostenzuschussAction {

    @InvocableMethod(
        label='Nebenkostenzuschuss erstellen'
        description='Erstellt einen Nebenkostenzuschuss aus einer Opportunity.'
    )
    public static List<Id> create(List<Id> opportunityIds) {
        if (opportunityIds == null || opportunityIds.isEmpty()) {
            return new List<Id>();
        }

        List<Nebenkostenzuschuss__c> created = NebenkostenzuschussService.createFromOpportunities(opportunityIds);

        List<Id> result = new List<Id>();
        for (Nebenkostenzuschuss__c nkz : created) {
            result.add(nkz.Id);
        }
        return result;
    }
}
