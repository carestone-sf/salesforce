import { LightningElement, api, wire } from 'lwc';
import { CloseActionScreenEvent } from 'lightning/actions';
import { loadScript } from 'lightning/platformResourceLoader';
import jsZipScript from '@salesforce/resourceUrl/JsZip';
import fileSaverScript from '@salesforce/resourceUrl/FileSaver';
import getRelatedContentVersions from '@salesforce/apex/DownloadRelatedFilesController.getRelatedContentVersions';
import getRelatedContentVersionIds from '@salesforce/apex/DownloadRelatedFilesController.getRelatedContentVersionIds';
import { getRecord } from 'lightning/uiRecordApi';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class DownloadFilesAsZip extends LightningElement {
    @api recordId;
    @api sobjectName;

    loadingText = 'Dateien werden heruntergeladen...';

    @wire(getRecord, { recordId: '$recordId', layoutTypes: 'Full' })
    wiredRecord({data, error}) {
        if(data) {
            this.recordData = data;
            if(this.scriptsLoaded) {
                this.doJsZip();
            }
        }
    }

    recordData;
    scriptsLoaded = false;

    connectedCallback() {
        Promise.all([
            loadScript(this, jsZipScript),
            loadScript(this, fileSaverScript)
        ]).then(() => {
            this.scriptsLoaded = true;
            if(this.recordData) {
                this.doJsZip();
            }
        });
    }

    doJsZip() {
        getRelatedContentVersions({recordId: this.recordId}).then(files => {
            if(files.length == 0) {
                this.dispatchEvent(new ShowToastEvent({
                    title: 'Nichts zu tun...',
                    message: 'Hier sind keine Dateien zum Herunterladen vorhanden.',
                    variant: 'info'
                }));
                this.close();
            } else {
                this.loadingText = 'Zip-Datei wird erstellt...';
                let zip = new JSZip();
    
                files.forEach(file => {
                    let title = file.title.replace('/', ':');
                    if(!title.endsWith('.' + file.extension)) {
                        title += '.' + file.extension;
                    }
                    zip.file(title, this.b64toBlob(file.data), {createFolders: false});
                });
                
                zip.generateAsync({type:"blob"}).then(blob =>{
                    saveAs(blob, `${this.recordName}.zip`);
                    this.close();
                }).catch(error => this.handleError(error));
            }
        }).catch(error => this.handleError(error));
    }

    downloadUsingSheperd() {
        getRelatedContentVersionIds({recordId: this.recordId}).then(contentVersionIds => {
            let baseUrl = window.location.origin;
            let fileIdsString = contentVersionIds.join('/');
            let sheperd = `/sfc/servlet.shepherd/version/download/${fileIdsString}?`;
    
            window.open(baseUrl + sheperd, '_blank');
            this.close();
        }).catch(error => {
            console.error(error);
            const evt = new ShowToastEvent({
                title: 'Fehler',
                message: 'Leider ist beim Erstellen der Zip-Datei ein Fehler aufgetreten.',
                variant: 'error',
            });
            this.dispatchEvent(evt);
        });
    }

    close() {
        this.dispatchEvent(new CustomEvent('close'));
        this.dispatchEvent(new CloseActionScreenEvent());
    }
    
    handleError(error) {
        console.warn(error);
        this.downloadUsingSheperd();
    }

    b64toBlob(b64Data, contentType='', sliceSize=512) {
        const byteCharacters = atob(b64Data);
        const byteArrays = [];
      
        for (let offset = 0; offset < byteCharacters.length; offset += sliceSize) {
          const slice = byteCharacters.slice(offset, offset + sliceSize);
      
          const byteNumbers = new Array(slice.length);
          for (let i = 0; i < slice.length; i++) {
            byteNumbers[i] = slice.charCodeAt(i);
          }
      
          const byteArray = new Uint8Array(byteNumbers);
          byteArrays.push(byteArray);
        }
      
        const blob = new Blob(byteArrays, {type: contentType});
        return blob;
    }

    get recordName() {
        return this.recordData.fields.Name.value;
    }
}