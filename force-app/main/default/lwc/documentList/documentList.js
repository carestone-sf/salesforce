import { LightningElement, wire, api, track } from 'lwc';
import getDocumentsApex from '@salesforce/apex/DMSController.getDocuments';
import getDocumentTypesApex from '@salesforce/apex/DMSController.getDocumentTypes';
import getDocumentApex from '@salesforce/apex/DMSController.getDocument';
import uploadDocumentFromContentVersionIdApex from '@salesforce/apex/DMSController.uploadDocumentFromContentVersionId';
import createFolderFromRecordIdApex from '@salesforce/apex/DMSController.createFolderFromRecordId';
import { refreshApex } from '@salesforce/apex';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import PROPERTY_HAUPTIMMOBILIE from "@salesforce/schema/Property__c.Hauptimmobilie__c";
import PROPERTY_ID from "@salesforce/schema/Property__c.Id";
import { getRecord, getFieldValue, getRecordNotifyChange} from 'lightning/uiRecordApi';

export default class DocumentList extends LightningElement {
    @api 
    recordId;

    @api
    hideUploadButton = false;

    @api
    folderSuffix;

    folderId;
    hauptimmobilieId;

    uploadDocumentModalShown = false;
    loading = true;
    docCount = 0;

    @track
    docs;
    @track
    documentTypes;
    @track
    documentTypeOptions = [];
    @track
    documentTypesLoaded = false;

    get folderExists() {
        return this.documentTypeOptions && this.documentTypeOptions.length > 0;
    }

    get folderExistsAndShowUploadButton() {
        return this.documentTypeOptions && this.documentTypeOptions.length > 0 && this.hideUploadButton != "true";
    }

    get folderDoesntExistsAndShowUploadButton() {
        return this.documentTypesLoaded && this.documentTypeOptions.length == 0 && this.hideUploadButton != "true";
    }

    get folderExistsAndHasDocuments() {
        return this.folderExists && this.docs;
    }

    selectedDocumentType;
    uploadedDocument;

    get acceptedFormats() {
        return ['.png', '.jpg', '.pdf', '.doc', '.docx', '.xls', '.xlsx'];
    }

    @track
    columns = [
        { label: 'Name',       fieldName: 'documentName', wrapText : true,
            cellAttributes: { 
                iconName: { fieldName: 'icon' }, iconPosition: 'left' 
            }
        },
        { label: 'Dokumentenart',  fieldName: 'documentTypeName'
        },
        { label: 'Dokumententyp',       fieldName: 'application_id', wrapText : true,
            cellAttributes: { 
                iconName: { fieldName: 'icon' }, iconPosition: 'left' 
            }
        },
        { label: 'Herunterladen', type:  'button', typeAttributes: { 
                label: 'Herunterladen', name: 'Herunterladen', variant: 'brand', iconName: 'action:download', 
                iconPosition: 'right' 
            } 
        }
    ];

    @wire(getRecord, { recordId: '$recordId', fields: [PROPERTY_ID, PROPERTY_HAUPTIMMOBILIE] })
    loadUser({error, data}) {
        if(data) {
            if(getFieldValue(data, PROPERTY_HAUPTIMMOBILIE) != null) {
                this.hauptimmobilieId = getFieldValue(data, PROPERTY_HAUPTIMMOBILIE);
                this.folderId = this.hauptimmobilieId;
                if(this.folderSuffix) {
                    this.folderId += '_' + this.folderSuffix;
                }
            }
        } else if(error) {
            this.hauptimmobilieId = this.recordId;
            this.folderId = this.recordId;
            if(this.folderSuffix) {
                this.folderId += '_' + this.folderSuffix;
            }
        }

        if(error || data) {
            getDocumentTypesApex({folderId: this.hauptimmobilieId}).then((result) => {
                if(result) {
                    console.log('is here', result);
                    this.documentTypes = result;
                    result.forEach((item) => {
                        const dropdownOption = {"label": item.documentTypeName, "value": item.typeId};
                        this.documentTypeOptions.push(dropdownOption);
                    });
                }

                this.documentTypesLoaded = true;

                getDocumentsApex({folderId: this.folderId, cachebuster: this.docCount}).then((res) => {
                    this.docs = res;
                    this.loading = false;
                }).catch((err) => {
                    this.loading = false;
                });
            }).catch((err) => {
                this.loading = false;
            });
        }
    }

    connectedCallback() {

    }

    downloadFile(row) {
        //const docNumber = event.target.closest('[data-key]').dataset.key;
        const docNumber = row.docNumber;
        getDocumentApex({docNumber: docNumber}).then((result) => {
            const linkSource = `data:application/octet-stream;base64,${result.fileContent}`;
            const downloadLink = document.createElement("a");
            downloadLink.href = linkSource;
            downloadLink.download = result.fileName + '.' + result.fileExtension;
            downloadLink.click();
        }).catch((err) => {

        });   
    }

    createFolder() {
        this.loading = true;
        createFolderFromRecordIdApex({recordId: this.recordId, updateFolder: false, updateRecord: true}).then((res) => {
            refreshApex(this.docs);
            refreshApex(this.documentTypes);
            this.showCalculationSaveSuccessToast('Der Ordner wurde erfolgreich erstellt.');
            getDocumentTypesApex({folderId: this.hauptimmobilieId}).then((result) => {
                if(result) {
                    this.documentTypes = result;
                    result.forEach((item) => {
                        const dropdownOption = {"label": item.documentTypeName, "value": item.typeId};
                        this.documentTypeOptions.push(dropdownOption);
                    });
                }

                this.documentTypesLoaded = true;
            }).catch((err) => {
                this.loading = false;
            });
        }).catch((err) => {
            this.showCalculationSaveErrorToast(err);
            this.loading = false;
        });
    }

    handleRowAction(event){

        const actionName = event.detail.action.name;
        const row = event.detail.row;
        switch (actionName) {
            case 'Preview':
                this.previewFile(row);
                break;
            case 'Herunterladen':
                this.downloadFile(row);
                break;
            case 'Delete':
                this.handleDeleteFiles(row);
                break;
            default:
        }

    }

    showUploadDocumentModal() {
        this.uploadDocumentModalShown = true;
    }

    closeUploadDocumentModal() {
        this.uploadDocumentModalShown = false;
    }

    handleDocumentTypeChange(e) {
        this.selectedDocumentType = e.detail.value;
    }

    handleDocumentChange(e) {
        // Get the list of uploaded files
        const uploadedFiles = e.detail.files;
        if(uploadedFiles.length > 0 ) {
            this.uploadedDocument = uploadedFiles[0].contentVersionId;
        }
    }

    handleDocumentUpload() {
        this.loading = true;
        uploadDocumentFromContentVersionIdApex({"folderId": this.folderId, "contentVersionId": this.uploadedDocument, "documentTypeId": this.selectedDocumentType}).then(result => {
            //this.dispatchEvent(new CustomEvent("refreshdata"));
            this.showCalculationSaveSuccessToast('Die Datei wurde erfolgreich hochgeladen.');
            this.docCount++;
            getDocumentsApex({"folderId": this.folderId, "cachebuster": this.docCount}).then((res) => {
                this.docs = res;
                this.loading = false;
            }).catch((err) => {
                this.loading = false;
            });
        }).catch(err => {
            this.showCalculationSaveErrorToast(err);
            this.loading = false;
        });
    }

    /**
     * Shows success toast
     */
    showCalculationSaveSuccessToast(message) {
        this.dispatchEvent(
            new ShowToastEvent({
                title: 'Erfolg',
                message: message,
                variant: 'success'
            })
        );
    }

    /**
     * Shows error toast
     * @param {message: 'your message'} error 
     */
    showCalculationSaveErrorToast(error) {
        this.dispatchEvent(
            new ShowToastEvent({
                title: 'Ein Fehler ist aufgetreten',
                message: error.message,
                variant: 'error'
            })
        );
    }

}