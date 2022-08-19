import { api, track, LightningElement, wire } from 'lwc';
import { MessageContext, publish, subscribe } from 'lightning/messageService';
import getRecordsApex from '@salesforce/apex/CreateMultipleRecordsController.getRecords';
import { refreshApex } from '@salesforce/apex';
import { deleteRecord,getRecordNotifyChange } from 'lightning/uiRecordApi';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class CreateMultipleRecords extends LightningElement {
    @api
    recordId;

    @api
    objectApiName;

    @api
    objectLabel;

    @api
    fields;

    get fieldsArray() {
        return this.fields.split(',');
    }

    @wire(getRecordsApex, { recordId: '$recordId', objectApiName: '$objectApiName', fields: '$fields' })
    records;

    // Used as the key in the iteration
    loading = false;

    get addRecordButtonLabel() {
        return this.objectLabel + ' hinzufügen';
    }

    get deleteRecordButtonLabel() {
        return this.objectLabel + ' löschen';
    }

    // Determines if we added records
    get hasRecords() {
        return this.records && this.records.length > 0;
    }

    showNewRecordForm = false;
    get showAddRecordButton() {
        return this.showNewRecordForm == false;
    }

    connectedCallback() {
    }

    renderedCallback() {
    }

    /**
     * Adds a.record to the list to be inserted
     */
    handleAddRecordClick() {
        this.showNewRecordForm = true;
    }

    /**
     * marks a Record__c record to be deleted
     * @param {*} event 
     */
    handleRemoveRecordWithIdClick(event) {
        this.loading = true;
        const key = event.target.closest('[data-key]').dataset.key;
        deleteRecord(key)
        .then(() => {    
            const evt = new ShowToastEvent({
                title: `${this.objectLabel} wurde erfolgreich gelöscht.`,
                variant: "success"
            });
            this.dispatchEvent(evt)
            refreshApex(this.records);
            this.loading = false;
        }).catch(error => {
            const evt = new ShowToastEvent({
                title: 'Fehler beim Löschen.',
                message: error.body.message,
                variant: 'error'
            })
            this.dispatchEvent(evt);
            this.loading = false;
        });
    }

    handleSave(){
        const isInputsCorrect = [...this.template.querySelectorAll('.record lightning-input-field')]
            .reduce((validSoFar, inputField) => {
                let valid = true;
                valid = inputField.reportValidity();
                return validSoFar && valid;
            }, true);
        if (!isInputsCorrect) {
            return;
        }   

        this.template.querySelector('.record').submit();      
    }    

    handleSuccess(event) {
        this.showRecordSaveSuccessToast();
        this.hideAddRecordForm(false); 
    }

    handleClose() {
        this.hideAddRecordForm(true);
    }

    hideAddRecordForm(canceled) {
        this.showNewRecordForm = false;
        if(canceled == false) {
            refreshApex(this.records);
        }
    }

    /**
     * Shows success toast
     */
     showRecordSaveSuccessToast() {
        this.dispatchEvent(
            new ShowToastEvent({
                title: 'Erfolg',
                message: `${this.objectLabel} wurde erfolgreich gespeichert.`,
                variant: 'success'
            })
        );
    }

    /**
     * Shows error toast
     * @param {message: 'your message'} error 
     */
    showRecordSaveErrorToast(error) {
        this.dispatchEvent(
            new ShowToastEvent({
                title: 'Beim Speichern ist ein Fehler aufgetreten.',
                message: error.message,
                variant: 'error'
            })
        );
    }

}