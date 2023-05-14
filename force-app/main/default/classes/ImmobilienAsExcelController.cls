public with sharing class ImmobilienAsExcelController {

    public ImmobilienAsExcelController() {

    }


        private final sObject mysObject;

        public String timeNow {
                get {
                        if(timeNow == null) {
                                timeNow = DateTime.now().format();
                        }
                        return timeNow;
                }
                set;
        }

        public List<Property__c> properties {
                get {
                        if(properties == null) {
                                properties = [SELECT Name, Property__c, Max_Rendite__c, Real_Estate_Transfer_Tax__c, Street__c, Place__c, Zip_Code__c, Anzahl_Einheiten__c, Fl_che_ab__c, Fl_che_bis__c, Preis_ab__c, Preis_bis__c, Rendite_in__c, Betreiber__r.Name, Betreiber__r.Stra_e__c, Bauart__c, Betreiber__r.PLZ__c, Betreiber__r.Stadt__c, Teaser_Highlight_1__c, Teaser_Highlight_2__c, Teaser_Highlight_3__c, Teaser_Highlight_4__c, Teaser_Highlight_5__c, Teaser_Highlight_6__c, Teaser_Highlight_7__c, Teaser_Highlight_8__c, Teaser_Highlight_9__c, (SELECT Name, Area_sq_m__c, Monthly_rent_sq_m__c,Zimmerart__c, Monthly_rent__c, PurchasePriceRounded__c, Status__c FROM Appartments__r WHERE Status__c='Available' OR Status__c = 'Reservierung angefragt' OR Status__c = 'Reservierungsvorbereitung' OR Status__c = 'Reserved' ORDER BY Name) FROM Property__c WHERE (Is_Public__c = true AND Status_Reason__c = 'Aktiv') AND Id In (SELECT Property__c FROM Appartment__c WHERE Status__c='Available' OR Status__c = 'Reservierung angefragt' OR Status__c = 'Reservierungsvorbereitung' OR Status__c = 'Reserved') ORDER BY Name];
                        }
                        return properties;
                }
                set;
        }

        public List<Property__c> getProperties() {
                return properties;
        }

        public String getTimeNow() {
                return timeNow;
        }
}