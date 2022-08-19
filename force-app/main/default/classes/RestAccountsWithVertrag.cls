@RestResource(urlMapping='/AccountsWithVertrag')
global with sharing class RestAccountsWithVertrag  {

    @HttpGet
    global static List<Account> show() {
        List<Account> accs = [SELECT Name, ParentId, Parent.Name FROM Account WHERE WHS_Maklerauftrag__c = 'Maklerauftrag beidseitig unterzeichnet' OR WHS_Maklerauftrag__c = 'Makler mit altem Vertrag'];

        return accs;
    }

}