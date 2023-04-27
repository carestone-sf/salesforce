@isTest
public class SandboxTest {
    @TestSetup
    static void makeData(){
        TestDataFactory.createNecessaryCustomSettings();
    }
    
    public testMethod static void runTest() {
        Test.startTest();
        Test.testSandboxPostCopyScript(
            new Sandbox(), UserInfo.getOrganizationId(),
                UserInfo.getOrganizationId(), UserInfo.getOrganizationName());
        Test.stopTest();
    }
}