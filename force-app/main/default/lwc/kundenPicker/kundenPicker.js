import { LightningElement, api, wire } from 'lwc';
import { publish, MessageContext } from 'lightning/messageService';
import CALCULATION_VALUE_CHANGE from '@salesforce/messageChannel/CalculationValueChange__c';

export default class KundenPicker extends LightningElement {
    // Berechnung__c record
    @api
    calculation;

    @wire(MessageContext) messageContext;

    // Holds the values to be saved
    calculationValues = {};

    /**
     * Handles changes to our inputs and emits an event containing the data
     * @param {*} event 
     */
    handleInputChange(event) {
        const myInputFields = this.template.querySelectorAll("lightning-input-field");
        myInputFields.forEach(input => {
            this.calculationValues[input.fieldName] = input.value;
        });
        
        const message = {
            calculationValues: this.calculationValues
        };

        publish(this.messageContext, CALCULATION_VALUE_CHANGE, message);
    }
}