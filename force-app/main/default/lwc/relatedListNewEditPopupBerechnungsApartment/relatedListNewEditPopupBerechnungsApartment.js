import { LightningElement, api, wire, track } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { loadStyle } from 'lightning/platformResourceLoader';
import relatedListResource from '@salesforce/resourceUrl/relatedListResource';
import getPublicImmobilienApex from '@salesforce/apex/ImmobilienController.getPublicImmobilien';
import insertBerechnungsApartmentsApex from '@salesforce/apex/BerechnungController.insertBerechnungsApartments';
import { getRecordNotifyChange } from 'lightning/uiRecordApi';

export default class RelatedListNewEditPopupBerechnungsApartment extends LightningElement {
    showModal = false
    @api sobjectLabel
    @api sobjectApiName    
    @api parentId
    @api recordId
    @api recordName

    // Picklist to show available immobilien
    immobilienPicklist;

    // Array to determine if an apartment was already picked and should not be shown again
    chosenApartmentIds = [];

    @track
    immobilienApartmentsPicklist = [];

    // Holds the BerechnungsApartment__c record to be inserted
    berechnungsApartment = {};

    apartmentDropdownDisabled = true;

    idsToApartment = {};

    // Holds all public Property__c records including apartments
    immobilien;
    @wire(getPublicImmobilienApex)
    loadImmobilien(result) {
        // Build picklist for immobilien
        if(result.data) {
            this.immobilien = result.data;
            this.immobilienPicklist = [];
            for(let i = 0; i < this.immobilien.length; i++) {
                const immobilie = this.immobilien[i];
                this.immobilienPicklist.push({'label': immobilie.immobilie.Name, 'value': immobilie.immobilie.Id});
                if(immobilie.immobilie.Appartments__r) {
                    for(let x = 0; x < immobilie.immobilie.Appartments__r.length; x++) {
                        const apartment = immobilie.immobilie.Appartments__r[x];
                        this.idsToApartment[apartment.Id] = apartment;
                    }
                }
            }
        }
    }

    @api show() {
        this.showModal = true;
    }

    @api hide() {
        this.showModal = false;
    }
    handleClose() {
        this.showModal = false;     
    }
    handleDialogClose(){
        this.handleClose()
    }

    isNew(){
        return this.recordId == null
    }
    get header(){
        return this.isNew() ? `Neues ${this.sobjectLabel}` : `${this.recordName} bearbeiten`
    }

    handleSave(){
        this.template.querySelector('lightning-record-form').submit();
       
    }    
    renderedCallback() {
        loadStyle(this, relatedListResource + '/relatedListNewEditPopup.css');
    }         

    /**
     * Saves a BerechnungsApartment__c
     */
     handleSaveApartmentClick() {
        this.berechnungsApartment.Berechnung__c = this.parentId;
        insertBerechnungsApartmentsApex({berechnungsApartments: [this.berechnungsApartment]})
                .then((data) => {
                    this.hide()
                    let name = this.berechnungsApartment.Name;
                    
                    const message = `${this.sobjectLabel} ${name} wurde ${(this.isNew() ? "erstellt" : "gespeichert")}.`
                    const evt = new ShowToastEvent({
                        title: message,
                        variant: "success"
                    });
                    this.dispatchEvent(evt); 
                    this.dispatchEvent(new CustomEvent("refreshdata"));
                    getRecordNotifyChange([{recordId: this.parentId}]);             
                })
                .catch((error) => {
                });
    }

    /**
     * Handles changes to the immobilien picklist and builds apartment picklist
     * @param {*} event 
     */
     handleImmobilienInputChange(event) {
        const immobilienId = event.detail.value;
        this.immobilienApartmentsPicklist = [];
        for(let i = 0; i < this.immobilien.length; i++) {
            const immobilie = this.immobilien[i].immobilie;
            if(immobilienId != immobilie.Id) {
                continue;
            }
            this.berechnungsApartment.Immobilie__c = immobilie.Id;
            for(let x = 0; x < immobilie.Appartments__r.length; x++) {
                const apartment = immobilie.Appartments__r[x];
                if(this.chosenApartmentIds.indexOf(apartment.Id) == -1) {
                    this.immobilienApartmentsPicklist.push({'label': apartment.Name + ' - ' + new Intl.NumberFormat('de-DE', { style: 'currency', currency: 'EUR' }).format(apartment.Purchase_Price__c), 'value': apartment.Id});
                }
            }
        }
        this.apartmentDropdownDisabled = false;
    }

    /**
     * handles changes to the apartment picklist and emits event with the apartments to be inserted and deleted
     * @param {*} event 
     */
    handleApartmentInputChange(event) {
        const apartmentId = event.detail.value;
        const apartment = this.idsToApartment[apartmentId];
        this.berechnungsApartment.Apartment__c = apartmentId;
        this.berechnungsApartment.Name = apartment.Property__r.Name + ' - ' + apartment.Name;
        this.chosenApartmentIds.push(apartmentId);
    }
}