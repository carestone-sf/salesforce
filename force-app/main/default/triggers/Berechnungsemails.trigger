trigger Berechnungsemails on Calculation__c (before insert) {
    if(Trigger.isInsert){
        if(Trigger.isBefore) {
            List<Id> immoUserIds = new List<Id>();
            for(Calculation__c calc:Trigger.new) {
                immoUserIds.add(calc.Brokers_Person__c);
            }

            Map<Id, Realty_User__c> immoUsers = new Map<Id, Realty_User__c>([SELECT Contact__c, Contact__r.Makler_E_Mail__c, Contact__r.MaklerBetreuer_E_Mail__c FROM Realty_User__c ru WHERE Id IN :immoUserIds]);

        	for(Calculation__c calc : Trigger.new){
                Realty_User__c immoUser = immoUsers.get(calc.Brokers_Person__c);
                if(immoUser.Contact__c != null) {
                    calc.Email_Maklerbetreuer__c = immoUser.Contact__r.MaklerBetreuer_E_Mail__c;
                    calc.EmailUebergeordneterMakler__c = immoUser.Contact__r.Makler_E_Mail__c;
                }
            }
        }
    }
}