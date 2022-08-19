public without sharing class GenerateDatevCreditorNumbers {
    public void generateDatevCreditorNumbers(List<Id> accIds) {
        try {
            List<Account> accs = [SELECT DatevKreditorennummer__c FROM Account WHERE Id IN :accIds];

            DatevKreditorennummer__c datevKreditorennummerSetting = DatevKreditorennummer__c.getOrgDefaults();
            Decimal datevKreditorennummer = datevKreditorennummerSetting.DatevKreditorennummer__c;
            for (Account acc : accs) {
                if (acc.DatevKreditorennummer__c == null) {
                    acc.DatevKreditorennummer__c = String.valueOf((Integer) datevKreditorennummer);
                    datevKreditorennummer++;
                }
            }

            if (datevKreditorennummer != datevKreditorennummerSetting.DatevKreditorennummer__c) {
                datevKreditorennummerSetting.DatevKreditorennummer__c = datevKreditorennummer;
                update datevKreditorennummerSetting;
                update accs;
            }

        } catch(Exception e) {
            throw e;
        }

    }
}