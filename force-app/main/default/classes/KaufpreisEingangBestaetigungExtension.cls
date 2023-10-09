public class KaufpreisEingangBestaetigungExtension {
    private final Opportunity opp;
    
    // The extension constructor initializes the private member
    // variable acct by using the getRecord method from the standard
    // controller.
    public KaufpreisEingangBestaetigungExtension(ApexPages.StandardController stdController) {
        this.opp = (Opportunity)stdController.getRecord();
    }

    public List<Zahlung__c> getZahlungen() {
        List<Zahlung__c> zahlungen = [SELECT Id, Name, Betrag__c, Zahldatum__c, BusinessPartner__c, IBAN__c, AccountingText__c FROM Zahlung__c WHERE MaBVRechnung__r.MaBVRechnungMaster__r.Opportunity__c = :this.opp.Id Order By Zahldatum__c ASC];
        return zahlungen;
    }
    
    public List<VKCZahlung__c> getVKCZahlungen() {
        List<VKCZahlung__c> zahlungen = [SELECT Id, Name, Betrag__c, Zahldatum__c, BusinessPartner__c, IBAN__c, AccountingText__c FROM VKCZahlung__c WHERE Verkaufschance__c = :this.opp.Id Order By Zahldatum__c ASC];
        return zahlungen;
    }
}