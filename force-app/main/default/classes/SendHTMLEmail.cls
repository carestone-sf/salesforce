public with sharing class SendHTMLEmail {

    @invocableMethod(label='Send HTML Email')
    public static List<Response>  SendEmail(List<Request> requests) {
        
      
        String HTMLbody = requests[0].HTMLbody;
        String plainTextBody = requests[0].plainTextBody;
        String subject = requests[0].subject;
        String replyEmailAddress = requests[0].replyEmailAddress;
        String senderDisplayName = requests[0].senderDisplayName;
        String templateID = requests[0].templateID;
        String templateTargetObjectId = requests[0].templateTargetObjectId;
        String orgWideEmailAddressId = requests[0].orgWideEmailAddressId;    
       
        //from https://developer.salesforce.com/docs/atlas.en-us.apexcode.meta/apexcode/apex_forcecom_email_outbound.htm

        // First, reserve email capacity for the current Apex transaction to ensure
        // that we won't exceed our daily email limits when sending email after
        // the current transaction is committed.
        //Messaging.reserveSingleEmailCapacity(2);

        // Processes and actions involved in the Apex transaction occur next,
        // which conclude with sending a single email.

        // Now create a new single email message object
        // that will send out a single email to the addresses in the To, CC & BCC list.
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();

        // Strings to hold the email addresses to which you are sending the email.
        //String[] toAddresses = new String[] {oneAddress}; 
        Map<String, Object> m = GenerateMap(requests[0]);
        String[] toAddresses = BuildAddressList('TO',m); 
        System.debug('toAddresses is: ' + toAddresses);
        String[] ccAddresses = BuildAddressList('CC',m); 
        System.debug('ccAddresses is: ' + ccAddresses);
        String[] bccAddresses = BuildAddressList('BCC', m);
        System.debug('bccAddresses is: ' + bccAddresses);
        

        // Assign the addresses for the To and CC lists to the mail object.
        mail.setToAddresses(toAddresses);
        mail.setCcAddresses(ccAddresses);
        mail.setBccAddresses(bccAddresses);

        //outgoing email can either use an orgWideEmailAddress or specify it here, but not both
        if (orgWideEmailAddressId != null && orgWideEmailAddressId != '') {
            mail.setOrgWideEmailAddressId(orgWideEmailAddressId);
        } else {
            // Specify the address used when the recipients reply to the email. 
            mail.setReplyTo(replyEmailAddress);

            // Specify the name used as the display name.
            mail.setSenderDisplayName(senderDisplayName);
        }

        // Specify the subject line for your email address.
        mail.setSubject(subject);

        // Set to True if you want to BCC yourself on the email.
        mail.setBccSender(false);

        // Optionally append the salesforce.com email signature to the email.
        // The email address of the user executing the Apex Code will be used.
        // True by default unless the user passes a value in.
        if(requests[0].useSalesforceSignature != null) {
            mail.setUseSignature(requests[0].useSalesforceSignature);
        } else {
            mail.setUseSignature(true);
        }

        if (requests[0].attachments != null) {
            mail = AddAttachments(mail, requests[0].attachments);
        }
        
        if (templateID != null && ((HTMLbody != null) || (plainTextBody != null)))
            throw new FlowEmailActionException('you\'re trying to pass in both a plaintext/html body and a template ID. Gotta pick one or the other. Make sure you\'re not confusing the Text Template resources in Flow, (which you can pass into either the HTMLBody or the plainTextBody) with the templateId, which represents a Salesforce Email Template (either Classic or Lightning).');
           
        if ((templateID != null && templateTargetObjectId == null) || (templateID == null && templateTargetObjectId != null))
            throw new FlowEmailActionException('templateId and templateTargetObjectId have to be used together. the target recordID determines how to fill in the mergefields in the template.');
            
        mail.setTemplateID(templateID);
        mail.setTargetObjectId(templateTargetObjectId);
        System.debug('templateID is:' + templateID);
        
        // Specify the text content of the email.
        mail.setPlainTextBody(plainTextBody);

        mail.setHtmlBody(HTMLbody);
        System.debug('mail is:' + mail);
        Messaging.SendEmailResult[] emailResponse;
        Boolean completed;
        String error;
        // Send the email you have created.
        try {
            emailResponse = Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
            System.debug('emailResponse is: ' + emailResponse);
            completed = true;
        } catch (FlowEmailActionException e){
            System.debug ('exception occured: ' + e.getMessage());
            completed = false;
            error = e.getMessage();
        } catch (System.EmailException e){
            System.debug ('exception occured: ' + e.getMessage());
            completed = false;
            error = e.getMessage();
        }
       
        //report back the results
        Response response = new Response();
        if (completed == true) {
            if (emailResponse[0].isSuccess() != true) {
                Messaging.SendEmailError[] curErrors = emailResponse[0].getErrors();
                String errorReport = '';
                for(Messaging.SendEmailError curError : curErrors ) {
                    errorReport = errorReport + curError.getMessage() + '/n';
                }
                response.errors = errorReport;
                response.isSuccess = false;
                }
            else {
                response.isSuccess = true;
            }
          
        } else {
            response.errors = error;
            response.isSuccess = false;
        }
        
        
       
        List<Response> responseList = new List<Response>();
        responseList.add(response);
        return responseList;
    }

    //credit to https://digitalflask.com/blog/send-email-attachments-salesforce-apex/
    public static Messaging.SingleEmailMessage AddAttachments(Messaging.SingleEmailMessage mail, List<Attachment> curAttachments) {
        List<Messaging.EmailFileAttachment> attachments = new List<Messaging.EmailFileAttachment>();
        for (Attachment file: curAttachments) {
            Messaging.EmailFileAttachment efa = new Messaging.EmailFileAttachment();
            efa.setFileName(file.Name);
            efa.setBody(file.Body);
            efa.setContentType(file.ContentType);
            attachments.add(efa);
        }
        mail.setFileAttachments(attachments); 
        return mail;
    }

    public static String[] BuildAddressList(string type, Map<String, Object> m) {
        
        String[] addressList = new List<String>();
        String curEmail;
        
        //build address list
        //handle individual addresses
        String oneAddress = (String)m.get('Send' + type + 'thisOneEmailAddress');
        if ( oneAddress != null) {
            addressList.add(oneAddress);
            System.debug('address list is:' + addressList);
        }

        //handle inputs involving collections of String addresses
        List<String> stringAddresses = (List<String>)m.get('Send' + type + 'thisStringCollectionOfEmailAddresses');
        if (stringAddresses != null) {
            addressList.addAll(stringAddresses);
            System.debug('address list is:' + addressList);
        }
        
        
        //handle inputs involving collections of Contacts
        List<Contact> curContacts = (List<Contact>)m.get('Send' + type + 'theEmailAddressesFromThisCollectionOfContacts');        
        if (curContacts != null) {
            List<String> extractedEmailAddresses = new List<String>();
            for (Contact curContact : curContacts) {
                curEmail = curContact.email;
                if (curEmail != null) extractedEmailAddresses.add(curEmail);
            }
            addressList.addAll(extractedEmailAddresses);
            System.debug('address list is now:' + addressList); 
        }
        
        //handle inputs involving collections of Users
        List<User> curUsers = (List<User>)m.get('Send' + type + 'theEmailAddressesFromThisCollectionOfUsers');
        if (curUsers != null) {
            List<String> extractedEmailAddresses = new List<String>();
            for (User curUser : curUsers) {
                curEmail = curUser.email;
                if (curEmail != null) extractedEmailAddresses.add(curEmail);
            }
            addressList.addAll(extractedEmailAddresses);
            System.debug('address list is now:' + addressList);
        }
        
        //handle inputs involving collections of Leads
        List<Lead> curLeads = (List<Lead>)m.get('Send' + type + 'theEmailAddressesFromThisCollectionOfLeads');
        if (curLeads != null) {
            List<String> extractedEmailAddresses = new List<String>();
            for (Lead curLead : curLeads) {
                curEmail = curLead.email;
                if (curEmail != null) extractedEmailAddresses.add(curEmail);
            }
            addressList.addAll(extractedEmailAddresses);
            System.debug('address list is now:' + addressList);
        }


        return addressList;

    }

    private static Map<String, Object> GenerateMap(Request request) {
       
        return new Map<String, Object>{
           'SendTOthisOneEmailAddress' => request.SendTOthisOneEmailAddress,
           'SendTOthisStringCollectionOfEmailAddresses'  => request.SendTOthisStringCollectionOfEmailAddresses,
           'SendTOtheEmailAddressesFromThisCollectionOfContacts' => request.SendTOtheEmailAddressesFromThisCollectionOfContacts,
           'SendTOtheEmailAddressesFromThisCollectionOfUsers' => request.SendTOtheEmailAddressesFromThisCollectionOfUsers,
           'SendTOtheEmailAddressesFromThisCollectionOfLeads' => request.SendTOtheEmailAddressesFromThisCollectionOfLeads,
           'SendCCthisOneEmailAddress' => request.SendCCthisOneEmailAddress,
           'SendCCthisStringCollectionOfEmailAddresses'  => request.SendCCthisStringCollectionOfEmailAddresses,
           'SendCCtheEmailAddressesFromThisCollectionOfContacts' => request.SendCCtheEmailAddressesFromThisCollectionOfContacts,
           'SendCCtheEmailAddressesFromThisCollectionOfUsers' => request.SendCCtheEmailAddressesFromThisCollectionOfUsers,
           'SendCCtheEmailAddressesFromThisCollectionOfLeads' => request.SendCCtheEmailAddressesFromThisCollectionOfLeads,
           'SendBCCthisOneEmailAddress' => request.SendBCCthisOneEmailAddress,
           'SendBCCthisStringCollectionOfEmailAddresses'  => request.SendBCCthisStringCollectionOfEmailAddresses,
           'SendBCCtheEmailAddressesFromThisCollectionOfContacts' => request.SendBCCtheEmailAddressesFromThisCollectionOfContacts,
           'SendBCCtheEmailAddressesFromThisCollectionOfUsers' => request.SendBCCtheEmailAddressesFromThisCollectionOfUsers,
           'SendBCCtheEmailAddressesFromThisCollectionOfLeads' => request.SendBCCtheEmailAddressesFromThisCollectionOfLeads 
  };
       
    }

  



    public class Request {
        @invocableVariable
        public String HTMLbody;

        @invocableVariable
        public String plainTextBody;
        
        @invocableVariable
        public String templateID;
        
        @invocableVariable(label='Template Target Record Id' description='If you are passing in a template Id, you need to also pass in the Id of context record. It can be a Contact, Lead, or User. It will determine which data gets merged into the template')
        public String templateTargetObjectID;
        
        @invocableVariable
        public String subject;
        
        @invocableVariable
        public String replyEmailAddress;
        
        @invocableVariable
        public String senderDisplayName;

        @invocableVariable
        public String orgWideEmailAddressId;

        @invocableVariable
        public String SendTOthisOneEmailAddress;

        @invocableVariable
        public List<String> SendTOthisStringCollectionOfEmailAddresses;

        @invocableVariable
        public List<Contact> SendTOtheEmailAddressesFromThisCollectionOfContacts;

        @invocableVariable
        public List<User> SendTOtheEmailAddressesFromThisCollectionOfUsers;
        
        @invocableVariable
        public List<Lead> SendTOtheEmailAddressesFromThisCollectionOfLeads;

        @invocableVariable
        public String SendCCthisOneEmailAddress;

        @invocableVariable
        public List<String>  SendCCthisStringCollectionOfEmailAddresses;

        @invocableVariable
        public List<Contact> SendCCtheEmailAddressesFromThisCollectionOfContacts;

        @invocableVariable
        public List<User> SendCCtheEmailAddressesFromThisCollectionOfUsers;
        
        @invocableVariable
        public List<Lead> SendCCtheEmailAddressesFromThisCollectionOfLeads;

        @invocableVariable
        public String SendBCCthisOneEmailAddress;

        @invocableVariable
        public List<String>  SendBCCthisStringCollectionOfEmailAddresses;

        @invocableVariable
        public List<Contact> SendBCCtheEmailAddressesFromThisCollectionOfContacts;

        @invocableVariable
        public List<User> SendBCCtheEmailAddressesFromThisCollectionOfUsers;
        
        @invocableVariable
        public List<Lead> SendBCCtheEmailAddressesFromThisCollectionOfLeads;
        
        @invocableVariable
        public Boolean UseSalesforceSignature;

        @invocableVariable
        public List<Attachment> Attachments;

    }

    public class Response {
        @invocableVariable
        public Boolean isSuccess; 
        
        @invocableVariable
        public String errors;

    }
            
    public class FlowEmailActionException extends Exception {}
   
}