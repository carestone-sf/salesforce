import { LightningElement, wire, track, api } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import { MessageContext, subscribe, unsubscribe, publish } from 'lightning/messageService';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getAllImmobilien from '@salesforce/apex/ImmobilienController.getAllImmobilien';
import getBerechnungen from '@salesforce/apex/BerechnungController.getBerechnungSave';
import IMMOFINDER_FILTER_UPDATE from '@salesforce/messageChannel/ImmoFinderFilterUpdate__c';
import IMMO_FINDER_APARTMENT_SELECTED from '@salesforce/messageChannel/ImmoFinderApartmentSelected__c';
import IMMO_FINDER_NEW_CALCULATION_BUTTON_CLICKED from '@salesforce/messageChannel/immoFinderNewCalculationButtonClicked__c';
import insertBerechnungWithApartmentsApex from '@salesforce/apex/BerechnungController.insertBerechnungWithApartments';
import getBerechnungSaveWithIdApex from '@salesforce/apex/BerechnungController.getBerechnungSaveWithId';

export default class ImmoFinder extends NavigationMixin(LightningElement) {

    @track 
    immobilien = {};

    @track
    selectedApartments;

    @track
    loaded = false;

    @track
    data;

    @api
    berechnungSave;

    @api
    selectedApartmentslength;

    immobilieId;
    immobilieName;
    apartmentList = [];

    createVerkaufsraumOptions = [{ label: 'Neuen Verkaufsraum erstellen', value: 'createVerkaufsraum' }];
    createVerkaufsraumValue = [];

    get isCreateVerkaufsraum() {
        return this.createVerkaufsraumValue.includes('createVerkaufsraum');
    }

    get createVekraufsraumClass() {
        return this.createVerkaufsraumValue.includes('createVerkaufsraum') ? 'slds-hide' : '';
    }

    // Used to toggle the sticky modal
    hasSelectedApartments;

    // Sets the inital state for the "Zu Berechnung hinzufügen" modal
    showModalAddCalc = false;

    // Sets the inital state for the "Neue Berechnung" modal
    showModalNewCalc = false;

    columns = [
        { label: 'Berechnung Name', fieldName: 'Name'},
        { label: 'Verkaufsraum Name', fieldName: 'VerkaufsraumName'},
        { label: 'Erster Käufer', fieldName: 'ErsterKaeuferName'},
        { label: 'Erstelldatum', fieldName: 'CreatedDate', type: 'date'},
    ];
    
	@wire(MessageContext) messageContext;

    @wire(getAllImmobilien)
     loadImmobilien(result) {
         this.immobilien = result;
         if (result.data) {
             this.immobilien = this.transformResult(result);
             this.loaded = true;
             console.log(this.immobilien);
         }
     }

 	connectedCallback() {
        // processes the data received via the message channel
        // sets immobilien and loaded, which controls the loading spinning wheel
        // data comes from immoFinderFilter
        // this.subscription = subscribe(
 		// 	this.messageContext,
 		// 	IMMOFINDER_FILTER_UPDATE,
 		// 	(message) => {
        //          if(message.immobilien){
        //             const transformResult = message.immobilien;
        //             this.immobilien = transformResult; 
        //             this.loaded = true;
        //          }else{
        //             this.loaded = true;
        //          }
 		// 	});
            
        // processes the data received via the message channel and sets immobilieId, immobilieName and apartmentList
        // data comes from immoListCard
        this.subscription = subscribe(
            this.messageContext,
            IMMO_FINDER_APARTMENT_SELECTED,
             (message) => {
                this.selectedApartments = message;
                this.selectedApartmentslength = this.selectedApartments[0].apartmentList.length;
                this.hasSelectedApartments = this.selectedApartmentslength > 0
                this.immobilieId = this.selectedApartments[0].Id;
                this.immobilieName = this.selectedApartments[0].Name;
                this.apartmentList = this.selectedApartments[0].apartmentList;
            });

    }

	disconnectedCallback() {
		unsubscribe(this.subscription);
		this.subscription = null;
	}

    // **Functions to open and close the "Neue Berechnung" pop-up
    newCalcModal(){
        this.showModalNewCalc = true;
        this.showModalAddCalc = false;
    }

    callApex(berechnungId){
        getBerechnungSaveWithIdApex({ berechnungId: berechnungId })
        .then(result => {
            this.data = result;
        })
        .catch(error => {
            this.showErrorToast(error);
        });
    }
 
    duplicateCheck(apartmentId, berechnungId){
        this.callApex(berechnungId);
        if(this.data){
        }

        // for(let i = 0;i<this.data[0].Berechnungs_Apartments__r.length;i++){
        //     if(this.data[0].Berechnungs_Apartments__r[i].Apartment__c == apartmentId){
        //         return false;
        //     }
        // }
    }
    closeNewCalcModal(){
        this.showModalNewCalc = false;
    }
    // **

    // **Functions to open and close the "Zur Berechnung hinzufügen" pop-up
    addToCalcModal() {    
        const message = {};
        message.apartments = this.apartmentList;
        message.immobilieId = this.immobilieId;
        publish(this.messageContext, IMMO_FINDER_NEW_CALCULATION_BUTTON_CLICKED, message);
    }
         
    closeAddToCalcModal() {    
        this.showModalAddCalc = false;
    }
    // **

    handleRaumChange(event){
        this.verkaufsRaumId = event.detail.value;
    }

    insertBerechnungWithApartments(berechnungId) {
        const insertBerechnungsApartments = [];
        for(let i = 0; i < this.apartmentList.length; i++) {
            const berechnungsApartment = this.apartmentList[i];;
            const insertBerechnungsApartment = {};
            insertBerechnungsApartment.Immobilie__c = this.immobilieId;
            insertBerechnungsApartment.Apartment__c = berechnungsApartment.Id;
            insertBerechnungsApartment.Name = this.immobilieName + " - "+ berechnungsApartment.Name;
            insertBerechnungsApartments.push(insertBerechnungsApartment);
        }
        insertBerechnungWithApartmentsApex({berechnungId: berechnungId, berechnungsApartments: insertBerechnungsApartments }).then((data) => {
            this.showAddApartmentSuccessToast();
            this.selectedApartments = undefined;
            this.hasSelectedApartments = undefined;
            this.showModalAddCalc = false;
        }).catch((error) => {
            this.showErrorToast(error);
        });
    }

    insertNewBerechnungWithApartments(berechnungId) {
        const insertNewBerechnungsApartments = [];
        for(let i = 0; i < this.apartmentList.length; i++) {
            const berechnungsApartment = this.apartmentList[i];
            const insertNewBerechnungsApartment = {};
            insertNewBerechnungsApartment.Immobilie__c = this.immobilieId;
            insertNewBerechnungsApartment.Apartment__c = berechnungsApartment.Id;
            insertNewBerechnungsApartment.Name = this.immobilieName + " - "+ berechnungsApartment.Name;
            insertNewBerechnungsApartments.push(insertNewBerechnungsApartment);
        }
        insertBerechnungWithApartmentsApex({berechnungId: berechnungId, berechnungsApartments: insertNewBerechnungsApartments }).then((data) => {
            this.showModalNewCalc = false;
            this.showModalAddCalc = false;
            this.showCreateApartmentSuccessToast();
        }).catch((error) => {
            this.showErrorToast(error);
        });
    }

    showAddApartmentSuccessToast() {
        this[NavigationMixin.GenerateUrl]({
            type: 'standard__recordPage',
            attributes: {
                recordId: this.berechnungId,
                actionName: 'view',
            },
        }).then(url => {
            const linkPageToast = new ShowToastEvent({
                title: "Erfolgreich hinzugefügt",
                variant: 'success',
                message: "{1}",
                mode: 'sticky',
                messageData: [
                    'Salesforce',
                    {
                        url,
                        label: 'Hier klicken um zur Berechnung zu kommen'
                    }
                ]
            });
            this.dispatchEvent(linkPageToast);
        });
    }

    showCreateApartmentSuccessToast() {
        this[NavigationMixin.GenerateUrl]({
            type: 'standard__recordPage',
            attributes: {
                recordId: this.newBerechnungId,
                actionName: 'view',
            },
        }).then(url => {
            const linkPageToast = new ShowToastEvent({
                title: "Erfolgreich gespeichert",
                variant: 'success',
                message: "{1}",
                messageData: [
                    'Salesforce',
                    {
                        url,
                        label: 'Hier klicken um zur Berechnung zu kommen'
                    }
                ]
            });
            this.dispatchEvent(linkPageToast);
        });
    }

    showErrorToast(error) {
        this.dispatchEvent(
            new ShowToastEvent({
                title: 'Beim Speichern ist ein Fehler aufgetreten.',
                message: error.message,
                variant: 'error'
            })
        );
    }


    // Id of Berechnung__c record selected
    handleBerechnungSelection(event){
        this.selectedRows = event.detail.selectedRows;
    }

    handleAddClick(){
        this.verkaufsRaumId = this.selectedRows[0].Verkaufsraum__c;
        this.berechnungId = this.selectedRows[0].Id;
        this.insertBerechnungWithApartments(this.berechnungId);
    }

    handleCreation(event){
        this.newBerechnungId = event.detail.id;
        this.insertNewBerechnungWithApartments(this.newBerechnungId);
    }

    handleVerkaufsraumSuccess(event) {
        const verkaufsraumRaumId = event.detail.id;
        this.template.querySelector('lightning-input-field[data-id="verkaufsraum-field"]').value = verkaufsraumRaumId;
        this.template.querySelector('lightning-record-edit-form[data-id="berechnung-form"]').submit();
    }

    handleCreateVerkaufsraumOptionChange(event) {
        this.createVerkaufsraumValue = event.detail.value;
    }

    get hasResultsImmo() {
        return (this.immobilien.data.length > 0);
    }

    // Recursively iterate over the data and manipulate relationships to flat values, e.g.:
    // Customer__r.Name -> CustomerName
    iterateData(data) {
        if(Array.isArray(data)) {
            for(let i = 0; i < data.length; i++) {
                const currentData = data[i];
                
                this.iterateDataCurrent(currentData);
            }
        } else {
            this.iterateDataCurrent(data);
        }
        return data;
    }

    iterateDataCurrent(currentData) {
        for(let key in currentData) {
            if(key.indexOf('__r') > -1 || key == 'immobilie' || key == 'Account') {
                var value = currentData[key];
                if(Array.isArray(value) || key == 'immobilie' || key == 'Account') {
                    currentData[key] = this.iterateData(value);
                } else {
                    var relationship = key.replace('__r', '');
                    for(let innerKey in currentData[key]) {
                        const newKey = relationship + innerKey;
                        currentData[newKey] = currentData[key][innerKey];
                        if(innerKey == 'Name') {
                            const linkId = relationship + 'IdLink';
                            currentData[linkId] = '/s/detail/' + currentData[key]['Id'];
                        }
                    }
                    delete currentData[key];
                }
            } else if(key.indexOf('__c') > -1) {
                let value = currentData[key];
                if(!isNaN(value)) {
                    if(key.toLowerCase().indexOf('purchase_price') > -1) {
                        currentData[key] = Math.round(currentData[key]);
                    } else if(key.toLowerCase().indexOf('zip_code') == -1) {
                        currentData[key] = Math.round(currentData[key] * 100) / 100;
                    }
                }
                if(key == 'OeffentlicherStatus__c') {
                    let colorClass = '';
                    if(currentData[key] == 'frei') {
                        colorClass = 'cs-text-color-green';
                    } else if(currentData[key] == 'Reserviert') {
                        colorClass = 'cs-text-color-gray';
                    } else if(currentData[key] == 'Notar') {
                        colorClass = 'cs-text-color-orange';
                    } else if(currentData[key] == 'Verkauft') {
                        colorClass = 'cs-text-color-red';
                    }
                    currentData['statusColorClass'] = colorClass;
                }
            }
        }
    }

    transformResult(result) {
        const copy = this.deepCopyFunction(result);
        copy.data = this.iterateData(copy.data);
        return copy;
    }

    deepCopyFunction(inObject) {
        let outObject, value, key
      
        if (typeof inObject !== "object" || inObject === null) {
          return inObject // Return the value if inObject is not an object
        }
      
        // Create an array or object to hold the values
        outObject = Array.isArray(inObject) ? [] : {}
      
        for (key in inObject) {
          value = inObject[key]
      
          // Recursively (deep) copy for nested objects, including arrays
          outObject[key] = this.deepCopyFunction(value)
        }
      
        return outObject
      }

}