public with sharing class ProjektdatenblattController {
    public ProjektdatenblattController(ApexPages.StandardController controller) {

    }
    public Id immobilieId {
        get {
            immobilieId = ApexPages.currentPage().getParameters().get('id');
            System.debug('IMMOBILIE ID');
            System.debug(immobilieId);
            return immobilieId;
        }
        set;

    }
    

    public String immobiliePdfName {
        get {
            if(immobiliePdfName == null){
                List<Property__C> property =[
                    SELECT id, name
                    FROM Property__C
                    WHERE id= :immobilieId
                ];
            
                immobiliePdfName = String.valueOf(Date.today())+'_'+property[0].Name+'_Projektdatenblatt';

                System.debug('IMMOBILIE PDF NAME:');
                System.debug(immobiliePdfName);
            }           
            return immobiliePdfName;

        }
        set;
    }
}