import { LightningElement, api, track } from 'lwc';

export default class AddFinanzierungsBaustein extends LightningElement {
    @api recordId;

    @track berechnungsApartmentColumns = [
        { label: 'Name', fieldName: 'Name', type: 'text' },
        { label: 'Art', fieldName: 'Art__c', type: 'text' },
        { label: 'Summe', fieldName: 'Kreditsumme__c', type: 'currency', cellAttributes: { alignment: 'left' } }
    ]

    connectedCallback() {
        
    }
}