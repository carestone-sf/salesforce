/**
 * Created by frederikwitte on 11.08.20.
 */

trigger Gutschrift on Gutschrift__c (before insert, before update, after insert, after update) {

    Gutschrift_Storno_Laufnummer__c gutschriftStornoLaufnummer = Gutschrift_Storno_Laufnummer__c.getOrgDefaults();
    Decimal gutschriftStornoLaufnummerZahl = gutschriftStornoLaufnummer.Gutschrift_Storno_Laufnummer__c;
    Set<Id> conIdsSet = new Set<Id>();

    if(Trigger.isBefore) {
        for(Gutschrift__c gutschriftRecord:Trigger.new) {
            if(Trigger.isInsert) {
                gutschriftRecord.Name = gutschriftRecord.LaufnummerNew__c;
            }

            if(Trigger.isUpdate) {
                Gutschrift__c oldGutschriftRecord = Trigger.oldMap.get(gutschriftRecord.Id);

                if(gutschriftRecord.GutschriftStorniert__c && !oldGutschriftRecord.GutschriftStorniert__c) {
                    gutschriftRecord.DatumGutschriftStorniert__c = Date.today();
                    gutschriftRecord.StornoLaufnummerZahl__c = gutschriftStornoLaufnummerZahl;
                    gutschriftStornoLaufnummerZahl++;
                }

                if((gutschriftRecord.GutschriftWurdeGeneriert__c == true && oldGutschriftRecord.GutschriftWurdeGeneriert__c == false) ||
                     (gutschriftRecord.GutschriftWurdeGeneriert__c == true && oldGutschriftRecord.GutschriftWurdeGeneriert__c == false)) {
                    conIdsSet.add(gutschriftRecord.Empfaenger__c);
                }
            }
        }
    }

    if(Trigger.isAfter) {
        for (Gutschrift__c gutschriftRecord : Trigger.new) {
            if (Trigger.isInsert && !gutschriftRecord.KeineEmails__c) {
                Gutschrift.sendGutschriftAsPdf(gutschriftRecord.Id);
            }

            if(Trigger.isUpdate) {
                if(gutschriftRecord.GutschriftStorniert__c && !Trigger.oldMap.get(gutschriftRecord.Id).GutschriftStorniert__c && !gutschriftRecord.KeineEmails__c) {
                    GutschriftStorno.sendGutschriftStornoAsPdf(gutschriftRecord.Id);
                }
            }
        }
    }

    if(gutschriftStornoLaufnummerZahl != gutschriftStornoLaufnummer.Gutschrift_Storno_Laufnummer__c) {
        gutschriftStornoLaufnummer.Gutschrift_Storno_Laufnummer__c = gutschriftStornoLaufnummerZahl;
        update gutschriftStornoLaufnummer;
    }

    if(conIdsSet.size() > 0) {
        List<Id> accIds = new List<Id>();
        Map<Id, Account> idToAccMap = new Map<Id, Account>([SELECT Id FROM Account WHERE Id IN (SELECT AccountId FROM Contact WHERE Id IN :conIdsSet)]);
        accIds.addAll(idToAccMap.keySet());
        GenerateDatevCreditorNumbers generateDatevCreditorNumbers = new GenerateDatevCreditorNumbers();
        generateDatevCreditorNumbers.generateDatevCreditorNumbers(accIds);
    }

}