@isTest
public with sharing class RelatedListControllerTest {
    @isTest public static void testInit(){
        Contact cnt = new Contact();
        cnt.FirstNAme = 'Frank';
        cnt.LastName = 'Köpsell';
        cnt.Email = 'witte@amstammtisch.de';
        cnt.MaklerBetreuer_E_Mail__c = 'witte@amstammtisch.de';
        insert cnt;
        Account acc = new Account();
        acc.Name = 'WH Maklerbetreuer - Frank Köpsell';
        acc.Email__c = 'witte@amstammtisch.de';
        acc.Maklerbetreuer_Wirtschaftshaus__c = 'Frank Köpsell';
        acc.Maklerbetreuer_Wirtschaftshaus_2__c = cnt.Id;
        acc.BIC__c  = '1';
        acc.Geschueftsfuehrer__c = cnt.id;
        acc.Gesetzliche_MwSt_auf_Provisionszahlung__c = 0.4;
        acc.Hinweis_zur_MwSt__c = 'Vertrag';
        acc.IBAN__c = 'DE43250501801900212158';
        acc.Rechtsform__c = 'GbR';
        acc.Unternehmensname__c = 'CareStone';
        insert acc;
        cnt.AccountId = acc.Id;
        update cnt;
                
        Map<String, Object> requestMap = new Map<String, Object>(); 
        requestMap.put(RelatedListController.FIELDS_PARAM, 'Name, Title, Email, Phone');
        requestMap.put(RelatedListController.RELATED_FIELD_API_NAME_PARAM, 'AccountId');
        requestMap.put(RelatedListController.RECORD_ID_PARAM, acc.Id);
        requestMap.put(RelatedListController.NUMBER_OF_RECORDS_PARAM, 1);
        requestMap.put(RelatedListController.SOBJECT_API_NAME_PARAM, 'Contact');
        requestMap.put(RelatedListController.SORTED_BY_PARAM, 'Name');
        requestMap.put(RelatedListController.SORTED_DIRECTION_PARAM, 'ASC');
                
        String jsonData = RelatedListController.initData(JSON.serialize(requestMap));
        Map<String, Object> responseMap = (Map<String, Object>)JSON.deserializeUntyped(jsonData);
        List<Object> records = (List<Object>)responseMap.get(RelatedListController.RECORDS_PARAM);
        System.assert(!records.isEmpty());
        String iconName = (String)responseMap.get(RelatedListController.ICON_NAME_PARAM);
        System.assert(String.isNotBlank(iconName));
    }
}