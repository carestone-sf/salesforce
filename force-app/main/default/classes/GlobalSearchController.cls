public class GlobalSearchController {

    public GlobalSearchController() {

    }

    List < List < SObject >> searchList = new List < List < SObject >> ();

    Public String searchValue {
        get;
        set;
    }

    // Searches Accounts, Contacts and Leads with the value of the inputText field "searchValue" and sets the searchList with these values
    public void search() {
        searchList = [FIND: searchValue IN ALL FIELDS RETURNING Account(Id, Name, Maklerbetreuer_Wirtschaftshaus_2__r.FirstName, Maklerbetreuer_Wirtschaftshaus_2__r.LastName, Email__c, Maklerschutz_besteht__c, Dauerhaft_gesch_tzt__c), Contact(FirstName, LastName, Email, Kunden_Maklerschutz__c, Maklerschutz_besteht__c, Account.Name, Account.Maklerbetreuer_Wirtschaftshaus_2__r.FirstName, Account.Maklerbetreuer_Wirtschaftshaus_2__r.LastName, MailingPostalCode, Dauerhaft_gesch_tzt__c), Lead(FirstName, Email, CreatedDate, LastName, PostalCode)];
    }

    // Returns either null if nothing is searched yet, or the List of Contacts
    public List < Contact > getPossibleDups() {
        if (searchList.size() > 0) {
            return ((List < Contact > ) searchList[1]);
        }
        return null;
    }

    // Returns either null if nothing is searched yet, or the List of Leads
    public List < Lead > getPossibleDupLeads() {
        if (searchList.size() > 0) {
            return ((List < Lead > ) searchList[2]);
        }
        return null;
    }

    // Returns either null if nothing is searched yet, or the List of Accounts
    public List < Account > getPossibleDupAccounts() {
        if (searchList.size() > 0) {
            return ((List < Account >) searchList[0]);
        }
        return null;
    }
}