global without sharing class ScheduledOposSync implements Schedulable {
    global static void execute(SchedulableContext sc){
        String soql = 'SELECT Id, Name FROM Account';
        BatchOposSync batch = new BatchOposSync();
        Database.executebatch(batch, 5);
    }
}