public without sharing class SendFinanzierungsbestaetigungAction {

    @InvocableMethod(
        label='Finanzierungsbestätigung senden'
        description='Sendet die Finanzierungsbestätigung E-Mail mit FB PDF im Anhang.'
    )
    public static void send(List<Id> finanzierungsanfrageIds) {
        if (finanzierungsanfrageIds == null || finanzierungsanfrageIds.isEmpty()) {
            return;
        }

        for (Id faId : finanzierungsanfrageIds) {
            if (faId != null) {
                FinanzierungsanfrageService.sendFinanzierungsbestaetigung(faId);
            }
        }
    }
}