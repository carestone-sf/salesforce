import { api, LightningElement } from 'lwc';
import VERTRIEBSPORTAL_SRC from '@salesforce/resourceUrl/VertriebsportalSrc';
import RUNDGAENGE from '@salesforce/resourceUrl/Rundgaenge';
import VIDEO_THUMBNAIL_ALLGEMEIN from '@salesforce/resourceUrl/Video_Thumbnail_Allgemein';
import RUNDGAENGE_2 from '@salesforce/resourceUrl/Rundgaenge2';
import OBJEKTFILM from '@salesforce/resourceUrl/Video_Thumbnail_Objektfilme';

//import apexClastTest from '@salesforce/apex/DownloadElementHelper.getContentVersionsByFolderName'

export default class DownloadElement extends LightningElement {

    @api
    fileType;

    @api
    downloadUrl;

    @api
    previewUrl;

    @api
    fileName;

    @api
    thumbnailUrl;

    @api isRundgang = false;
    @api isRundgang2 = false;

    @api isObjektfilm = false;
    @api isVideoAllgemein = false;


    get completeThumbnailUrl() {
        if(this.thumbnailUrl.indexOf('https://') > -1) {
            console.log('returning full url not changed')
            return this.thumbnailUrl;
        } else {
            if(this.isRundgang) {
                return RUNDGAENGE + this.thumbnailUrl;
            } else if(this.isVideoAllgemein) {
                return VIDEO_THUMBNAIL_ALLGEMEIN + this.thumbnailUrl;
            } else if(this.isRundgang2) {
                return RUNDGAENGE_2 + this.thumbnailUrl;
            } else if(this.isObjektfilm) {
                return OBJEKTFILM + this.thumbnailUrl;
            } else {
                return VERTRIEBSPORTAL_SRC + this.thumbnailUrl;
            }
        }
    }

    get hasThumbnailUrl() {
        return this.thumbnailUrl != null || this.fileType == 'Bild';
    }

    get hasDownloadUrl() {
        return this.downloadUrl != null;
    }

    get fileIcon() {
        let fileIcon;
        switch(this.fileType) {
            case 'PDF':
                fileIcon = 'doctype:pdf';
                break;
            case 'Excel':
                fileIcon = 'doctype:excel';
                break;
            case 'Word':
                fileIcon = 'doctype:word';
                break;
            case 'Bild':
                fileIcon = 'doctype:image';
                break;
            case 'Powerpoint':
                fileIcon = 'doctype:ppt'
                break;
        }
        return fileIcon;
    }

    connectedCallback() {
    }

//    renderedCallback(){
//        apexClastTest({folderName: 'test123'}).then().then(result => {
//
//        console.log(JSON.stringify((result)))
//
//                                                    })
//                                                    .catch(error => {
//                                                       console.log(error)
//                                                    });
//    }

}