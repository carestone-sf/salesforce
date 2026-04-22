// Invite partner portal users
// Step 1: Query all active partner users
List<User> partnerUsers = [SELECT Id, ContactId 
                           FROM User 
                           WHERE ContactId != null AND IsActive = true AND Contact.EinladungZumVPSenden__c = false AND Contact.Email != null LIMIT 50];

// Step 2: Query Permission Set Assignments for the specific permission set
Set<Id> userIdsWithPermissionSet = new Set<Id>();
for (PermissionSetAssignment psa : [
    SELECT AssigneeId 
    FROM PermissionSetAssignment 
    WHERE PermissionSetId = '0PS67000000yII3' 
]) {
    userIdsWithPermissionSet.add(psa.AssigneeId);
}

// Step 3: Prepare Contacts for update
Map<Id, Contact> contactsToUpdate = new Map<Id, Contact>();

for (User user : partnerUsers) {
    if (user.ContactId != null) {
        Contact contact = new Contact(Id = user.ContactId);

        // Set EinladungZumVPSenden__c to true for all contacts
        contact.EinladungZumVPSenden__c = true;

        // Check if user has the permission set and set VPRollen__c if applicable
        if (userIdsWithPermissionSet.contains(user.Id)) {
            contact.VPRollen__c = 'Provision';
        }

        // Add to map to ensure each Contact is updated only once
        contactsToUpdate.put(contact.Id, contact);
    }
}

// Step 4: Update all contacts in bulk
update contactsToUpdate.values();

System.debug('Contacts updated with invitation settings and roles.');
