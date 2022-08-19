import { LightningElement, api, wire } from 'lwc';
import getMabvInvoicesApex from '@salesforce/apex/OpportunityController.getMabvInvoices';

export default class MabvOverview extends LightningElement {
    @api 
    recordId;

    abgerechneterBetrag = 0;
    vollstaendigAbgerechnet = 'Nein';
    vollstaendigBezahlt = 'Nein';
    restforderung = 0;
    bezahlterBetrag = 0;
    offenerBetrag = 0;
    rateOne;
    rateTwo;
    rateThree;
    rateFour;
    rateFive;
    rateSix;
    rateSeven;
    currentRate;

    opp;
    mabvInvoices;
    @wire(getMabvInvoicesApex, {oppId: '$recordId'})
    loadMabvInvoices(result) {
        if(result.data) {
            this.mabvOverview = result.data;
            if(this.mabvOverview != null) {
                this.opp = this.mabvOverview.opp;
                this.mabvInvoices = this.mabvOverview.mabvInvoices;
            }
            this.currentRate = this.mabvInvoices.length;
            for(let i = 0; i < this.mabvInvoices.length; i++) {
                const mabvInvoice = this.mabvInvoices[i];
                this.abgerechneterBetrag += mabvInvoice.RateGesamtInEuro__c;
                if(mabvInvoice.OffenerBetragNeu__c != null) {
                    this.offenerBetrag += mabvInvoice.OffenerBetragNeu__c;
                }
                if(i == 0) {
                    this.rateOne = this.mabvInvoices[i];
                } else if(i == 1) {
                    this.rateTwo = this.mabvInvoices[i];
                } else if(i == 2) {
                    this.rateThree = this.mabvInvoices[i];
                } else if(i == 3) {
                    this.rateFour = this.mabvInvoices[i];
                } else if(i == 4) {
                    this.rateFive = this.mabvInvoices[i];
                } else if(i == 5) {
                    this.rateSix = this.mabvInvoices[i];
                } else if(i == 6) {
                    this.rateSeven = this.mabvInvoices[i];
                }
            }
            
            if(this.opp.beurkundeter_Kaufpreis__c-100 <= this.abgerechneterBetrag) {
                this.vollstaendigAbgerechnet = 'Ja';
            } 
            if(this.opp.beurkundeter_Kaufpreis__c-100 <= this.abgerechneterBetrag && this.offenerBetrag < 100) {
                this.vollstaendigBezahlt = 'Ja';
            }
            if(this.abgerechneterBetrag) {
                this.restforderung = this.opp.beurkundeter_Kaufpreis__c - this.abgerechneterBetrag;
                if(!isNaN(this.restforderung) && this.restforderung < 1 && this.restforderung > -1) {
                    this.restforderung = 0;
                }
            }
            if(this.abgerechneterBetrag != null && this.offenerBetrag != null) {
                this.bezahlterBetrag = this.abgerechneterBetrag - this.offenerBetrag;
            }
        }
    }
}