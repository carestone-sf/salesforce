public with sharing class DigitaleVSAController {
    public DigitaleVSAController(ApexPages.StandardController controller) {

    }

    private Id digitaleVsaId = ApexPages.currentPage().getParameters().get('id');

    //all Verbindlichkeiten connected to DigitaleVsa

    //TODO list of fields
    public List < VsaVerbindlichkeit__c > verbindlichkeiten {
        get {
            if (verbindlichkeiten == null) {
                verbindlichkeiten = [select id, name, DigitaleVsa__c, Art__c, Kreditgeber__c, UrspruenglicherDarlehensbetrag__c, ZinsbindungBis__c, TilgungBis__c, MonatlicheRate__c, AktuelleRestschuld__c   from VsaVerbindlichkeit__c where DigitaleVsa__c = :digitaleVsaId];
            }
            return verbindlichkeiten;
        }
        set;
    }
    //all Vermögenswerte connected to DigitaleVsa
    public List < VsaVermoegenswert__c > vermoegenswert {
        get {
            if (vermoegenswert == null) {
                vermoegenswert = [ select id, name, DigitaleVsa__c, Art__c, Gesellschaft__c, Vertragssumme__c, Sparbeginn__c, MonatlicheZahlung__c, AktuellesGuthaben__c from VsaVermoegenswert__c where DigitaleVsa__c = :digitaleVsaId];
            }
            return vermoegenswert;
        }
        set;
    }

    //all Immobilien connected to DigitaleVsa
    public List < VSAImmobilie__c > immobilie {
        get {
            if (immobilie == null) {
                immobilie = [ select id, name, DigitaleVsa__c,  Art__c, Verkehrswert__c, Restschuld__c, Kreditgeber__c, MonatlicheRate__c, MonatlicheNettokaltmiete__c, PostleitzahlOrtDerImmobilie__c	from VSAImmobilie__c where DigitaleVsa__c = :digitaleVsaId ];
            }
            return immobilie;
        }
        set;
    }
}