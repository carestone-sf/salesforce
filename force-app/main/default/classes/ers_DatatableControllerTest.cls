@IsTest
private with sharing class ers_DatatableControllerTest {

    @TestSetup
    private static void setup(){
        Account a1 = TestDataFactory.createAccount(false, 'Test1', 'Bank');
        a1.AccountNumber='1';
        a1.AnnualRevenue=1000000;
        a1.Website='https://trailblazer.me/id/ericsmith';
        a1.Description='D1';
        insert a1;

        Account a2 = TestDataFactory.createAccount(false, 'Test2', 'Bank');
        a2.AccountNumber='2';
        a2.AnnualRevenue=2000000;
        a2.Website='https://ericsplayground.wordpress.com/blog/';
        a2.Description='D2';
        insert a2;
    }

    @IsTest
    static void test() {
        Account[] accts = [SELECT Id, Name, OwnerId FROM Account];
        String fieldnames = 'Name, Id, OwnerId, AccountNumber, Website, Type, Description, IsDeleted, CreatedDate, AnnualRevenue, Fax, LastActivityDate, NumberOfEmployees, ShippingLongitude';
        String testResponse = ers_DatatableController.getReturnResults(accts, fieldnames);
        System.assert(testResponse.contains('"noEditFieldList":['));
        System.assert(testResponse.contains('"lookupFieldList":["OwnerId"]'));

        String testCPEResponse = ers_DatatableController.getCPEReturnResults('Account');
        
        Account[] empty = [SELECT Id, Name, OwnerId FROM Account WHERE Name='NotInAccounts'];
        String testEmpty = ers_DatatableController.getReturnResults(empty, fieldnames);
        System.assert(testEmpty.contains('"objectName":"EmptyCollection"'));
    }

    @IsTest
    private static void testUnknownFieldException() {
        String fieldNames = 'Id, Name, BogusField';
        String assert = '';
        List<Account> accts = [SELECT Id, Name, OwnerId FROM Account];

        try {
            ers_DatatableController.getReturnResults(accts, fieldNames);
        } catch (Exception ex) {
            assert = ex.getMessage();
        }

        System.assertEquals('Could not find the field: BogusField on the object Account', assert);
    }

    @IsTest
    private static void testMultiCurrency() {
        String fieldNames = 'Id, Name, AnnualRevenue';
        List<Account> accts = [SELECT Id, Name, OwnerId FROM Account];
        ers_DatatableController.isMultiCurrencyOrganization = true;
        String testResponse = ers_DatatableController.getReturnResults(accts, fieldNames);
        System.assert(testResponse.contains('"AnnualRevenue":1000000'));
    }

    @IsTest
    private static void testGetNameUniqueField() {
        System.assertEquals('Name', ers_DatatableController.getNameUniqueField('Account'));
        System.assertEquals('Name', ers_DatatableController.getNameUniqueField('Contact'));
        System.assertEquals('OrderItemNumber', ers_DatatableController.getNameUniqueField('OrderItem'));
        System.assertEquals('Subject', ers_DatatableController.getNameUniqueField('Task'));
        System.assertEquals('CaseNumber', ers_DatatableController.getNameUniqueField('Case'));
    }

    @IsTest
    private static void testGetIconName() {
        System.assertEquals('standard:account', ers_DatatableController.getIconName('Account'));
        System.assertEquals('standard:contact', ers_DatatableController.getIconName('Contact'));
    }

}