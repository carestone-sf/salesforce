import { api, track, LightningElement, wire } from 'lwc';
import { MessageContext, publish, subscribe } from 'lightning/messageService';
import getBerechnung from '@salesforce/apex/BerechnungController.getBerechnung';
import { refreshApex } from '@salesforce/apex';
import { deleteRecord,getRecordNotifyChange } from 'lightning/uiRecordApi';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class FinanzierungsBausteine extends LightningElement {
    @api
    recordId;

    // Berechnung__c record
    // Holds the "real" calculation record
    calculation;
    @wire(getBerechnung, { recordId: '$recordId' })
    loadCalculation(result) {
        this.calculation = result;
        if(result.data) {
            this.finanzierungsArt = this.calculation.data.Finanzierungsart__c;
            if(this.eigenkapital == null) {
                this.eigenkapital = this.calculation.data.Eigenkapital__c;
            }
            this.calculateOpenAmount();
            this.openAmountNotEqualZero = this.openAmount != 0;

            this.finanzierungsBausteine = [];
            if(this.calculation.data.Finanzierungsbausteine__r != null) {
                for(let i = 0; i < this.calculation.data.Finanzierungsbausteine__r.length; i++) {
                    const finanzierungsBaustein = this.calculation.data.Finanzierungsbausteine__r[i];
                    if(!finanzierungsBaustein.IstEigenkapitalBaustein__c) {
                        this.finanzierungsBausteine.push(finanzierungsBaustein);
                    }
                }
            }
        }
        this.loading = false;
    }
    // Used as the key in the iteration
    count = 0;
    loading = true;

    @api
    eigenkapital;

    @api
    openAmountNotEqualZero;

    @api
    validate() {
        if(!this.openAmountNotEqualZero) { 
            return { isValid: true }; 
        } 
        else { 
            // If the component is invalid, return the isValid parameter 
            // as false and return an error message. 
            return { 
                isValid: false, 
                errorMessage: 'Die offene Summe muss 0 Euro ergeben.' 
            }; 
        }
    }

    @track
    openAmount = 0;

    // Determines if we added finanzierungsBausteine
    get hasFinanzierungsBausteine() {
        return this.finanzierungsBausteine && this.finanzierungsBausteine.length > 0;
    }

    showNewFinanzierungsBausteinForm = false;

    get showAddFinanzierungsBausteinButton() {
        return this.finanzierungsArt == 'Finanzierung' && this.openAmount > 0 && this.showNewFinanzierungsBausteinForm == false;
    }

    get showAddFinanzierungsBausteinFromOpenSumButton() {
        return this.finanzierungsArt == 'Finanzierung' && this.openAmount > 0 && this.showNewFinanzierungsBausteinForm == false;
    }

    showSondertilgungOptions = [{
        "label": "Sondertilgung",
        "value": "showSondertilgung"  
    }]
    showSondertilgungValue = [];
    
    @track
    showSondertilgung = false;
    sondertilgungId;

    // Options for radio button group
    finanzierungsArtOptions = [
        {label: 'Bar', value: 'Bar'},
        {label: 'Finanzierung', value: 'Finanzierung'}
    ]

    @api
    finanzierungsArt = 'Bar';
    get isBarFinanzierung() {
        return this.finanzierungsArt == 'Finanzierung' ? false : true;
    }

    @wire(MessageContext) messageContext; 

    // Holds the Finanzierungsbaustein__c records to be inserted
    @track
    finanzierungsBausteine;

    connectedCallback() {
        
    }

    renderedCallback() {
        refreshApex(this.calculation);
        console.log('other', this.template.querySelectorAll('input'));
        const fields = document.querySelectorAll('lightning-input-field');
        console.log(fields);
        fields.forEach(function(item) {
            console.log(item);
            item.setAttribute('autocomplete', 'off');
        });
    }

    handleFinanzierungsArtChange(event) {
        this.finanzierungsArt = event.detail.value;
        if(this.finanzierungsArt == 'Finanzierung') {
            this.eigenkapital = this.calculation?.data?.Eigenkapital__c != null ? this.calculation.data.Eigenkapital__c : 0;
        }
        this.calculateOpenAmount();
        this.openAmountNotEqualZero = this.openAmount != 0;
    }

    calculateOpenAmount() {
        if(this.calculation?.data != null && this.isBarFinanzierung) {
            this.eigenkapital = this.calculation.data.Gesamtkosten__c;
            this.openAmount = 0;
            this.openAmountNotEqualZero = false;
        } else if(this.calculation?.data != null) {
            const ek = this.eigenkapital != null ? this.eigenkapital : this.calculation.data.Eigenkapital__c;
            this.openAmount = Math.round(this.calculation.data.Gesamtkosten__c - this.calculation.data.Kreditsumme__c - ek);   
        }
    }

    /**
     * Handles changes to the inputs
     * @param {*} event 
     */
    handleValueChange(event) {
        const fieldName = event.target.fieldName;
        const fieldValue = event.detail.value;
        if(fieldName == 'Eigenkapital__c') {
            this.eigenkapital = fieldValue;
            this.calculateOpenAmount();
            this.openAmountNotEqualZero = this.openAmount != 0;
        }
    }

    /**
     * Adds a finanzierungsbaustein to the list to be inserted
     */
    handleAddFinanzierungsBausteinClick() {
        this.showNewFinanzierungsBausteinForm = true;
        const outerThis = this;
        setTimeout(function() {
            outerThis.initKreditsummeField();
            outerThis.initTilgungsbeginnField();
        }, 100);
        
    }

    /**
     * marks a FinanzierungsBaustein__c record to be deleted
     * @param {*} event 
     */
    handleRemoveFinanzierungsBausteinWithIdClick(event) {
        this.loading = true;
        if(this.calculation.data) {
            const key = event.target.closest('[data-key]').dataset.key;
            deleteRecord(key)
            .then(() => {    
                const evt = new ShowToastEvent({
                    title: `Der Finanzierungsbaustein wurde erfolgreich gelöscht.`,
                    variant: "success"
                });
                this.dispatchEvent(evt)
                refreshApex(this.calculation);
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
    }

    initKreditsummeField() {
        const kreditsummeField = this.template.querySelector('lightning-input-field[data-name="Kreditsumme__c"]');   
        if(this.openAmount && kreditsummeField) {
            kreditsummeField.value = this.openAmount;
            this.openAmount = 0;
        }
    }

    initTilgungsbeginnField() {
        if(this.calculation && 
                    this.calculation.data && 
                    this.calculation.data.Hauptimmobilie__c != null && 
                    this.calculation.data.Hauptimmobilie__r.Repayment_Beginning__c != null) {
            const tilgungsbeginnField = this.template.querySelector('lightning-input-field[data-name="Tilgungsbeginn__c"]');   
            if(tilgungsbeginnField) {
                tilgungsbeginnField.value = this.calculation.data.Hauptimmobilie__r.Repayment_Beginning__c;
            }
        }
    }

    handleSave(){
        const isInputsCorrect = [...this.template.querySelectorAll('.finanzierungsbaustein lightning-input-field')]
            .reduce((validSoFar, inputField) => {
                let valid = true;
                valid = inputField.reportValidity();
                return validSoFar && valid;
            }, true);
        if (!isInputsCorrect) {
            return;
        }   

        if(this.showSondertilgung) {
            const isInputsCorrect = [...this.template.querySelectorAll('.sondertilgung lightning-input-field')]
            .reduce((validSoFar, inputField) => {
                let valid = true;
                if(inputField.dataset.name != 'Finanzierungsbaustein__c') {
                    valid = inputField.reportValidity();
                } 
                return validSoFar && valid;
            }, true);
            
            if (isInputsCorrect) {
                this.template.querySelector('.finanzierungsbaustein').submit();  
            } else {
                // do nothing, as errors will be shown to the user
            }
        } else if(this.sondertilgungId) {
            deleteRecord(this.sondertilgungId)
            .then(() => {    
                this.template.querySelector('.finanzierungsbaustein').submit();      
            }).catch(error => {
                this.showFinanzierungsbausteinSaveErrorToast(error);
            });
        } else {
            this.template.querySelector('.finanzierungsbaustein').submit();      
        }
    }    

    handleSuccess(event) {
        if(this.showSondertilgung) {
            const finanzierungsbausteinField = this.template.querySelector('lightning-input-field[data-name="Finanzierungsbaustein__c"]');
            finanzierungsbausteinField.value = event.detail.id;
            this.submitSondertilgung();
        } else {
            this.showFinanzierungsbausteinSaveSuccessToast();
            this.hideAddFinanzierungsBausteinForm(false); 
        }
    }

    handleSonderTilgungSuccess(event) {
        this.showFinanzierungsbausteinSaveSuccessToast();
        this.hideAddFinanzierungsBausteinForm(false);
        this.dispatchEvent(new CustomEvent("refreshdata"));  
        getRecordNotifyChange([{recordId: this.recordId}]);
    }

    handleClose() {
        this.hideAddFinanzierungsBausteinForm(true);
    }

    hideAddFinanzierungsBausteinForm(canceled) {
        this.showNewFinanzierungsBausteinForm = false;
        this.showSondertilgung = false;
        if(canceled == false) {
            refreshApex(this.calculation);
        } else {
            this.calculateOpenAmount();
            this.openAmountNotEqualZero = this.openAmount != 0;
        }
    }

    submitSondertilgung() {
        this.template.querySelector('.sondertilgung').submit();  
    }

    handleFesteLaufzeitChange(event) {
        const festeLaufzeit = event.target.value;
        this.handleFesteLaufzeit(festeLaufzeit);
    }

    handleFesteLaufzeit(festeLaufzeit) {
        const laufzeitInJahrenField = this.template.querySelector('lightning-input-field[data-name="LaufzeitInJahren__c"]');
        const tilgungInPercentField = this.template.querySelector('lightning-input-field[data-name="TilgungInPercent__c"]');
        if(!festeLaufzeit) {
            laufzeitInJahrenField.disabled = true;
            laufzeitInJahrenField.required = false;
            laufzeitInJahrenField.value = null;
            tilgungInPercentField.disabled = false;
            tilgungInPercentField.required = true;
        } else {
            laufzeitInJahrenField.disabled = false;
            laufzeitInJahrenField.required = true;
            tilgungInPercentField.disabled = true;
            tilgungInPercentField.required = false;
        }
    }

    handleTypeChange(event) {
        const type = event.detail.value;
        this.handleType(type);
    }

    handleType(type) {
        const festeLaufzeitField = this.template.querySelector('lightning-input-field[data-name="FesteLaufzeit__c"]');
        const tilgungsBeginnField = this.template.querySelector('lightning-input-field[data-name="Tilgungsbeginn__c"]');
        if(type == 'Annuitäten Darlehen') {
            tilgungsBeginnField.disabled = false;
            festeLaufzeitField.disabled = false;
        } else if(type == 'Endfälliges Darlehen') {
            festeLaufzeitField.value = true;
            this.handleFesteLaufzeit(true);
            festeLaufzeitField.disabled = true;
            tilgungsBeginnField.disabled = true;
        } else if(type == 'KfW Darlehen') {
            tilgungsBeginnField.disabled = false;
            festeLaufzeitField.disabled = false;
        }
    }

    handleKreditsummeChange(event) {
        const kreditSumme = event.detail.value;
        if(kreditSumme != null) {
            this.calculateOpenAmount();
            this.openAmount -= kreditSumme;   
        }
        this.calculateTilgungInPercent();
    }

    handleZinsInPercentChange() {
        this.calculateTilgungInPercent();
    }

    handleLaufzeitInJahrenChange() {
        this.calculateTilgungInPercent();
    }

    handleSondertilgungChange(event) {
        const val = event.detail.value;
        if(val.includes('showSondertilgung')) {
            this.showSondertilgungValue = ['showSondertilgung'];
            this.showSondertilgung = true;
        } else {
            this.showSondertilgungValue = [];
            this.showSondertilgung = false;
        }
    }

    calculateTilgungInPercent() {
        const laufzeitInJahrenField = this.template.querySelector('lightning-input-field[data-name="LaufzeitInJahren__c"]');
        const kreditsummeField = this.template.querySelector('lightning-input-field[data-name="Kreditsumme__c"]');
        const zinsInPercentField = this.template.querySelector('lightning-input-field[data-name="ZinsInPercent__c"]');
        const tilgungInPercentField = this.template.querySelector('lightning-input-field[data-name="TilgungInPercent__c"]');
        const laufzeitInJahrenValue = laufzeitInJahrenField?.value;
        const kreditsummeValue = kreditsummeField?.value;
        const zinsInPercentValue = zinsInPercentField?.value;
        if(laufzeitInJahrenValue && kreditsummeValue && zinsInPercentValue) {
            const annuityZinsValue = zinsInPercentValue/100+1;
            const annuityRate = kreditsummeValue * Math.pow(annuityZinsValue, laufzeitInJahrenValue) * ((annuityZinsValue-1) / (Math.pow(annuityZinsValue, laufzeitInJahrenValue)-1));
            const tilgungInPercent = (annuityRate - (kreditsummeValue * zinsInPercentValue / 100) ) / kreditsummeValue * 100;
            tilgungInPercentField.value = tilgungInPercent.toFixed(2);
        }
    }

    handleSondertilgungValueChange(event) {
        const val = event.detail.value;
        if(val) {
            const kreditsummeField = this.template.querySelector('lightning-input-field[data-name="Kreditsumme__c"]'); 
            const kreditsumme = kreditsummeField.value;
            const percent = val / kreditsumme;
            const percentField = this.template.querySelector('lightning-input-field[data-name="Prozent__c"]'); 
            percentField.value = (percent*100).toFixed(2);
        }
    }

    handleSondertilungPercentChange(event) {
        const val = event.detail.value;
        if(val) {
            const kreditsummeField = this.template.querySelector('lightning-input-field[data-name="Kreditsumme__c"]'); 
            const kreditsumme = kreditsummeField.value;
            const value = kreditsumme * val/100; 
            const valueField = this.template.querySelector('lightning-input-field[data-name="Betrag__c"]'); 
            valueField.value = value;
        }
    }

    /**
     * Shows success toast
     */
     showFinanzierungsbausteinSaveSuccessToast() {
        this.dispatchEvent(
            new ShowToastEvent({
                title: 'Erfolg',
                message: 'Der Finanzierungsbaustein wurde erfolgreich gespeichert.',
                variant: 'success'
            })
        );
    }

    /**
     * Shows error toast
     * @param {message: 'your message'} error 
     */
    showFinanzierungsbausteinSaveErrorToast(error) {
        this.dispatchEvent(
            new ShowToastEvent({
                title: 'Beim Speichern ist ein Fehler aufgetreten.',
                message: error.message,
                variant: 'error'
            })
        );
    }

}