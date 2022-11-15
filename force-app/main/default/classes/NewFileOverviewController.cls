public without sharing class NewFileOverviewController {

    public List<File> files {get;set;}

    public NewFileOverviewController() {
        this.files = getFiles();
    }

    public static List<File> getFiles() {
        List<File> newFiles = new List<File>();
        for(ImmobilienDmsDatei__c immoDmsDatei : [
            SELECT Id, Name, Immobilie__r.Name, DateiUrl__c FROM ImmobilienDmsDatei__c 
            WHERE FileLastModifiedDate__c >= :(System.now().addHours(-24)) AND DateiTyp__c = 'Dokumente' AND Immobilie__r.Is_Public__c = true
            ORDER BY Immobilie__r.Name ASC]) {
            newFiles.add(new File(immoDmsDatei));
        }
        return newFiles;
    }

    public class File {
        public String title {get;set;}
        public String immoName {get;set;}
        public String url {get;set;}

        public File(ImmobilienDmsDatei__c immoDmsDatei) {
            this.title = immoDmsDatei.Name;
            this.immoName = immoDmsDatei.Immobilie__r.Name;
            this.url = immoDmsDatei.DateiUrl__c;
        }
    }
}
