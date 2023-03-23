public without sharing class EventController {
    
    @AuraEnabled(cacheable=true)
    public static List<CustomEvent> getCampaignsAndEvents() {
        Id userId = UserInfo.getUserId();
        Id profileId = UserInfo.getProfileId();
        Profile pf = [SELECT Name FROM Profile WHERE Id = :profileId];
        User usr = [SELECT ContactId, AccountId FROM User WHERE Id = :userId];
        Id conId = usr.ContactId;
        Id accId = usr.AccountId;
        List<Campaign> cmsRegistered = [SELECT Id, Name, Url__c, StartDate, EndDate, DateTime__c FROM Campaign WHERE Id IN (SELECT CampaignId FROM CampaignMember WHERE ContactId = :conId) AND StartDate >= TODAY];
        List<Campaign> cmsNotRegistered = [SELECT Id, Name, Url__c, StartDate, EndDate, DateTime__c FROM Campaign WHERE Type = 'Webinar' AND StartDate >= TODAY AND ID NOT IN  (SELECT CampaignId FROM CampaignMember WHERE ContactId = :conId)];
        List<Event> events = [
            SELECT Id, Subject, StartDateTime, EndDateTime, Description, Location, Who.Name, Owner.FirstName, Owner.LastName ,ShowInVp__c,SubjectVp__c,DescriptionVp__c
            FROM Event
            WHERE StartDateTime >= TODAY
            AND (WhoId = :conId OR OwnerId = :userId)
            AND ShowInVp__c =true
        ];
        List<CustomEvent> customEvents = new List<CustomEvent>();
        for(Event e:events) {
            String ownerFullName = e.Owner.FirstName + ' ' + e.Owner.LastName;
            CustomEvent ce = new CustomEvent('event', e.Subject, null, e.StartDateTime, e.EndDateTime, null, null, e.Id, true, false, e.Description, e.Location, ownerFullName, e.Who.Name,e.DescriptionVp__c,e.SubjectVp__c);
            customEvents.add(ce);
        }

        for(Campaign cm:cmsRegistered) {
            CustomEvent ce = new CustomEvent('campaign', cm.Name, cm.Url__c, cm.DateTime__c, null, cm.StartDate, cm.EndDate, cm.Id, true, false, null, null, null, null,null,null);
            customEvents.add(ce);
        }
        for(Campaign cm:cmsNotRegistered) {
            CustomEvent ce = new CustomEvent('campaign', cm.Name, cm.Url__c, cm.DateTime__c, null, cm.StartDate, cm.EndDate, cm.Id, false, true, null, null, null, null,null,null);
            customEvents.add(ce);
        }
        
        customEvents.sort();

        return customEvents;
    }

    @AuraEnabled
    public static void createCampaignMember(CampaignMember cm) {
        insert cm;
    }

    @AuraEnabled
    public static void deleteCampaignMember(CampaignMember cm) {
        CampaignMember deleteCampaignMember = [SELECT Id FROM CampaignMember WHERE ContactId = :cm.ContactId AND CampaignId = :cm.CampaignId];
        delete deleteCampaignMember;
    }

    public class CustomEvent implements Comparable {
        @AuraEnabled
        public String type{get;set;}
        @AuraEnabled
        public String name{get;set;}
        @AuraEnabled
        public String url{get;set;}
        @AuraEnabled
        public DateTime startDateTime{get;set;}
        @AuraEnabled
        public DateTime endDateTime{get;set;}
        @AuraEnabled
        public Date startDate{get;set;}
        @AuraEnabled
        public Date endDate{get;set;}
        @AuraEnabled
        public  Id recordId{get;set;}
        @AuraEnabled
        public Boolean registered{get;set;}
        @AuraEnabled
        public Boolean unregistered{get;set;}
        @AuraEnabled
        public String location{get;set;}
        @AuraEnabled
        public String description{get;set;}
        @AuraEnabled
        public String whoName{get;set;}
        @AuraEnabled
        public String ownerName{get;set;}

        public Integer compareTo(Object compareTo) {
            // needs bus logic to decide if null date is < non null date or vice-versa
            CustomEvent ce = (CustomEvent) compareTo;
            if(ce.startDateTime == null || this.startDateTime == null) return 0;
            if (ce.startDateTime < this.startDateTime) return +1;
            if (ce.startDateTime > this.startDateTime) return -1;
            return 0; 
        }
        
        public CustomEvent(String type, String name, String url, DateTime startDateTime, DateTime endDateTime, Date startDate, Date endDate, Id recordId, Boolean registered, Boolean unregistered, String description, String location, String ownerName, String whoName, String descriptionVp, String subjectVp) {
            this.type = type;
            this.name =  subjectVp != null ? subjectVp:name;
            this.url = url;
            this.startDateTime = startDateTime;
            this.endDateTime = endDateTime;
            this.startDate = startDate;
            this.endDate = endDate;
            this.recordId = recordId;
            this.registered = registered;
            this.unregistered = unregistered;
            this.location = location;
            this.description =  descriptionVp != null ? descriptionVp:description;
            this.ownerName = ownerName;
            this.whoName = whoName;
        }
    }
}