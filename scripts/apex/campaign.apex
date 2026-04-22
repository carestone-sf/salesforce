// Define the campaign ID
Id campaignId = '701Vi00000cTOSUIA4';

// List to hold contacts to update
List<Contact> contactsToUpdate = new List<Contact>();

try {
    // Query all campaign members associated with the campaign
    List<CampaignMember> campaignMembers = [
        SELECT ContactId 
        FROM CampaignMember 
        WHERE CampaignId = :campaignId AND ContactId != null
    ];
    
    // Build a set of unique contact IDs from campaign members
    Set<Id> contactIds = new Set<Id>();
    for (CampaignMember cm : campaignMembers) {
        contactIds.add(cm.ContactId);
    }
    
    // Query related contacts
    List<Contact> relatedContacts = [
        SELECT Id, Kampagnen__c 
        FROM Contact 
        WHERE Id IN :contactIds
    ];
    
    // Prepare contacts for update
    for (Contact c : relatedContacts) {
        if(c.Kampagnen__c != null) {
            c.Kampagnen__c += ';Incentive 2025';
        } else {
            c.Kampagnen__c = 'Incentive 2025';
        }
        contactsToUpdate.add(c);
    }
    
    // Update the contacts
    if (!contactsToUpdate.isEmpty()) {
        update contactsToUpdate;
        System.debug('Updated ' + contactsToUpdate.size() + ' contacts.');
    } else {
        System.debug('No contacts found for update.');
    }
} catch (Exception e) {
    System.debug('Error occurred: ' + e.getMessage());
}
