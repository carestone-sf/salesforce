public with sharing class ProjektdatenblattController {
    @TestVisible

    private id testImmobilieID;
    public ProjektdatenblattController(ApexPages.StandardController controller) {
        Apexpages.currentPage().getHeaders().put('content-disposition', 'attachment; filename=' + immobiliePdfDownloadName());
    }
    public Id immobilieId {
        get {
            return ApexPages.currentPage().getParameters().get('id');
        }
        set;

    }
    public Property__c immobilien {
        get {
            if (immobilien == null) {
                List<Property__C> property = [
                        SELECT id, name
                        FROM Property__C
                        WHERE id = :immobilieId
                        LIMIT 1
                ];
                immobilien = property.size() > 0 ? property[0] : null;
            }
            return immobilien;
        }
        set;
    }
    public String immobiliePdfName {
        get {
            if (immobiliePdfName == null) {
                immobiliePdfName = immobilien.Name;
            }
            return immobiliePdfName;

        }
        set;
    }
    public String immobiliePdfDownloadName() {
        return String.valueOf(Date.Today()) + '_' + immobiliePdfName + '_Projektdatenblatt.pdf';
    }
}