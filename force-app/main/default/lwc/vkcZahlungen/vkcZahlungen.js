import { LightningElement, api, wire } from 'lwc';
import { getRecord, getFieldValue } from 'lightning/uiRecordApi';

import KAUFPREIS from '@salesforce/schema/Opportunity.beurkundeter_Kaufpreis__c';
import ABGERECHNETER_BETRAG from "@salesforce/schema/Opportunity.AbgerechneterBetrag__c";
import BEZAHLTER_BETRAG from '@salesforce/schema/Opportunity.BezahlterBetrag__c';
import RESTFORDERUNG from '@salesforce/schema/Opportunity.Restforderung__c';
import VOLLSTAENDIG_ABGERECHNET from '@salesforce/schema/Opportunity.VollstaendigAbgerechnet__c';
import VOLLSTAENDIG_BEZAHLT from '@salesforce/schema/Opportunity.VollstaendigBezahlt__c';
import OFFENER_BETRAG from '@salesforce/schema/Opportunity.OffenerBetrag__c';

export default class VkcZahlungen extends LightningElement {

    @api recordId;

    @wire(getRecord, { recordId: '$recordId', fields: [KAUFPREIS, ABGERECHNETER_BETRAG, BEZAHLTER_BETRAG, RESTFORDERUNG, VOLLSTAENDIG_BEZAHLT, VOLLSTAENDIG_ABGERECHNET, OFFENER_BETRAG] })
    wiredOpportunity;

    get opportunityDataLoaded() {
        return this.wiredOpportunity && this.wiredOpportunity.data;
    }

    get kaufpreis() {
        return this.opportunityDataLoaded ? getFieldValue(this.wiredOpportunity.data, KAUFPREIS) : null;
    }

    get vollstaendigBezahlt() {
        if(this.opportunityDataLoaded && getFieldValue(this.wiredOpportunity.data, VOLLSTAENDIG_BEZAHLT) == true) {
            return 'Ja';
        } else {
            return 'Nein';
        }
    }    
    
    get vollstaendigAbgerechnet() {
        if(this.opportunityDataLoaded && getFieldValue(this.wiredOpportunity.data, VOLLSTAENDIG_ABGERECHNET) == true) {
            return 'Ja';
        } else {
            return 'Nein';
        }
    }

    get abgerechneterBetrag() {
        return this.opportunityDataLoaded ? getFieldValue(this.wiredOpportunity.data, ABGERECHNETER_BETRAG) : null;
    }

    get bezahlterBetrag() {
        return this.opportunityDataLoaded ? getFieldValue(this.wiredOpportunity.data, BEZAHLTER_BETRAG) : null;
    }

    get offenerBetrag() {
        return this.opportunityDataLoaded ? getFieldValue(this.wiredOpportunity.data, OFFENER_BETRAG) : null;
    }

    get restforderung() {
        return this.opportunityDataLoaded ? getFieldValue(this.wiredOpportunity.data, RESTFORDERUNG) : null;
    }
}