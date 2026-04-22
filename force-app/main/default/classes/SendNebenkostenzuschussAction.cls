public without sharing class SendNebenkostenzuschussAction {

    @InvocableMethod(
        label='Nebenkostenzuschuss senden'
        description='Sendet die Nebenkostenzuschuss E-Mail an den Vertriebskoordinator der Opportunity.'
    )
    public static void send(List<Id> opportunityIds) {
        if (opportunityIds == null || opportunityIds.isEmpty()) {
            return;
        }

        for (Id oppId : opportunityIds) {
            if (oppId != null) {
                OpportunityService.sendNebenkostenzuschuss(oppId);
            }
        }
    }
}