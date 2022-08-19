trigger CampaignMemberTrigger on CampaignMember (before insert) {
    if(Trigger.isInsert && Trigger.isBefore)
    {
    	Map<ID, Set<Contact>> campaignToConMap = new Map<Id, Set<contact>>();
        for(CampaignMember cm:Trigger.new)
        {
            	Set<Contact> lmList = campaignToConMap.get(cm.CampaignId);
	             if (lmList == null) lmList = new Set<Contact>();
	             Contact con = new Contact();
	             con.Id = cm.ContactId;
	             con.Kampagnenquelle__c = cm.CampaignId;
            	lmList.add(con);
            	campaignToConMap.put(cm.CampaignId, lmList);
        }
        List<Contact> consToUpdate = new List<Contact>();
        for(Set<Contact> cons:campaignToConMap.values()) {
        	for(Contact con:cons) {
        		consToUpdate.add(con);
        	}
        }
        update consToUpdate;
    }
}