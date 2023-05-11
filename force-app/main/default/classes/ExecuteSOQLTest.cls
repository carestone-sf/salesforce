@isTest
public class ExecuteSOQLTest {
    @isTest 
    public static void testExecuteEnglishUpperCasePM() {
        Account acc = TestDataFactory.createAccount(true, 'Test Account', null);

        //Not formatted DateTime
        ExecuteSOQL.Requests requests = new ExecuteSOQL.Requests();
        requests.soqlQuery = 'Select Id From Account Where CreatedDate >= 04/12/2020 03:24 PM';

        Test.startTest();
        List<ExecuteSOQL.Results> results = ExecuteSOQL.execute(new List<ExecuteSOQL.Requests>{
                requests
        });
        Test.stopTest();
        System.assertEquals(acc.Id, results[0].sObjects[0].Id);
    }

    @isTest
    public static void testExecuteEnglishWithComma() {
        Account acc = TestDataFactory.createAccount(true, 'Test1', null);
        Test.setCreatedDate(acc.id, Datetime.newInstance(2020, 4, 12, 1, 0, 0));

        ExecuteSOQL.Requests requests = new ExecuteSOQL.Requests();
        requests.soqlQuery = 'Select Id From Account Where CreatedDate <= 04/12/2020, 12:00 pm';

        Test.startTest();
        List<ExecuteSOQL.Results> results = ExecuteSOQL.execute(new List<ExecuteSOQL.Requests>{
            requests
        });
        Test.stopTest();
        System.assertEquals(acc.Id, results[0].sObjects[0].Id);
    }

    @isTest
    private static void testExecuteSOQLMonthDayCommaYear() {
        Account acc = TestDataFactory.createAccount(true, 'Test Account', null);

        //Not formatted Date
        ExecuteSOQL.Requests requests = new ExecuteSOQL.Requests();
        requests.soqlQuery = 'Select Id From Account Where CreatedDate >= April 12, 2020';

        Test.startTest();
        List<ExecuteSOQL.Results> results = ExecuteSOQL.execute(new List<ExecuteSOQL.Requests>{
                requests
        });
        Test.stopTest();

        System.assertEquals(acc.Id, results[0].sObjects[0].Id);
    }
    
    @isTest
    private static void testExecuteSOQLLonDateTime() {
        Account acc = TestDataFactory.createAccount(true, 'Test Account', null);

        //Formatted date time
        ExecuteSOQL.Requests requests = new ExecuteSOQL.Requests();
        requests.soqlQuery = 'Select Id From Account Where CreatedDate >= 2020-04-12T15:24:00Z';

        Test.startTest();
        List<ExecuteSOQL.Results> results = ExecuteSOQL.execute(new List<ExecuteSOQL.Requests>{
                requests
        });
        Test.stopTest();

        System.assertEquals(acc.Id, results[0].sObjects[0].Id);
    }
    
        @isTest
    private static void testExecuteSOQLDateLiteral() {
        Account acc = TestDataFactory.createAccount(true, 'Test1', null); 

        //Formatted date time
        ExecuteSOQL.Requests requests = new ExecuteSOQL.Requests();
        requests.soqlQuery = 'Select Id From Account Where CreatedDate = LAST_n_DAYS:14';

        Test.startTest();
        List<ExecuteSOQL.Results> results = ExecuteSOQL.execute(new List<ExecuteSOQL.Requests>{
                requests
        });
        Test.stopTest();
        System.assertEquals(1, results[0].sObjects.size());
        System.assertEquals(acc.Id, results[0].sObjects[0].Id);
    }

    @isTest
    private static void testExecuteSOQLLimit() {        
        insert new List<Account>{TestDataFactory.createAccount(false, 'Test 3', null), TestDataFactory.createAccount(false, 'Test 1', null), TestDataFactory.createAccount(false, 'Test 2', null)};
        
        ExecuteSOQL.Requests requests = new ExecuteSOQL.Requests();
        requests.soqlQuery = 'Select Id From Account Where Name != \'TEST\' LIMIT 2';
                
        Test.startTest();
        List<ExecuteSOQL.Results> results = ExecuteSOQL.execute(new List<ExecuteSOQL.Requests>{requests});
        Test.stopTest();
        
        System.assertEquals(2, results[0].sObjects.size());  
    }

    @isTest
    private static void testExecuteSOQLId() {   
        Account searchAccount = TestDataFactory.createAccount(false, 'Test 3', null);
        insert new List<Account>{searchAccount, TestDataFactory.createAccount(false, 'Test 1', null), TestDataFactory.createAccount(false, 'Test 2', null)};
        
        ExecuteSOQL.Requests requests = new ExecuteSOQL.Requests();
        requests.soqlQuery = 'Select Id From Account Where Name != \'TEST\' AND Id = \'' + searchAccount.Id + '\'';
                
        Test.startTest();
        List<ExecuteSOQL.Results> results = ExecuteSOQL.execute(new List<ExecuteSOQL.Requests>{requests});
        Test.stopTest();
        
        System.assertEquals(1, results[0].sObjects.size());  
        System.assertEquals(searchAccount.Id, results[0].sObjects[0].Id);  
    }
    
    @isTest
    private static void testExecuteSOQLOrderBy() {
        insert new List<Account>{TestDataFactory.createAccount(false, 'Apple', null),TestDataFactory.createAccount(false, 'Pear', null), TestDataFactory.createAccount(false, 'Cucumber', null)};
        
        ExecuteSOQL.Requests requests = new ExecuteSOQL.Requests();
        requests.soqlQuery = 'Select Id,Name From Account Order By Name';
                
        Test.startTest();
        List<ExecuteSOQL.Results> results = ExecuteSOQL.execute(new List<ExecuteSOQL.Requests>{requests});
        Test.stopTest();
        
        System.assertEquals(true, results[0].sObjects.size() == 3);
        List<Account> accounts = (List<Account>)results[0].sObjects;
        System.assertEquals('Apple', accounts[0].Name);
        System.assertEquals('Cucumber', accounts[1].Name);
        System.assertEquals('Pear', accounts[2].Name);
    }

    @isTest
    private static void testExecuteSOQLRelationshipQuery() {
        Account act = TestDataFactory.createAccount(true, 'Test1', null);

        Contact ct = TestDataFactory.createContact(false);
        ct.AccountId=act.Id;
        insert ct;

        ExecuteSOQL.Requests requests = new ExecuteSOQL.Requests();
        requests.soqlQuery = 'Select Id, AccountId, Account.Name From Contact Where AccountId in (SELECT Id from Account WHERE Name in (\'Test1\', \'Test2\', \'Test3\')) ';

        Test.startTest();
        List<ExecuteSOQL.Results> results = ExecuteSOQL.execute(new List<ExecuteSOQL.Requests>{requests});
        Test.stopTest();

        System.assertEquals(1, results[0].sObjects.size());

        Contact returnedContact = (Contact) (results[0].sObjects[0]);
        System.assertEquals(ct.Id, returnedContact.Id);
        System.assertEquals(act.Id, returnedContact.AccountId);
        System.assertEquals('Test1', returnedContact.Account.Name);
    }
    
    @isTest
    private static void testGetFieldTypesUnknownSObjectType() {
        String sObjectTypeName = 'theObjectThatMustNotBeNamed';
        String msg = '[ExecuteSOQLException Not Thrown for Unknown sObject Type]';
        Test.startTest();
        try {
            Map<String, String> results = ExecuteSOQL.getFieldTypes(sObjectTypeName, new List<String>());
        } catch (ExecuteSOQL.ExecuteSOQLException e) {
            msg = e.getMessage();
        }
        Test.stopTest();
        System.assertEquals('Unable to get sObject Type for name: '+ sObjectTypeName, msg);
    }

    @isTest
    private static void testReplaceWithFormattedValuesWithBadQueryString() {
        String soqlQuery = 'DOES NOT COMPUTE WHERE SELECT FROM ';
        String msg = '[ExecuteSOQLException Not Thrown for Bad Query String]';
        Test.startTest();
        try {
            String result = ExecuteSOQL.replaceWithFormattedValues(soqlQuery);
        } catch (ExecuteSOQL.ExecuteSOQLException e) {
            msg = e.getMessage();
        }
        Test.stopTest();
        System.assertEquals('Unable to parse query string: ' + soqlQuery, msg);
    }

    @isTest
    private static void testGetFormattedValueWithInteger() {
        String fieldvalue = '1';
        String fieldType = 'INTEGER';
        Test.startTest();
        String actualFieldvalue = ExecuteSOQL.getFormattedValue(fieldValue, fieldType);
        Test.stopTest();
        System.assertEquals(actualFieldvalue, fieldValue);
    }

    @isTest
    public static void testBulkification() {
        final Integer NUM_ACCOUNTS = 11;

        List<Account> accounts = TestDataFactory.createAccounts(true, null, NUM_ACCOUNTS);
        
        List<ExecuteSOQL.Requests> requestsList = new List<ExecuteSOQL.Requests>();
        ExecuteSOQL.Requests requests;
        for (Integer i=1; i <= NUM_ACCOUNTS; i++) {
            requests = new ExecuteSOQL.Requests();
            requests.soqlQuery = 'Select Id From Account Where Name LIKE \'Makler _%\' LIMIT ' + String.valueOf(i);
            requestsList.add(requests);
        }
        System.debug('testBulkification: requestsList.size() ' + requestsList.size());
        Test.startTest();
        List<ExecuteSOQL.Results> resultsList = ExecuteSOQL.execute(requestsList);
        Test.stopTest();
        System.debug('testBulkification: requestsList.size() ' + requestsList.size() +', resultsList.size() ' + resultsList.size());
        System.assertEquals(requestsList.size(), resultsList.size(), 'Results list size');
        for (Integer i=0; i < resultsList.size(); i++) {
            ExecuteSOQL.Results results =resultsList[i];
            List<SObject> sObjects = results.sObjects;
            System.debug('testBulkification: sObjects.size() ' + sObjects.size() +', expected ' + (i+1));
            System.assertEquals(i+1, sObjects.size(), 'Returned SObjects size');
        }
    }

    @isTest
    public static void testLegacyEntryPoint() {
        Account acc = TestDataFactory.createAccount(true, 'Test Account', null);
        
        ExecuteSOQL.Requests requests = new ExecuteSOQL.Requests();
        requests.soqlQuery = 'Select Id From Account Where CreatedDate >= YESTERDAY';

        Test.startTest();
        List<ExecuteSOQL.Results> results = ExecuteSOQL.getEligibleProducts(new List<ExecuteSOQL.Requests>{
                requests
        });
        Test.stopTest();
        System.assertEquals(acc.Id, results[0].sObjects[0].Id);
    }
}