public with sharing class Utility {
    
    public static Boolean checkIfDeliverabilityIsEnabled() {
        Boolean deliverabilityEnabled = true;
        try {
            Messaging.reserveSingleEmailCapacity(1);
            Messaging.reserveMassEmailCapacity(1);
        } catch(NoAccessException ex) {
            deliverabilityEnabled = false;
        }
        return deliverabilityEnabled;
    }
}
