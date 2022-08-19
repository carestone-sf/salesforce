import { LightningElement, api, track } from 'lwc';

export default class AddBerechnungsApartment extends LightningElement {
    @api recordId;

    @track berechnungsApartmentColumns = [
        { label: 'Name', fieldName: 'Name', type: 'text' },
        { label: 'Listenpreis', fieldName: 'Listenpreis__c', type: 'currency', cellAttributes: { alignment: 'left' } }
    ]

    connectedCallback() {
        
    }
}