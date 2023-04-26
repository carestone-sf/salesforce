public with sharing class ProjektdatenblattController {
    @TestVisible

    //It specifies all characters except for lowercase and uppercase letters (a-z and A-Z), numbers (0-9), underscore (_), hyphen (-), and space ( ).
    private String CROPPED_NAME_REGEXP = '[^a-zA-Z0-9_\\\\x20\\\\x2D]';
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

    public String buildFullPDFName (){
        String returnedString = '';
        returnedString = String.valueOf(Date.Today())
                + '_' + immobiliePdfName.replaceAll(CROPPED_NAME_REGEXP, '')
                + '_Projektdatenblatt.pdf';

        return returnedString;
    }
    public String immobiliePdfDownloadName() {
        return buildFullPDFName();
    }
}