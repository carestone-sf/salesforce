@RestResource(urlMapping='/Immoframe')
global with sharing class RestImmoframe  {

    @HttpGet
    global static List<Property__c> show() {

        List<Property__c> properties = [SELECT Id, Website_Header_Bild__c, Name, MaBV__c, Completion__c, state__c, place__c, street__c, zip_code__c, property__c, description__c, share_Redevelopment_Substance__c, Value_Plot__c, Objektvideo_Link__c, Highlights__c, energieausweis__c, Freie_Appartments__c, reservierte_appartements__c, verkaufte_appartements__c, Infozeile_1__c, Infozeile_2__c, is_public__c, Collection_Id__c, Max_Rendite__c, Rendite_In__c, Vorschau_Appartements__c, Preis_ab__c, Preis_bis__c, Betreiber__r.Id, Betreiber__r.Name, In_Vorschau__c,  Betreiber__r.Stra_e__c, Betreiber__r.PLZ__c, Betreiber__r.Stadt__c, Betreiber__r.Betreiber_Logo__c, Betreiber__r.Betreiberinformationen__c,(SELECT status__c, id, Name, Purchase_Price__c, Area_sq_m__c, Monthly_rent_sq_m__c, Monthly_Rent__c, Notary_And_Court_Costs_1_5__c, Maintenance_sqm__c, Cost_Admin__c, Depreciation_Value__c, Real_Estate_Transfer_Tax__c, Net_asset_value__c, Net_Asset_Value_AFA__c, Value_of_OIutdoor__c, Outdoor_AFA__c, Purchase_Price_sq_m__c, Rental_return_old__c FROM Appartments__r ORDER BY Name)  FROM Property__c WHERE (Is_Public__c = true AND Status_Reason__c = 'Aktiv' AND Immoframe__c = false) ORDER BY Name];

        return properties;

    }

}