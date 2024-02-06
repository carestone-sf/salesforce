public without sharing class ImmobilienController {

    public static ConnectorService connectorService;
    public static Boolean validConnector { get; set; }
    public static ffhttp_GoogleDrive client;

    @AuraEnabled(Cacheable=true)
    public static Immobilie[] getMaklerImmobilien() {
        Id userId = UserInfo.getUserId();
        Id profileId = UserInfo.getProfileId();
        Profile pf = [SELECT Name FROM Profile WHERE Id = :profileId];
        User usr = [SELECT ContactId, AccountId FROM User WHERE Id = :userId];
        Id conId = usr.ContactId;
        Id accId = usr.AccountId;
        List<Property__c> properties = new List<Property__c>();
        if(conId == null) {
            
        } else if (pf.Name.contains('Manager')) {
            properties = [
                SELECT Id, Name, Website_Header_Bild__c, DisruptorLogoOne__c, DisruptorLogoTwo__c, (SELECT Id, DateiUrl__c, PreviewUrl__c, FileLastModifiedDate__c, ThumbnailUrl__c, Name, ParentOrdner__c, DateiTyp__c FROM ImmobilienDmsDateien__r), PreSale__c, Preis_ab__c, MaBV__c, Foerderung__c, Projektbeauftragte__r.Name, Projektbeauftragte__r.Email__c,Projektbeauftragte__r.Telefonnummer__c,Projektbeauftragte__r.Foto_URL__c, Preis_bis__c, Anzahl_Einheiten__c, Location__Latitude__s, Property__c, State__c, Rendite_in__c, Arrival__c, Bauart__c, Location__Longitude__s, Street__c, Zip_Code__c, Place__c, Unternehmen__c,Verkaufte_Appartements__c, MieteVon__c, MieteBis__c,Reservierte_Appartements__c, Fl_che_ab__c, Fl_che_bis__c, Operating_Company__c,Freie_Appartments__c, Description__c, SalesDescription__c, Lagebeschreibung__c, Betreiber__r.Name, Betreiber__r.Betreiberinformationen__c, Betreiber__r.Betreiber_Logo__c, Finanzierung_Details__c, Operating_Company__r.Name,Notar__r.Account.Name,Notar__r.Account.BillingStreet,Notar__r.Account.BillingCity,Notar__r.Account.BillingPostalCode, Completion__c, FAQ__c, Max_Rendite__c, Min_Rendite__c, (SELECT Id, Name,Purchase_Price_sq_m__c,Monthly_Rent__c,Cost_Admin__c,Maintenance_sqm__c,Area_sq_m__c, RentalReturnFormulaVP__c, Purchase_Price__c, Notartermin__c, Status__c, Property__r.Name, FlaecheQmText__c, Jahresmiete__c FROM Appartments__r WHERE Makler__r.AccountId =: accId AND Status__c = 'Sold' Order By Name ASC)
                FROM Property__c
                WHERE ShowInObjectArchive__c = TRUE
                AND Id NOT IN (SELECT Property__c FROM HiddenProperty__c WHERE Account__c = :accId) Order By Name ASC
            ];
        } else {
            properties = [
                SELECT Id, Name, Website_Header_Bild__c, DisruptorLogoOne__c, DisruptorLogoTwo__c, (SELECT Id, DateiUrl__c, PreviewUrl__c, FileLastModifiedDate__c, ThumbnailUrl__c, Name, ParentOrdner__c, DateiTyp__c FROM ImmobilienDmsDateien__r), PreSale__c, Preis_ab__c, MaBV__c, Foerderung__c, Projektbeauftragte__r.Name, Projektbeauftragte__r.Email__c,Projektbeauftragte__r.Telefonnummer__c,Projektbeauftragte__r.Foto_URL__c, Preis_bis__c, Anzahl_Einheiten__c, Location__Latitude__s, Property__c, State__c, Rendite_in__c, Arrival__c, Bauart__c, Location__Longitude__s, Street__c, Zip_Code__c, Place__c, Unternehmen__c,Verkaufte_Appartements__c, MieteVon__c, MieteBis__c,Reservierte_Appartements__c, Fl_che_ab__c, Fl_che_bis__c, Operating_Company__c,Freie_Appartments__c, Description__c, SalesDescription__c, Lagebeschreibung__c, Betreiber__r.Name, Betreiber__r.Betreiberinformationen__c, Betreiber__r.Betreiber_Logo__c, Finanzierung_Details__c, Operating_Company__r.Name,Notar__r.Account.Name,Notar__r.Account.BillingStreet,Notar__r.Account.BillingCity,Notar__r.Account.BillingPostalCode, Completion__c, FAQ__c, Max_Rendite__c, Min_Rendite__c, (SELECT Id, Name,Purchase_Price_sq_m__c,Monthly_Rent__c,Cost_Admin__c,Maintenance_sqm__c,Area_sq_m__c, RentalReturnFormulaVP__c, Purchase_Price__c, Notartermin__c, Status__c, Property__r.Name, FlaecheQmText__c, Jahresmiete__c FROM Appartments__r WHERE Makler__c =: conId AND Status__c = 'Sold' Order By Name ASC)
                FROM Property__c
                WHERE ShowInObjectArchive__c = TRUE
                AND Id NOT IN (SELECT Property__c FROM HiddenProperty__c WHERE Account__c = :accId) Order By Name ASC
            ];
        }
        
        return getImmobilienList(properties);
    }

    @AuraEnabled(Cacheable=true)
    public static Immobilie[] getPublicImmobilien() {
        /*
        Contact contact = [SELECT Id, AccountId FROM Contact WHERE Id = :UserInfo.getUserId()];
        Property_Selector selector = new Property_Selector(contact.AccountId);
        selector.setFields(new List<Schema.SObjectField> {Property__c.Location__Latitude__s, Property__c.PreSale__c, Property__c.Property__c, Property__c.Bauart__c});
        selector.addSubquery('Appartments__r', new List<Schema.SObjectField> {Appartment__c.Id, Appartment__c.Name, Appartment__c.Purchase_Price__c, Appartment__c.Purchase_Price__c, Appartment__c.Notartermin__c, Appartment__c.Property__r.Name}, null);
        selector.setConditionWithSharing('ImVertriebsportalSichtbar__c = TRUE AND PreSale__c = FALSE');
        return getImmobilienList(selector.getRecords());
        selector.setConditionWithSharing('ImVertriebsportalSichtbar__c = TRUE AND PreSale__c = FALSE');
        */
        
        String query = 'SELECT Id, Name, Location__Latitude__s, PreSale__c, Property__c, Bauart__c, (SELECT Id, Name, Purchase_Price__c, Notartermin__c, Property__r.Name FROM Appartments__r Order By Name ASC) FROM Property__c WHERE ImVertriebsportalSichtbar__c = TRUE AND PreSale__c = FALSE';

        if(0 != [SELECT COUNT() FROM Contact WHERE Id IN (SELECT ContactId FROM User WHERE Id = :UserInfo.getUserId())]) {
            Contact contact = [SELECT Id, AccountId FROM Contact WHERE Id IN (SELECT ContactId FROM User WHERE Id = :UserInfo.getUserId())];
            query += ' AND Id NOT IN (SELECT Property__c FROM HiddenProperty__c WHERE Account__c = \'' + contact.AccountId + '\')';
        }

        List<Property__c> properties = (List<Property__c>) Database.query(query);
        return getImmobilienList(properties);
    }

    @AuraEnabled(Cacheable=true)
    public static Immobilie[] getAllImmobilien() {
        Id userId = UserInfo.getUserId();
        Id profileId = UserInfo.getProfileId();
        Profile pf = [SELECT Name FROM Profile WHERE Id = :profileId];
        User usr = [SELECT ContactId, Contact.AccountId FROM User WHERE Id = :userId];
        Id conId = usr.ContactId;
        Id accId = null;
        if(usr.Contact != null && usr.Contact.AccountId != null) {
            accId = usr.Contact.AccountId;
        }

        List<Property__c> publicProperties = [
            SELECT  Id, Teaser_Highlight_1__c, Teaser_Highlight_2__c, Teaser_Highlight_3__c, Name, Website_Header_Bild__c, DisruptorLogoOne__c, DisruptorLogoTwo__c, (SELECT Id, DateiUrl__c, PreviewUrl__c, FileLastModifiedDate__c, ThumbnailUrl__c, Name, ParentOrdner__c, DateiTyp__c FROM ImmobilienDmsDateien__r), PreSale__c, Preis_ab__c, MaBV__c, Foerderung__c, Projektbeauftragte__r.Name, Projektbeauftragte__r.Email__c,Projektbeauftragte__r.Telefonnummer__c,Projektbeauftragte__r.Foto_URL__c, Preis_bis__c, Anzahl_Einheiten__c, Location__Latitude__s, Property__c, State__c, Rendite_in__c, Arrival__c, Bauart__c, Location__Longitude__s, Street__c, Zip_Code__c, Place__c, Unternehmen__c,Verkaufte_Appartements__c, MieteVon__c, MieteBis__c,Reservierte_Appartements__c, Fl_che_ab__c, Fl_che_bis__c, Operating_Company__c,Freie_Appartments__c, Description__c, SalesDescription__c, Lagebeschreibung__c, Betreiber__r.Name, Betreiber__r.Betreiberinformationen__c, Betreiber__r.Betreiber_Logo__c, Finanzierung_Details__c, Operating_Company__r.Name,Notar__r.Account.Name,Notar__r.Account.BillingStreet,Notar__r.Account.BillingCity,Notar__r.Account.BillingPostalCode, Completion__c, FAQ__c,BuildingProgressWebcam__c, Max_Rendite__c, Min_Rendite__c, (SELECT Id, OeffentlicherStatus__c, Name,Purchase_Price_sq_m__c,Monthly_Rent__c,Cost_Admin__c,Maintenance_sqm__c,Area_sq_m__c, RentalReturnFormulaVP__c, Purchase_Price__c, Notartermin__c, Status__c, Property__r.Name, FlaecheQmText__c, Jahresmiete__c FROM Appartments__r WHERE Status__c != 'Sold' Order By Name ASC)
            FROM Property__c WHERE ImVertriebsportalSichtbar__c = true
            AND Id NOT IN (SELECT Property__c FROM HiddenProperty__c WHERE Account__c = :accId)
        ];

        List<Property__c> exklusivProperties = [
            SELECT  Id, Teaser_Highlight_1__c, Teaser_Highlight_2__c, Teaser_Highlight_3__c, Name, Website_Header_Bild__c, DisruptorLogoOne__c, DisruptorLogoTwo__c, (SELECT Id, DateiUrl__c, PreviewUrl__c, FileLastModifiedDate__c, ThumbnailUrl__c, Name, ParentOrdner__c, DateiTyp__c FROM ImmobilienDmsDateien__r), PreSale__c, Preis_ab__c, MaBV__c, Foerderung__c, Projektbeauftragte__r.Name, Projektbeauftragte__r.Email__c,Projektbeauftragte__r.Telefonnummer__c,Projektbeauftragte__r.Foto_URL__c, Preis_bis__c, Anzahl_Einheiten__c, Location__Latitude__s, Property__c, State__c, Rendite_in__c, Arrival__c, Bauart__c, Location__Longitude__s, Street__c, Zip_Code__c, Place__c, Unternehmen__c,Verkaufte_Appartements__c, MieteVon__c, MieteBis__c,Reservierte_Appartements__c, Fl_che_ab__c, Fl_che_bis__c, Operating_Company__c,Freie_Appartments__c, Description__c, SalesDescription__c, Lagebeschreibung__c, Betreiber__r.Name, Betreiber__r.Betreiberinformationen__c, Betreiber__r.Betreiber_Logo__c, Finanzierung_Details__c, Operating_Company__r.Name,Notar__r.Account.Name,Notar__r.Account.BillingStreet,Notar__r.Account.BillingCity,Notar__r.Account.BillingPostalCode, Completion__c, FAQ__c,BuildingProgressWebcam__c, Max_Rendite__c, Min_Rendite__c, (SELECT Id, OeffentlicherStatus__c, Name,Purchase_Price_sq_m__c,Monthly_Rent__c,Cost_Admin__c,Maintenance_sqm__c,Area_sq_m__c, RentalReturnFormulaVP__c, Purchase_Price__c, Notartermin__c, Status__c, Property__r.Name, FlaecheQmText__c, Jahresmiete__c FROM Appartments__r WHERE Status__c != 'Sold' Order By Name ASC)
            FROM Property__c WHERE Id in (SELECT Immobilie__c FROM Exklusiv_im_ImmoFinder__c WHERE Account__c = :accId)
        ];

        Set<Property__c> propsSet = new Set<Property__c>();
        propsSet.addAll(publicProperties);
        propsSet.addAll(exklusivProperties);
        List<Property__c> mergedProperties = new List<Property__c>();
        for(Property__c prop:propsSet) {
            if(prop.Anzahl_Einheiten__c > 0) {
                mergedProperties.add(prop);
            }
        }
        mergedProperties.sort();
        return getImmobilienList(mergedProperties);
    }

    @AuraEnabled(Cacheable=true)
    public static Immobilie[] getHighlightImmobilien() {
        if(0 != [SELECT COUNT() FROM Contact WHERE Id IN (SELECT ContactId FROM User WHERE Id = :UserInfo.getUserId())]) {
            Contact contact = [SELECT Id, AccountId FROM Contact WHERE Id IN (SELECT ContactId FROM User WHERE Id = :UserInfo.getUserId())];
            List<Property__c> properties = [
                SELECT Id, Name, Website_Header_Bild__c, DisruptorLogoOne__c, DisruptorLogoTwo__c, (SELECT Id, DateiUrl__c, PreviewUrl__c, FileLastModifiedDate__c, ThumbnailUrl__c, Name, ParentOrdner__c, DateiTyp__c FROM ImmobilienDmsDateien__r), PreSale__c, Verkaufte_Appartements__c, MieteVon__c, MieteBis__c, Reservierte_Appartements__c, Freie_Appartments__c, Preis_ab__c, Preis_bis__c, 
                (SELECT Id, Name,Purchase_Price_sq_m__c,Monthly_Rent__c,Cost_Admin__c,Maintenance_sqm__c,Area_sq_m__c, RentalReturnFormulaVP__c, Purchase_Price__c, Notartermin__c, Status__c, Property__r.Name FROM Appartments__r Order By Name ASC) 
                FROM Property__c 
                WHERE ImVertriebsportalSichtbar__c = true 
                AND Immobilie_promoten__c = true
                AND Id NOT IN (SELECT Property__c FROM HiddenProperty__c WHERE Account__c = :contact.AccountId)
            ];
            return getImmobilienList(properties);
        } else {
            List<Property__c> properties = [
                SELECT Id, Name, Website_Header_Bild__c, DisruptorLogoOne__c, DisruptorLogoTwo__c, (SELECT Id, DateiUrl__c, PreviewUrl__c, FileLastModifiedDate__c, ThumbnailUrl__c, Name, ParentOrdner__c, DateiTyp__c FROM ImmobilienDmsDateien__r), PreSale__c, Verkaufte_Appartements__c, MieteVon__c, MieteBis__c, Reservierte_Appartements__c, Freie_Appartments__c, Preis_ab__c, Preis_bis__c, 
                (SELECT Id, Name,Purchase_Price_sq_m__c,Monthly_Rent__c,Cost_Admin__c,Maintenance_sqm__c,Area_sq_m__c, RentalReturnFormulaVP__c, Purchase_Price__c, Notartermin__c, Status__c, Property__r.Name FROM Appartments__r Order By Name ASC) 
                FROM Property__c 
                WHERE ImVertriebsportalSichtbar__c = true 
                AND Immobilie_promoten__c = true
            ];
            return getImmobilienList(properties);
        }
    }

    public static List<Immobilie> getImmobilienList(List<Property__c> properties) {

        Map<Id,Immobilie> immosByIds = new Map<Id,Immobilie>();

        for(Property__c property:properties) {
            Immobilie i = new Immobilie();
            i.immobilie = property;
            for(ImmobilienDmsDatei__c immobilienDatei:property.ImmobilienDmsDateien__r) {
                if(immobilienDatei.DateiTyp__c == 'Bilder' || immobilienDatei.DateiTyp__c == 'Highlights') { 
                    if(!immobilienDatei.Name.contains('logo') && !immobilienDatei.Name.contains('berechnung') && !immobilienDatei.Name.contains('header')) {
                        Map<String, String> metadata = new Map<String, String>();
                        metadata.put('previewUrl', immobilienDatei.PreviewUrl__c);
                        metadata.put('downloadUrl', immobilienDatei.DateiUrl__c);
                        metadata.put('thumbnailUrl', immobilienDatei.ThumbnailUrl__c);
                        i.bilder.add(metadata);
                        i.highlightBilder.add(metadata);
                    } else if(immobilienDatei.Name.contains('logo')) {
                        i.logo = immobilienDatei.ThumbnailUrl__c;
                    }
                } else if(immobilienDatei.DateiTyp__c == 'Grundrisse') {
                    Map<String, String> metadata = new Map<String, String>();
                    metadata.put('previewUrl', immobilienDatei.PreviewUrl__c);
                    metadata.put('downloadUrl', immobilienDatei.DateiUrl__c);
                    metadata.put('thumbnailUrl', immobilienDatei.ThumbnailUrl__c);
                    i.bilder.add(metadata);
                } else if(immobilienDatei.DateiTyp__c == 'Baufortschritt') {
                    Map<String, String> metadata = new Map<String, String>();
                    metadata.put('previewUrl', immobilienDatei.PreviewUrl__c);
                    metadata.put('downloadUrl', immobilienDatei.DateiUrl__c);
                    metadata.put('thumbnailUrl', immobilienDatei.ThumbnailUrl__c);
                    i.constructionBilder.add(metadata);
                } else {
                    Map<String, String> metadata = new Map<String, String>();
                    metadata.put('id', immobilienDatei.Id);
                    metadata.put('name', immobilienDatei.Name);
                    metadata.put('previewUrl', immobilienDatei.PreviewUrl__c);
                    metadata.put('downloadUrl', immobilienDatei.DateiUrl__c);
                    metadata.put('parentFolder', immobilienDatei.ParentOrdner__c);
                    metadata.put('fileLastModifiedDate', String.valueOf(immobilienDatei.FileLastModifiedDate__c));
                    i.dokumente.add(metadata);
                }
            }
            immosByIds.put(property.Id, i);
            for(Appartment__c teilobjekt : property.Appartments__r) {
                immosByIds.get(teilobjekt.Property__c).teilobjekte.add(teilobjekt);
            }
        }

        return immosByIds.values();
    }

    public class Immobilie {
        @AuraEnabled
        public Property__c immobilie{get;set;}

        @AuraEnabled
        public List<Map<String, String>> bilder{get;set;}

        @AuraEnabled
        public List<Map<String, String>> highlightBilder{get;set;}

        @AuraEnabled
        public List<Map<String, String>> constructionBilder{get;set;}

        @AuraEnabled
        public List<Map<String, String>> dokumente{get;set;}

        @AuraEnabled
        public String logo{get;set;}

        @AuraEnabled
        public List<Appartment__c> teilobjekte {get;set;}

        public Immobilie() {
            this.bilder = new List<Map<String,String>>();
            this.highlightBilder = new List<Map<String,String>>();
            this.constructionBilder = new List<Map<String,String>>();
            this.dokumente = new List<Map<String,String>>();
            this.teilobjekte = new List<Appartment__c>();
        }
    }
}