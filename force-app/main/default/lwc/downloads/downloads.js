import { LightningElement, track } from 'lwc';
import apexClastTest from '@salesforce/apex/DownloadElementHelper.getContentVersionsByFolderNameReturningList'

export default class Downloads extends LightningElement {


        @track contentVersions;
        @track error;
        @track imageUrl;
        
                
        
//        handleLoad() {
//                apexClastTest({folderNa4me: 'Medienbereich_Beratungsbroschüre'})
//                    .then(result => {
//                        console.log(JSON.stringify((result)))
//                        this.contentVersions = result;
//                    })
//                    .catch(error => {
//                        this.error = error;
//                    });
//        }

        renderedCallback(){
                this.imageUrl = 'https://wirtschaftshaus--artur.sandbox.file.force.com/sfc/servlet.shepherd/version/renditionDownload?rendition=ORIGINAL_Jpg&versionId=0683G000000Dj05&operationContext=CHATTER&contentId=05T3G000000GC9B'
                apexClastTest({folderName: 'test123'}).then(result => {
                        console.table(JSON.stringify(result));
                        console.log(window.location.origin);
                        this.contentVersions = result;
                })
                .catch(error => {
                        console.log(error)
                });
        }
}