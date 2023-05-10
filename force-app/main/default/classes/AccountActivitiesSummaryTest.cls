@isTest
private class AccountActivitiesSummaryTest {
    @isTest
    private static void testAccountActivitiesSummary(){
        Account acc = TestDataFactory.createAccount(true);
        User testUser = TestDataFactory.createCommunityUser(acc.Id);
        Contact con = [SELECT Id FROM Contact WHERE AccountId = :acc.Id LIMIT 1];
        con.VPBenutzerLetzterLogin__c = DateTime.now();
        con.CommunityUser__c = testUser.Id;
        update con;
        Account bautraeger = TestDataFactory.createBautraeger(true);
        Property__c p = TestDataFactory.createProperty(true, bautraeger.Id);
        Task incomingCallTask = TestDataFactory.createTask(true, con.Id, 'Eingehender Anruf');
        Task outgoingCallTask = TestDataFactory.createTask(true, con.Id, 'Ausgehender Anruf');
        
        Berechnung__c b;
        Test.startTest();
        System.RunAs(testUser){
            TestDataFactory.createInteressent(true, acc.Id);
            b = TestDataFactory.createCalculation(true, con.Id);
        }
        AccountActivitiesSummarySchedulable.scheduleMe();
        Database.executeBatch(new AccountActivitiesSummaryBatch());
        Test.stopTest();
        
        acc = [SELECT VPUserLastLogin__c, CalculationsCurrentYear__c, CustomersCreatedCurrentYear__c, IncomingCallsCurrentYear__c, OutgoingCallsCurrentYear__c, LastOutgoingCall__c, LastIncomingCall__c, LastCalculation__c FROM Account WHERE Id = :acc.Id];
        System.assertEquals(1, acc.CalculationsCurrentYear__c, 'Expected 1 created calculation');
        System.assertEquals(1, acc.CustomersCreatedCurrentYear__c, 'Expected 1 created customer');
        System.assertEquals(1, acc.IncomingCallsCurrentYear__c, 'Expected 1 incoming call');
        System.assertEquals(1, acc.OutgoingCallsCurrentYear__c, 'Expected 1 outgoing call');
        outgoingCallTask = [SELECT CreatedDate FROM Task WHERE Id = :outgoingCallTask.Id];
        incomingCallTask = [SELECT CreatedDate FROM Task WHERE Id = :incomingCallTask.Id];
        System.assertEquals(outgoingCallTask.CreatedDate, acc.LastOutgoingCall__c, 'Expected last outgoing call to match with task created date');
        System.assertEquals(incomingCallTask.CreatedDate, acc.LastIncomingCall__c, 'Expected last incoming call to match with task created date');
        b = [SELECT CreatedDate FROM Berechnung__c WHERE Id = :b.Id];
        System.assertEquals(b.CreatedDate, acc.LastCalculation__c, 'Expected last calculation to match with calculation created date');
        System.assertEquals(con.VPBenutzerLetzterLogin__c, acc.VPUserLastLogin__c, 'Expected last login to match with contact last login date');
    }
}