import { api, LightningElement, wire, track } from 'lwc';
import { getRecord } from 'lightning/uiRecordApi';

const FIELDS = [
    'Berechnung__c.Eigenkapital__c'
];

export default class BerechnungOverview extends LightningElement {
    @api 
    calculation;

    connectedCallback() {
    }
}