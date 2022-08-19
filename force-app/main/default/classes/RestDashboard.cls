@RestResource(urlMapping='/Dashboard')
global with sharing class RestDashboard  {

    @HttpPost
    global static DashboardData show(Id userId) {

        DashboardData dashboardData = new DashboardData(userId);

        return dashboardData;

    }

    global class DashboardData {
        List<Campaign> myCampaigns = new List<Campaign>();
        List<Campaign> webinars = new List<Campaign>();
        List<Campaign> otherCampaigns = new List<Campaign>();
        List<Property__c> properties = new List<Property__c>();
        List<Opportunity> oppsThisYear = new List<Opportunity>();
        List<Provision__c> provsThisYear = new List<Provision__c>();


        public DashboardData(Id userId) {
            // Get the User from which the request is being sent
            Realty_User__c user = [SELECT Contact__c FROM Realty_User__c WHERE Id = :userId];
            // Get the Contact related to the user
            Contact con = [SELECT Id, AccountId FROM Contact WHERE Id =: user.Contact__c];

            // Get all campaigns and then filter them in a for loop to add to the right list
            List<Campaign> allCampaigns = [SELECT Name, Id, Type, Speaker__c, Url__c, DateTime__c, Is_Public__c, Description FROM Campaign WHERE DateTime__c > TODAY AND Status != 'Abgeschlossen' AND Status != 'Abgebrochen'];
            for(Campaign camp:allCampaigns) {
                if(camp.Speaker__c == con.Id){
                    myCampaigns.add(camp);
                } else if(camp.Type == 'Online-Seminar') {
                    webinars.add(camp);
                } else {
                    otherCampaigns.add(camp);
                }
            }

            // Get highlight properties
            // Right now it's just the for most recent
            properties = [SELECT Name, Collection_Id__c FROM Property__c WHERE Is_Public__c = true AND Status_Reason__c = 'Aktiv' ORDER BY CreatedDate DESC LIMIT 4];

            // Get Data Statistics
            oppsThisYear = [SELECT StageName FROM Opportunity WHERE (Notartermin__c = THIS_YEAR OR CreatedDate = THIS_YEAR) AND Makler__c = :con.Id];
            provsThisYear = [SELECT Provisionssumme__c, Rechnungsvorlage_verschickt_am__c FROM Provision__c WHERE Makler__c = :con.Id AND (Rechnungsvorlage_verschickt_am__c = LAST_N_MONTHS:11 OR Rechnungsvorlage_verschickt_am__c = THIS_MONTH)];


        }

    }

}