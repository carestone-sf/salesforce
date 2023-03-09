public with sharing class EmailMessageTriggerHandler implements ITrigger {
    
    Map<String, Contact> mapContactsByEmailAddress = new Map<String, Contact>();
    Map<Id,EmailMessageRelation> mapRelationByEmailMessageId = new Map<Id, EmailMessageRelation>();
    List<EmailMessageRelation> relationsToUpdate = new List<EmailMessageRelation>();

    public void bulkBefore() {

    }
    
    public void bulkAfter() {
        if(Trigger.isInsert) {
            Set<String> gutschriftRecipientEmails = new Set<String>();
            for(EmailMessage emailMessage : (List<EmailMessage>) Trigger.new) {
                SentEmail email = new SentEmail(emailMessage);
                if(email.isRelatedToGutschrift()) {
                    gutschriftRecipientEmails.addAll(email.getRecipientAddresses());
                }
            }

            if(!gutschriftRecipientEmails.isEmpty()) {
                for(Contact contact : [SELECT Id, EmailForCreditNotes__c FROM Contact WHERE EmailForCreditNotes__c IN :gutschriftRecipientEmails]) {
                    mapContactsByEmailAddress.put(contact.EmailForCreditNotes__c, contact);
                }
    
                for(EmailMessageRelation relation : [SELECT Id, EmailMessageId FROM EmailMessageRelation WHERE EmailMessageId IN :Trigger.new AND RelationAddress IN :gutschriftRecipientEmails]) {
                    mapRelationByEmailMessageId.put(relation.EmailMessageId, relation);
                }
            }
        }
    }

    public void beforeInsert(SObject so) {
        
    }

    public void beforeUpdate(SObject oldSo, SObject so) {
        
    }

    public void beforeDelete(SObject so) {

    }

    public void afterInsert(SObject so) {
        SentEmail email = new SentEmail((EmailMessage) so);

        if(email.isRelatedToGutschrift()) {
            for(String recipientAddress : email.getRecipientAddresses()) {
                if(mapContactsByEmailAddress.containsKey(recipientAddress) && mapRelationByEmailMessageId.containsKey(email.EmailMessage.Id)) {
                    EmailMessageRelation relation = mapRelationByEmailMessageId.get(email.EmailMessage.Id);
                    relation.RelationId = mapContactsByEmailAddress.get(recipientAddress).Id;
                    relationsToUpdate.add(relation);
                }
            }
        }
    }

    public void afterUpdate(SObject oldSo, SObject so) {
        
    }

    public void afterDelete(SObject so) {

    }

    public void andFinally() {
        update relationsToUpdate;
    }

    public class SentEmail {
        
        private SentEmail(EmailMessage emailMessage) {
            this.emailMessage = emailMessage;
        }

        private EmailMessage emailMessage;

        private Boolean isRelatedToGutschrift() {
            return emailMessage.RelatedToId != null && emailMessage.RelatedToId.getSobjectType() == Gutschrift__c.getSObjectType();
        }

        private Set<String> getRecipientAddresses() {
            return new Set<String> (emailMessage.toAddress.split(';'));
        }
    }
}
