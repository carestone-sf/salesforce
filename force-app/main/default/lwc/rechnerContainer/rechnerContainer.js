import { LightningElement, wire } from 'lwc';
import { createRecord, updateRecord, getRecord, getFieldValue, generateRecordInputForCreate } from 'lightning/uiRecordApi';
import CONTACT_ID from "@salesforce/schema/User.ContactId";
import USER_ID from "@salesforce/user/Id";
import { subscribe, publish, MessageContext } from 'lightning/messageService';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import LOAD_LIST_UPDATE from '@salesforce/messageChannel/LoadListUpdate__c';

// Events
import CALCULATION_VALUE_CHANGE from '@salesforce/messageChannel/CalculationValueChange__c';
import BERECHNUNGS_APARTMENTS_CHANGE from '@salesforce/messageChannel/BerechnungsApartmentsChange__c';
import FINANZIERUNGS_BAUSTEINE_CHANGE from '@salesforce/messageChannel/FinanzierungsBausteineChange__c';
import CALCULATION_SAVE from '@salesforce/messageChannel/CalculationSave__c';

// Apex
import insertBerechnungsApartmentsApex from '@salesforce/apex/BerechnungController.insertBerechnungsApartments';
import getBerechnung from '@salesforce/apex/BerechnungController.getBerechnung';
import deleteBerechnungsApartmentsApex from '@salesforce/apex/BerechnungController.deleteBerechnungsApartments';
import deleteFinanzierungsBausteineApex from '@salesforce/apex/BerechnungController.deleteFinanzierungsBausteine';
import insertFinanzierungsBausteineApex from '@salesforce/apex/BerechnungController.insertFinanzierungsBausteine';
import { refreshApex } from '@salesforce/apex';

export default class RechnerContainer extends LightningElement {
    // Holds the calculation values for saving / deleting
    calculationValues;
    berechnungsApartments = [];
    createBerechnungsApartments = [];
    deletedBerechnungsApartments = [];
    finanzierungsBausteine = [];
    createFinanzierungsBausteine = [];
    deletedFinanzierungsBausteine = [];

    receivedRecordId;

    // Object which is used to update the calculation itself
    updateObject = {};
    recordId;

    // Controls the modal to input "calculation metadata" (i.e. Name)
    showDataInputModal = false;

    // Controls the modal to load an existing calculation
    bShowModal = false;

    // Indicated wether to save the calculation as new or existing
    saveAsNewCalculation = false;

    // boolean value to use in html to check if the record was already saved or not
    recordIdDoesntExist = false;
    get recordIdDoesntExist() {
        return recordId != null;
    }

    // Holds the "real" calculation record
    calculation = {data: {}, error: {}};
    @wire(getBerechnung, { recordId: '$recordId' })
    loadCalculation(result) {
        if(result.data) {
            this.calculation = result;
        }
    }

    @wire(MessageContext) messageContext;

    // Sneaky trick to get the current contact id
    @wire(getRecord, { recordId: USER_ID, fields: [CONTACT_ID] })
    user;
    get contactId() {
      return getFieldValue(this.user.data, CONTACT_ID);
    }

    connectedCallback() {

        // Subscribe to all subcomponent change events to get calculation data
        subscribe(
			this.messageContext,
			CALCULATION_VALUE_CHANGE,
			(message) => {
				this.handleCalculationValueChange(message.calculationValues)
			}
		);

        subscribe(
			this.messageContext,
			BERECHNUNGS_APARTMENTS_CHANGE,
			(message) => {
				this.handleBerechnungsApartmentsChange(message.berechnungsApartments, message.deleteBerechnungsApartments)
			}
		);

        subscribe(
			this.messageContext,
			FINANZIERUNGS_BAUSTEINE_CHANGE,
			(message) => {
				this.handleFinanzierungsBausteineChange(message.finanzierungsBausteine, message.deleteFinanzierungsBausteine)
			}
		);
        
        subscribe(
			this.messageContext,
			LOAD_LIST_UPDATE,
			(message) => {
				this.saveData(message)
			}
		);
    }

    /**
     * Initiates duplicating the calculation
     */
    saveNewCalculation() {
        this.saveAsNewCalculation = true;
        this.showDataInputModal = true;
    }

    /**
     * Initiates saving the calculation
     */
    saveCalculation() {
        if(this.recordId && !this.saveAsNewCalculation) {
            this.updateObject.Id = this.calculation.data.Id;
            updateRecord({fields: this.updateObject})
            .then((data) => {
                this.insertBerechnungsApartments();
            })
            .catch((error) => {
               this.showCalculationSaveErrorToast(error);
            });
        } else {
            if(!this.updateObject.Name) {
                this.showDataInputModal = true;
            } else if(this.saveAsNewCalculation) {
                const calculationData = this.calculation.data;
                this.updateObject.ErsterKaeufer__c = calculationData.ErsterKaeufer__c;
                this.updateObject.ZweiterKauefer__c = calculationData.ZweiterKauefer__c;
                this.updateObject.Finanzierung__c = calculationData.Finanzierung__c;
                this.recordId = null;

                if(calculationData.Berechnungs_Apartments__r) {
                    for(let i = 0; i<calculationData.Berechnungs_Apartments__r.length; i++) {
                        const apartment = calculationData.Berechnungs_Apartments__r[i];
                        this.berechnungsApartments.push(this.getCreateApartment(apartment));
                    }
                }

                if(calculationData.Finanzierungsbausteine__r) {
                    for(let i = 0; i<calculationData.Finanzierungsbausteine__r.length; i++) {
                        const finanzierungsBaustein = calculationData.Finanzierungsbausteine__r[i];
                        this.finanzierungsBausteine.push(this.getCreateFinanzierungsbaustein(finanzierungsBaustein));
                   }
                }
                this.saveAsNewCalculation = false;
                this.saveCalculation();
            } else {
                this.updateObject.Makler__c = this.contactId;
                createRecord({apiName: 'Berechnung__c', fields: this.updateObject})
                .then((data) => {
                    this.recordId = data.id;
                    this.insertBerechnungsApartments();
                })
                .catch((error) => {
                    this.showCalculationSaveErrorToast(error);
                });
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
                message: 'Die Berechnung wurde erfolgreich gespeichert.',
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

    /**
     * Subscription handler for value changes to Berechnung__c
     * @param {*} calculationValues 
     */
    handleCalculationValueChange(calculationValues) {
        for(let key in calculationValues) {
            this.updateObject[key] = calculationValues[key];
        }
    }

    /**
     * Subscription handler for apartment changes (BerechnungsApartment__c)
     * @param {*} berechnungsApartments 
     * @param {*} deleteBerechnungsApartments 
     */
    handleBerechnungsApartmentsChange(berechnungsApartments, deleteBerechnungsApartments) {
        this.berechnungsApartments = berechnungsApartments.map(a => ({...a}));
        this.deletedBerechnungsApartments = deleteBerechnungsApartments.map(a => ({...a}));
    }

    /**
     * Subscription handler for finanzierungs baustein changes (FinanzierungsBaustein__c)
     * @param {*} finanzierungsBausteine 
     */
    handleFinanzierungsBausteineChange(finanzierungsBausteine, deleteFinanzierungsBausteine) {
        this.finanzierungsBausteine = finanzierungsBausteine.map(a => ({...a}));
        this.deletedFinanzierungsBausteine = deleteFinanzierungsBausteine.map(a => ({...a}));
    }

    /**
     * Logic to insert the BerechnungsApartment__c records related to the current calculation
     */
    insertBerechnungsApartments() {
        for(let i = 0; i < this.berechnungsApartments.length; i++) {
            const apartment = this.berechnungsApartments[i];
            this.createBerechnungsApartments.push(this.getCreateApartment(apartment));
        }
        insertBerechnungsApartmentsApex({berechnungsApartments: this.createBerechnungsApartments}).then((data) => {
            this.deleteBerechnungsApartments();
        }).catch((error) => {
            this.showCalculationSaveErrorToast(error);
            refreshApex(this.calculation);
        });
    }

    /**
     * Generate record for creation
     */
    getCreateApartment(originalApartment) {
        const createApartment = {};
        createApartment.Name = originalApartment.Name;
        createApartment.Berechnung__c = this.recordId;
        createApartment.Apartment__c = originalApartment.Apartment__c;
        createApartment.Immobilie__c = originalApartment.Immobilie__c;
        createApartment.sObjectType = 'BerechnungsApartment__c';
        return createApartment;
    }

    /**
     * Logic to delete the BerechnungsApartment__c records marked for deletion in the Apartment Picker
     */
    deleteBerechnungsApartments() {
        deleteBerechnungsApartmentsApex({deletedIds: this.deletedBerechnungsApartments}).then((data) => {
            this.insertFinanzierungsBausteine();
        }).catch((error) => {
            this.showCalculationSaveErrorToast(error);
            refreshApex(this.calculation);
        });
    }

    /**
     * Logic to insert the FinanzierungsBaustein__c records related to the current calculation
     */
    insertFinanzierungsBausteine() {
        for(let i = 0; i < this.finanzierungsBausteine.length; i++) {
            const finanzierungsBaustein = this.finanzierungsBausteine[i];
            this.createFinanzierungsBausteine.push(this.getCreateFinanzierungsbaustein(finanzierungsBaustein));
        }
        insertFinanzierungsBausteineApex({finanzierungsBausteine: this.createFinanzierungsBausteine}).then((data) => {
            this.deleteFinanzierungsBausteine();
        }).catch((error) => {
            this.showCalculationSaveErrorToast(error);
            refreshApex(this.calculation);
        });
    }

     /**
     * Generate record for creation
     */
      getCreateFinanzierungsbaustein(originalFinanzierungsbaustein) {
        const createFinanzierungsBaustein = {...originalFinanzierungsbaustein};
        delete createFinanzierungsBaustein['Id'];
        delete createFinanzierungsBaustein['counter'];
        createFinanzierungsBaustein.Berechnung__c = this.recordId;
        return createFinanzierungsBaustein;
    }

     /**
     * Logic to delete the Finanzierungsbaustein__c records marked for deletion in the Apartment Picker
     */
    deleteFinanzierungsBausteine() {
        deleteFinanzierungsBausteineApex({deletedIds: this.deletedFinanzierungsBausteine}).then((data) => {
            this.berechnungsApartments = [];
            this.createBerechnungsApartments = [];
            this.deletedBerechnungsApartments = [];
            this.finanzierungsBausteine = [];
            this.createFinanzierungsBausteine = [];
            this.deletedFinanzierungsBausteine = [];
            this.showCalculationSaveSuccessToast();
            refreshApex(this.calculation);
            const message = {saveFinished: true};
            publish(this.messageContext, CALCULATION_SAVE, message);
            this.showDataInputModal = false;
        }).catch((error) => {
            this.showCalculationSaveErrorToast(error);
            refreshApex(this.calculation);
        });
    }

    /**
     * onchange handler for name input in modal
     * @param {*} event 
     */
    handleNameChange(event) {
        this.updateObject.Name = event.detail.value;
    }

    /**
     * close the "save calculation" modal
     */
    closeModal() {
        this.showDataInputModal = false;
    }

    // Functions to open and close the load pop-up
    openLoadModal() {    
        this.bShowModal = true;
    }
 
    closeLoadModal() {    
        this.bShowModal = false;
    }

    // Saves the received recordId and waits for load
    // @param message - data received from the message channel LOAD_LIST_UPDATE
    saveData(message){
        this.receivedRecordId = message.recordId;
    }
    // Loads the recordId saved in receivedRecordId
    handleLoadClick(){
        this.recordId = this.receivedRecordId;
        this.bShowModal = 0;
    }
}