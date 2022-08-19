public without sharing class ApprovalController {
    
    @AuraEnabled(cacheable=true)
    public static List<ProvisionApproval> getProvisionApprovals() {
        Id userId = UserInfo.getUserId();
        List<ProcessInstanceWorkitem> workItems = [Select p.Id, p.ProcessInstance.TargetObjectId from ProcessInstanceWorkitem p where ActorId = :userId];
        List<Id> targetObjectIds = new List<Id>();
        for(ProcessInstanceWorkItem workItem:workItems) {
            targetObjectIds.add(workItem.ProcessInstance.TargetObjectId);
        }

        Map<Id, Provision__c> provs = new Map<Id, Provision__c>([SELECT Name, Wert_Maklerprovision__c, Wert_Verk_ufer_Beratungsprovision_m_R__c, Verkaufschance__r.Immobilie__r.Name, Verkaufschance__r.Appartement__r.Name FROM Provision__c WHERE ID IN :targetObjectIds]);

        List<ProvisionApproval> provApprovals = new List<ProvisionApproval>();

        for(ProcessInstanceWorkItem workItem:workItems) { 
            Provision__c p = provs.get(workItem.ProcessInstance.TargetObjectId);
            ProvisionApproval pa = new ProvisionApproval(workItem.Id, p.Name, p.Wert_Maklerprovision__c, p.Wert_Verk_ufer_Beratungsprovision_m_R__c, p.Verkaufschance__r.Immobilie__r.Name, p.Verkaufschance__r.Appartement__r.Name);
            provApprovals.add(pa);
        }
        
        return provApprovals;
    }

    @AuraEnabled
    public static void approveProvision(Id workItemId) {
        Approval.ProcessWorkitemRequest req = new Approval.ProcessWorkitemRequest();
        req.setComments('Vom Makler über das Vertriebsportal genehmigt.');
        req.setAction('Approve');
        req.setWorkitemId(workItemId);
        Approval.process(req);
    }

    @AuraEnabled 
    public static void rejectProvision(Id workItemId) {
        Approval.ProcessWorkitemRequest req = new Approval.ProcessWorkitemRequest();
        req.setComments('Vom Makler über das Vertriebsportal abgelehnt.');
        req.setAction('Reject');
        req.setWorkitemId(workItemId);
        Approval.process(req);
    }

    public class ProvisionApproval {
        @AuraEnabled
        public String workItemId{get;set;}
        @AuraEnabled
        public String name{get;set;}
        @AuraEnabled
        public Decimal maklerProv{get;set;}
        @AuraEnabled
        public Decimal beratungProv{get;set;}
        @AuraEnabled
        public String immobilieName{get;set;}
        @AuraEnabled
        public String apartmentName{get;set;}

        public ProvisionApproval(String workItemId, String name, Decimal maklerProv, Decimal beratungProv, String immobilieName, String apartmentName) {
            this.workItemId = workItemId;
            this.name = name;
            this.maklerProv = maklerProv;
            this.beratungProv = beratungProv;
            this.immobilieName = immobilieName;
            this.apartmentName = apartmentName;
        }
    }

}