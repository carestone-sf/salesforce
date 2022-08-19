import { LightningElement, api, wire, track } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { loadStyle } from 'lightning/platformResourceLoader';
import relatedListResource from '@salesforce/resourceUrl/relatedListResource';
import getFinanzierungsbaustein from '@salesforce/apex/BerechnungController.getFinanzierungsbaustein';
import getBerechnung from '@salesforce/apex/BerechnungController.getBerechnung';
import { refreshApex } from '@salesforce/apex';
import { deleteRecord,getRecordNotifyChange } from 'lightning/uiRecordApi';

export default class RelatedListNewEditPopupFinanzierungsBaustein extends LightningElement {
    showModal = false
    @api sobjectLabel
    @api sobjectApiName    
    @api parentId
    @api recordId
    @api recordName
    sondertilgungId;

    get isEigenkapital() {
        return this.finanzierungsbaustein && this.finanzierungsbaustein.data && this.finanzierungsbaustein.data.Art__c == 'Eigenkapital';
    }

    @api show() {
        refreshApex(this.calculationResult);
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

    showSondertilgungOptions = [{
      "label": "Sondertilgung",
      "value": "showSondertilgung"  
    }]
    showSondertilgungValue = [];
    
    @track
    showSondertilgung = false;

    finanzierungsbaustein;
    calculationResult;
    openAmount = 0;

    @wire(getBerechnung, { recordId: '$parentId' })
    loadBerechnunng(result) {
        this.calculationResult = result;
        if(result.data) {
            const data = result.data;
            if(data && Object.keys(data).length > 0) {
                this.openAmount = data.Gesamtkosten__c - data.Kreditsumme__c - data.Eigenkapital__c;   
                if(this.openAmount < 0) {
                    this.openAmount = 0;
                }
                this.initKreditsummeField();
                this.initTilgungsbeginnField();
            }
        }
    }

    @wire(getFinanzierungsbaustein, { recordId: '$recordId' })
    loadFinanzierungsbaustein(result) {
        if(result.data) {
            this.finanzierungsbaustein = result;
            const data = this.finanzierungsbaustein.data;
            if(data && Object.keys(data).length > 0) {
                this.openAmount = data.Berechnung__r.Gesamtkosten__c - data.Berechnung__r.Kreditsumme__c - data.Berechnung__r.Eigenkapital__c + data.Kreditsumme__c;   
                if(this.openAmount < 0) {
                    this.openAmount = 0;
                }
                if(data.Sondertilgungen__r && data.Sondertilgungen__r.length > 0) {
                    this.sondertilgungId = data.Sondertilgungen__r[0].Id;
                    this.showSondertilgungValue = ['showSondertilgung'];
                    this.showSondertilgung = true;
                }
                this.initKreditsummeField();
                this.handleFesteLaufzeit(data.FesteLaufzeit__c);
                this.handleType(data.Art__c);
            }
        }
    };

    renderedCallback() {
        if(this.isNew()) {
            this.initKreditsummeField();
            this.initTilgungsbeginnField();
        }
        loadStyle(this, relatedListResource + '/relatedListNewEditPopup.css')
        refreshApex(this.calculation);
    }

    initKreditsummeField() {
        const kreditsummeField = this.template.querySelector('lightning-input-field[data-name="Kreditsumme__c"]');   
        if(this.openAmount && kreditsummeField && this.isNew()) {
            kreditsummeField.value = this.openAmount;
        }
    }

    initTilgungsbeginnField() {
        if(this.calculationResult && 
                    this.calculationResult.data && 
                    this.calculationResult.data.Hauptimmobilie__c != null && 
                    this.calculationResult.data.Hauptimmobilie__r.Repayment_Beginning__c != null) {
            const tilgungsbeginnField = this.template.querySelector('lightning-input-field[data-name="Tilgungsbeginn__c"]');   
            if(tilgungsbeginnField) {
                tilgungsbeginnField.value = this.calculationResult.data.Hauptimmobilie__r.Repayment_Beginning__c;
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
            this.hide(); 
            getRecordNotifyChange([{recordId: this.recordId}]);
            this.dispatchEvent(new CustomEvent("refreshdata"));
        }
    }

    handleSonderTilgungSuccess(event) {
        this.showFinanzierungsbausteinSaveSuccessToast();
        this.hide();
        this.dispatchEvent(new CustomEvent("refreshdata"));  
        getRecordNotifyChange([{recordId: this.recordId}]);
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

    handleKreditsummeChange() {
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
        const laufzeitInJahrenValue = laufzeitInJahrenField.value;
        const kreditsummeValue = kreditsummeField.value;
        const zinsInPercentValue = zinsInPercentField.value;
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