public without sharing class GutschriftApprovalController {
    public String status {get;set;}

    public GutschriftApprovalController() {
        status = '';
    }

    public void approveGutschrift() {
        String gutschriftId = Apexpages.currentPage().getParameters().get('gutschriftId');
        String accepted = Apexpages.currentPage().getParameters().get('accepted');

        Provision__c[] prov = [SELECT Id, GutschriftBestaetigt__c, GutschriftAbgelehnt__c  FROM Provision__c WHERE Id = :gutschriftId];

        
        if (accepted != null && prov.size() > 0) {

            //Check if Provision has been already approved
            if (prov[0].GutschriftBestaetigt__c == true || prov[0].GutschriftAbgelehnt__c == true) {
                status = 'Diese Gutschrift wurde bereits bearbeitet.';
                return;
            }
            
            //Approve Provision
            if (accepted == 'true') {
                prov[0].GutschriftBestaetigt__c = true;
                status = 'Gutschrift erfolgreich bestätigt!';
            }
            //Reject Provision
            else if (accepted == 'false') {
                prov[0].GutschriftAbgelehnt__c = true;
                status = 'Gutschrift erfolgreich abgelehnt!';
            }
            //Parameter 'accepted' is not true or false
            else {
                status = 'Fehler! Bitte wenden Sie sich an Ihren Maklerbetreuer. <br/>(Fehlercode e1)';
            }

            try {
                update prov;
            } catch (Exception e) {
                System.debug('EXCEPTION: ' + e);
                status = 'Fehler! Bitte wenden Sie sich an Ihren Maklerbetreuer. <br/>(Fehlercode e2)';
            }
        }
        //Parameter 'gutschriftId' is either wrong or empty
        else if (prov.size() == 0) {
            status = 'Fehler! Bitte wenden Sie sich an Ihren Maklerbetreuer. <br/>(Fehlercode e3)';
        }

    }
}