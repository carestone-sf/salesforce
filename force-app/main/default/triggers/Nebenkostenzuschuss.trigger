trigger Nebenkostenzuschuss on Nebenkostenzuschuss__c (before update, after update) {

    NKZ_Storno_Laufnummer__c nkzStornoLaufnummer = NKZ_Storno_Laufnummer__c.getOrgDefaults();
    Decimal nkzStornoLaufnummerZahl = nkzStornoLaufnummer.NKZ_Storno_Laufnummer__c;

    if (Trigger.isBefore) {
        for (Nebenkostenzuschuss__c nkzRecord : Trigger.new) {
            if (Trigger.isUpdate) {
                Nebenkostenzuschuss__c oldRecord = Trigger.oldMap.get(nkzRecord.Id);

                if (nkzRecord.Storniert__c && !oldRecord.Storniert__c) {
                    nkzRecord.DatumStorniert__c = Date.today();
                    nkzRecord.StornoLaufnummerZahl__c = nkzStornoLaufnummerZahl;
                    nkzStornoLaufnummerZahl++;
                }
            }
        }
    }

    if (Trigger.isAfter) {
        for (Nebenkostenzuschuss__c nkzRecord : Trigger.new) {
            if (Trigger.isUpdate) {
                if (nkzRecord.Storniert__c && !Trigger.oldMap.get(nkzRecord.Id).Storniert__c) {
                    NebenkostenzuschussStorno.sendNKZStornoAsPdf(nkzRecord.Id);
                }
            }
        }
    }

    if (nkzStornoLaufnummerZahl != nkzStornoLaufnummer.NKZ_Storno_Laufnummer__c) {
        nkzStornoLaufnummer.NKZ_Storno_Laufnummer__c = nkzStornoLaufnummerZahl;
        update nkzStornoLaufnummer;
    }

}
