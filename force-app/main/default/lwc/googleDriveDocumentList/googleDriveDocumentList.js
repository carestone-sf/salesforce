import { LightningElement, api, track } from 'lwc';

export default class GoogleDriveDocumentList extends LightningElement {

    @api
    get documents() {
        return this._documents;
    }
    set documents(value) {
        this.setAttribute('documents', value);
        this._documents = value;
        this.setup();
    }

    @track _documents;

    documentsByParentFolder = [];

    loading = true;

    @track
    columns = [
        { label: 'Name',       fieldName: 'name', wrapText : true,
            cellAttributes: { 
                iconName: { fieldName: 'icon' }, iconPosition: 'left' 
            }
        },
        { label: 'Zuletzt geändert am', fieldName: 'fileLastModifiedDate', type: 'date'},
        // { label: 'Dokumententyp',       fieldName: 'application_id', wrapText : true,
        //     cellAttributes: { 
        //         iconName: { fieldName: 'icon' }, iconPosition: 'left' 
        //     }
        // },
        {
            label: 'Herunterladen',
            type: 'button-icon',
            typeAttributes:
            {
                iconName: 'utility:download',
                name: 'download'
            },
            initialWidth: 200
        },
        {
            label: 'Vorschau',
            type: 'button-icon',
            typeAttributes:
            {
                iconName: 'utility:preview',
                name: 'preview'
            },
            initialWidth: 200
        }
    ];

    connectedCallback() {
        this.setup();
    }

    setup() {
        const documentsByParentFolderJson = {};
        this.documentsByParentFolder = [];
        /*
            [ { "folderName": "abc", "documents": [] }, ... ]
        */
        for(let i = 0; i < this.documents.length; i++) {
            const doc = this.documents[i];
            if(doc.parentFolder == null) {
                continue;
            }
            if(documentsByParentFolderJson[doc.parentFolder] == null) {
                documentsByParentFolderJson[doc.parentFolder] = {};
                documentsByParentFolderJson[doc.parentFolder]["documents"] = [];
                documentsByParentFolderJson[doc.parentFolder]["folderName"] = doc.parentFolder;
            }
            documentsByParentFolderJson[doc.parentFolder]["documents"].push(doc);
        }

        for(const key in documentsByParentFolderJson) {
            this.documentsByParentFolder.push(documentsByParentFolderJson[key]);
        }
    }

    handleRowAction(event){
        const actionName = event.detail.action.name;
        const row = event.detail.row;
        switch (actionName) {
            case 'download':
                this.downloadFile(row);
                break;
            case 'preview':
                this.previewFile(row);
                break;
            default:
        }

    }

    downloadFile(doc) {
        const downloadLink = document.createElement("a");
        downloadLink.href = doc.downloadUrl;
        downloadLink.target = '_blank';
        downloadLink.download = doc.name;
        downloadLink.click();
    }

    previewFile(doc) {
        const downloadLink = document.createElement("a");
        downloadLink.href = doc.previewUrl;
        downloadLink.target = '_blank';
        downloadLink.download = doc.name;
        downloadLink.click();
    }

}