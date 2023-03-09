@isTest
public class GetOrgBaseUrlTest {
    static string BASE_URL = URL.getSalesforceBaseUrl().toExternalForm(); //add base url to test
    @testSetup
    static void setup() {
        TestDataFactory.createDatevSettings();
    }

    @isTest
    static void checkIfBaseUrlIsOK() {
        Account acc = TestDataFactory.createAccount(true);
        Test.startTest();
        string url = GetOrgBaseUrl.getBaseUrl(new List<sObject>{
                acc
        })[0].sfdcBaseURL;
        System.assertEquals(url, BASE_URL);
        Test.stopTest();
    }
    @isTest
    static void checkIfBaseUrlWithIdIsOK() {
        Account acc = TestDataFactory.createAccount(true);
        Test.startTest();
        string urlWithId = GetOrgBaseUrl.getBaseUrl(new List<sObject>{
                acc
        })[0].sfdcRecordURL;
        System.assertEquals(urlwithId, BASE_URL + '/' + acc.id);
        Test.stopTest();
    }
}