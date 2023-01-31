import { LightningElement, track, api, wire } from 'lwc';
import getPublicImmobilien from '@salesforce/apex/ImmobilienController.getPublicImmobilien';
import { MessageContext, publish, subscribe } from 'lightning/messageService';
import BERECHNUNGS_APARTMENTS_CHANGE from '@salesforce/messageChannel/BerechnungsApartmentsChange__c';
import CALCULATION_SAVE from '@salesforce/messageChannel/CalculationSave__c';
import { createRecord } from 'lightning/uiRecordApi';

export default class ApartmentPicker extends LightningElement {

    // Picklist to show available immobilien
    immobilienPicklist;

    // Array to determine if an apartment was already picked and should not be shown again
    chosenApartmentIds = [];
    
    // Used as a unique id for adding new apartments 
    count = 0;

    // Determines if we added apartments
    hasBerechnungsApartments = false;

    @track
    immobilienApartmentsPicklist = [];

    // Holds the BerechnungsApartment__c record to be inserted
    berechnungsApartment = {};

    apartmentDropdownDisabled = true;

    // If true, the immobilien/apartment picker will be shown
    showApartmentPicker = false;
    
    // The Berechnung__c record
    @api
    calculation;

    @api
    apartmentss;

    @api
    apartments;

    @api
    recordId;

    idsToApartment = {};

    deleteBerechnungsApartments = [];

    @wire(MessageContext) messageContext; 

    // Holds all public Property__c records including apartments
    immobilien;
    @wire(getPublicImmobilien)
    loadImmobilien(result) {
        // Build picklist for immobilien
        if(result.data) {
            this.immobilien = result.data;
            this.immobilienPicklist = [];
            for(let i = 0; i < this.immobilien.length; i++) {
                const immobilie = this.immobilien[i].immobilie;
                const teilobjekte = this.immobilien[i].teilobjekte;
                if(teilobjekte == null || teilobjekte.length == 0) {
                    continue;
                }
                this.immobilienPicklist.push({'label': immobilie.Name, 'value': immobilie.Id});
                for(let x = 0; x < teilobjekte.length; x++) {
                    const apartment = teilobjekte[x];
                    this.idsToApartment[apartment.Id] = apartment;
                }
            }
        }
    }

    connectedCallback() {
        console.log('calc: ', this.apartmentss);
        console.log('recordId: ', this.recordId);
        // Subscribe to the save event 
        subscribe(this.messageContext, CALCULATION_SAVE, (message) => {
            this.hasBerechnungsApartments = false;
        });
    }

    /**
     * Shows the immobilien/apartment picker
     */
    handleAddApartmentClick() {
        this.showApartmentPicker = true;
    }

    /**
     * Cancels adding an apartment
     */
    handleCancelApartmentClick() {
        this.showApartmentPicker = false;
    }

    /**
     * Saves a BerechnungsApartment__c
     */
    handleSaveApartmentClick() {
        createRecord({apiName: 'BerechnungsApartment__c', fields: this.berechnungsApartment})
                .then((data) => {
                    this.showApartmentPicker = false;
                })
                .catch((error) => {
                    this.showCalculationSaveErrorToast(error);
                });
    }

    /**
     * marks a BerechnungsApartment__c record to be deleted
     * @param {*} event 
     */
    handleRemoveApartmentWithIdClick(event) {
        if(this.calculation.data) {
            const key = event.target.closest('[data-key]').dataset.key;
            for(let i = 0;i < this.calculation.data.Berechnungs_Apartments__r.length; i++) {
                const apartment = this.calculation.data.Berechnungs_Apartments__r[i];
                if(apartment.Id == key) {                    
                    this.deleteBerechnungsApartments.push(apartment.Id);
                }
            }
        }
    }
 
    /**
     * Shows success toast
     */
     showCalculationSaveSuccessToast() {
        this.dispatchEvent(
            new ShowToastEvent({
                title: 'Erfolg',
                message: 'Das Apartment wurde erfolgreich gespeichert.',
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
                title: 'Beim Speichern ist ein Fehler aufgetreten.',
                message: error.message,
                variant: 'error'
            })
        );
    }

}